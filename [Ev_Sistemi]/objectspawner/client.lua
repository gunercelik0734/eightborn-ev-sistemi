-- ModFreakz
-- For support, previews and showcases, head to https://discord.gg/ukgQa5K

local MFO = MF_ObjectSpawner
local ESX = nil
MFO.ShowingMarker = true
MFO.SavedObjects = {}
local playerIdent = nil
local editing = false
local price
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()
    playerIdent = ESX.GetPlayerData().identifier
end)

function MFO:Awake(...)
    while not ESX do Citizen.Wait(0); end
    while not ESX.IsPlayerLoaded() do Citizen.Wait(0); end
    self.PlayerData = ESX.GetPlayerData()
    ESX.TriggerServerCallback('MF_ObjectSpawner:GetStartData', function(retVal,retTab) self.dS = true; self.cS = retVal; self:Start(retTab); end)
end

function MFO:Start(retTab)
  self.SavedObjects = retTab
  if self.dS and self.cS then self:Update(); end
end

function MFO:Update(...)
  local timer = GetGameTimer()
  while self.dS and self.cS do
    Citizen.Wait(0)

    if self.ShowingMarker and not self.ControllingObject then
      local fwd,right,up,plyPos = GetEntityMatrix(GetPlayerPed(-1))
      local camPos = GetGameplayCamCoord()
      local offset = plyPos - camPos

      local pos = plyPos + (offset * self.Range) + (right * self.Range) + (up * self.Range)
      local found,z = GetGroundZFor_3dCoord(pos.x +2.0 ,pos.y + 2.0 ,pos.z + 2.0,z,false)
      if found and found >= 1 then if pos.z < z then pos = vector3(pos.x,pos.y,z); end; end

      --DrawMarker(0, pos.x,pos.y,pos.z, 0.0,0.0,0.0, 0.0,0.0,0.0, 0.5,0.5,0.5, 15,155,15,115, false,true,2,false,false,false,false)

      DisableControlAction(0,12,true)
      DisableControlAction(0,13,true)
      DisableControlAction(0,14,true)
      DisableControlAction(0,15,true)
      DisableControlAction(0,16,true)

      if IsDisabledControlJustPressed(0,self.Controls["INCREASE_RANGE"])  then self.Range = self.Range + self.RangeAdder; end
      if IsDisabledControlJustPressed(0,self.Controls["DECREASE_RANGE"])  then self.Range = self.Range - self.RangeAdder; end
      --if IsControlJustPressed(0,self.Controls["GRAB_OBJECT"])     then self:MoveObject(); end
    elseif self.ControllingObject and self.CurrentObject then
      local offset = vector3(0.0,0.0,0.0)
      local dimsMin,dimsMax = GetModelDimensions(GetEntityModel(self.CurrentObject))
      if dimsMin and dimsMax then
        if dimsMin.z > dimsMax.z then
          offset = vector3(0.0,0.0,dimsMin.z)
        else
          offset = vector3(0.0,0.0,dimsMax.z)
        end
      end
      local objPos = GetEntityCoords(self.CurrentObject)
			--Burası bir oynanacak gibi sanki
      local pos = objPos + offset
      DrawMarker(0, pos.x,pos.y,pos.z, 0.0,0.0,0.0, 0.0,0.0,0.0, 0.5,0.5,0.5, 155,15,15,115, false,true,2,false,false,false,false)

      --if IsControlJustPressed(0,self.Controls["GRAB_OBJECT"])     then self:MoveObject(); end
      if IsControlJustPressed(0,self.Controls["DROP_OBJECT"])     then self:DropObject(); end
      if IsControlJustPressed(0,self.Controls["SAVE_OBJECT"])     then self:SaveObject(); end
	  if IsControlJustPressed(0,self.Controls["DELETE_OBJECT"])     then self:DeleteObject(); end
    end

		if (GetGameTimer() - timer) > 1000 then
      timer = GetGameTimer()
      local plyPos = GetEntityCoords(GetPlayerPed(-1))
      for k,v in pairs(self.SavedObjects) do
        local dist = Utils.GetVecDist(plyPos,k)
        if v.obj and dist > self.DespawnDist then
          DeleteObject(v.obj)
          self.SavedObjects[k].obj = nil
        elseif not v.obj and dist < self.SpawnDist then
          while not HasModelLoaded(v.model) do RequestModel(v.model); Citizen.Wait(0); end
          local newObj = CreateObject(v.model, v.pos.x,v.pos.y,v.pos.z + 200.0, false,false,false)
          Citizen.Wait(100)
          SetEntityCoordsNoOffset(newObj,v.pos.x,v.pos.y,v.pos.z,false,false,false)
          SetEntityRotation(newObj, v.rot.x,v.rot.y,v.rot.z, 2, true)
          self.SavedObjects[k].obj = newObj
          SetModelAsNoLongerNeeded(v.model)
          Citizen.Wait(100)
					FreezeEntityPosition(newObj,true)
					SetEntityAsMissionEntity(newObj,true,true)
					SetModelAsNoLongerNeeded(GetHashKey(newObj))
        end
      end
    end

  end
end

function MFO:SaveObject()
  if not self.CurrentObject then return; end
  ESX.ShowNotification("Object Saved : "..self.CurrentObject)
	local pos = GetEntityCoords(self.CurrentObject)
  pos = vector3(math.round(pos.x,3.0),math.round(pos.y,3.0),math.round(pos.z,3.0))
  local rot = GetEntityRotation(self.CurrentObject,2)
  rot = vector3(math.round(rot.x,3.0),math.round(rot.y,3.0),math.round(rot.z,3.0))
  local model = GetEntityModel(self.CurrentObject)
  self.SavedObjects[pos] = {owner = playerIdent ,pos = pos, rot = rot, model = model}
  TriggerServerEvent('MF_ObjectSpawner:SaveObject', self.SavedObjects[pos])

	FreezeEntityPosition(self.CurrentObject,true)
	SetEntityAsMissionEntity(self.CurrentObject,true,true)
	SetModelAsNoLongerNeeded(GetHashKey(self.CurrentObject))
	--MFO:DropObject();
	self.ControllingObject = false
  self.CurrentObject = false
  self.ObjectFrozen = false
end

function MFO:DoSpawn(obj)
  if not self.ShowingMarker then ESX.ShowNotification("You need to use /build first."); return; end
  if not obj then return; end

  local hash = GetHashKey(obj)
  while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end

  local fwd,right,up,plyPos = GetEntityMatrix(GetPlayerPed(-1))
  local camPos = GetGameplayCamCoord()
  local offset = plyPos - camPos

  local pos = plyPos + (offset * self.Range) + (right * self.Range) + (up * self.Range + 0.5)
  local newObj = CreateObject(hash, pos.x,pos.y,pos.z, false,false,false)
	self.CurrentObject = newObj
	self:MoveObject(true)

end

function MFO:DropObject(...)
  if not self.ControllingObject or not self.CurrentObject then return; end
  ESX.ShowNotification("Dropped Object : "..self.CurrentObject)
  self.ControllingObject = false
  self.CurrentObject = false
  self.ObjectFrozen = false
	--Para iade Kısmı Burada Olmalı

end

function MFO:MoveObject(saved, id)
  if not self.ShowingMarker then return; end
  if self.ControllingObject then
    local pos = GetEntityCoords(self.CurrentObject)
    if not self.SavedObjects[pos] then
      if not saved then
        ESX.ShowNotification("D1:Delete Unsaved Object : "..self.CurrentObject)
      else
        ESX.ShowNotification("D1:Saved Object : "..self.CurrentObject)
      end
    end
		FreezeEntityPosition(self.CurrentObject,true)
		SetModelAsNoLongerNeeded(GetHashKey(self.CurrentObject))
		SetEntityAsMissionEntity(self.CurrentObject,true,true)
    DeleteObject(self.CurrentObject)
    --self:DoSavedDelete(self.CurrentObject)
    --self.ControllingObject = false
    --self.CurrentObject = false
    --self.ObjectFrozen = false

    return
  end

--local fwd,right,up,plyPos = GetEntityMatrix(GetPlayerPed(-1))
--local camPos = GetGameplayCamCoord()
--local offset = plyPos - camPos
--local pos = plyPos + (offset * self.Range) + (right * self.Range)
--local obj = ESX.Game.GetClosestObject({},pos)

  	local Kobjpos
		ESX.TriggerServerCallback('MF_ObjectSpawner:Mobilyalar', function(data)
			self.Data = (data or {})
			SavedObjects = {}
			for k,v in pairs(self.Data) do
				if(tonumber(v.ID) == tonumber(id)) then
					print("IDler uyuştu :"..tonumber(v.ID))
				  v.id = tonumber(v.ID)
				  v.pos = json.decode(v.pos)
				  v.rot = json.decode(v.rot)
				  local pos = vector3(v.pos.x, v.pos.y, v.pos.z)
				  local rot = vector3(v.rot.x, v.rot.y, v.rot.z)
				  SavedObjects[k] = {id = tonumber(v.ID), home = tonumber(v.home) , pos = pos, rot = rot, model = tonumber(v.model)}
					Kobjpos = SavedObjects[k]["pos"]
					print("Kobjpos : "..Kobjpos)
					self.CurrentObject = ESX.Game.GetClosestObject({}, Kobjpos)
				end
			end
		end)

  FreezeEntityPosition(obj,false)
  SetEntityCollision(obj,false,false)

  self.ControllingObject = true
  self.ObjectFrozen = false
  for k,v in pairs(self.SavedObjects) do
    if v.obj and self.CurrentObject == v.obj then
      ESX.ShowNotification("Delete Saved Object : "..self.CurrentObject)
      TriggerServerEvent('MF_ObjectSpawner:DeleteObject', v)
			DeleteObject()
    end
  end


  Citizen.CreateThread(function(...)
    while self.ControllingObject do
      Citizen.Wait(0)
	  HelpText(Strings['Furnishing'])
      local fwd,right,up,pos = GetEntityMatrix(self.CurrentObject)
      local rot = GetEntityRotation(self.CurrentObject,2)
      local moveSpeed = self.MoveSpeed
      local rotSpeed  = self.RotSpeed
      if IsControlJustPressed(0,self.Controls["SAVE_OBJECT"])     then self:SaveObject(); end
      if IsControlJustPressed(0,self.Controls["INCREASE_SPEED"]) or IsControlPressed(0,self.Controls["INCREASE_SPEED"]) then moveSpeed = moveSpeed * self.SpeedIncreaser; rotSpeed = rotSpeed * self.SpeedIncreaser; end
      if IsControlJustPressed(0,self.Controls["DECREASE_SPEED"]) or IsControlPressed(0,self.Controls["DECREASE_SPEED"]) then moveSpeed = moveSpeed * self.SpeedDecreaser; rotSpeed = rotSpeed * self.SpeedDecreaser; end

      if IsControlJustPressed(0,self.Controls["RIGHT"])   or IsControlPressed(0,self.Controls["RIGHT"])   then pos = pos + (right *moveSpeed); end
      if IsControlJustPressed(0,self.Controls["LEFT"])    or IsControlPressed(0,self.Controls["LEFT"])    then pos = pos - (right *moveSpeed); end
      if IsControlJustPressed(0,self.Controls["FORWARD"]) or IsControlPressed(0,self.Controls["FORWARD"]) then pos = pos + (fwd   *moveSpeed); end
      if IsControlJustPressed(0,self.Controls["BACK"])    or IsControlPressed(0,self.Controls["BACK"])    then pos = pos - (fwd   *moveSpeed); end
      if IsControlJustPressed(0,self.Controls["UP"])      or IsControlPressed(0,self.Controls["UP"])      then pos = pos + (up    *moveSpeed); end
      if IsControlJustPressed(0,self.Controls["DOWN"])    or IsControlPressed(0,self.Controls["DOWN"])    then pos = pos - (up    *moveSpeed); end

      if IsControlJustPressed(0,self.Controls["ROTX+"])   or IsControlPressed(0,self.Controls["ROTX+"])   then rot = rot + vector3(rotSpeed,0.0,0.0); end
      if IsControlJustPressed(0,self.Controls["ROTX-"])   or IsControlPressed(0,self.Controls["ROTX-"])   then rot = rot - vector3(rotSpeed,0.0,0.0); end
      if IsControlJustPressed(0,self.Controls["ROTY+"])   or IsControlPressed(0,self.Controls["ROTY+"])   then rot = rot + vector3(0.0,rotSpeed,0.0); end
      if IsControlJustPressed(0,self.Controls["ROTY-"])   or IsControlPressed(0,self.Controls["ROTY-"])   then rot = rot - vector3(0.0,rotSpeed,0.0); end
      if IsControlJustPressed(0,self.Controls["ROTZ+"])   or IsControlPressed(0,self.Controls["ROTZ+"])   then rot = rot + vector3(0.0,0.0,rotSpeed); end
      if IsControlJustPressed(0,self.Controls["ROTZ-"])   or IsControlPressed(0,self.Controls["ROTZ-"])   then rot = rot - vector3(0.0,0.0,rotSpeed); end
      ESX.Game.Utils.DrawText3D(pos, ("Mobilya :"), 0.9)

      SetEntityRotation(self.CurrentObject, rot.x,rot.y,rot.z, 2, true)
      SetEntityCoords(self.CurrentObject, pos.x,pos.y,pos.z)
    end

    SetEntityCollision(self.CurrentObject,true,true)
    self.ObjectFrozen = false
    self.CurrentObject = false
  end)
end

function MFO:SyncObject(obj)
  self.SavedObjects[obj.pos] = obj
end

function MFO:DeleteObject(pos)
		DeleteObject(GetHashKey(ESX.Game.GetClosestObject({}, pos)))
		editing = true;
		MFO:Mobilya()
		if self.SavedObjects[pos] then
		    if self.SavedObjects[pos].obj and (not self.CurrentObject or (self.CurrentObject and self.CurrentObject ~= self.SavedObjects[pos].obj)) then
					DeleteObject(self.SavedObjects[pos].obj)
		    end
		    self.SavedObjects[pos] = nil
		  end
end

HelpText = function(msg, coords)
    if not coords or not Config.Use3DText then
        AddTextEntry(GetCurrentResourceName(), msg)
        DisplayHelpTextThisFrame(GetCurrentResourceName(), true)
		SetTextWrap(1.0,1.0)
    else
        DrawText3D(coords, string.gsub(msg, "~INPUT_CONTEXT~", "~r~[~w~E~r~]~w~"), 0.20)
    end
end

function MFO:DoSavedDelete(obj)
  for k,v in pairs(self.SavedObjects) do
    if v.obj and obj == v.obj then
      ESX.ShowNotification("Delete Saved Object : "..obj)
      TriggerServerEvent('MF_ObjectSpawner:DeleteObject',v)
    end
  end
end

function MFO:ShowMarker()
  self.ShowingMarker = not self.ShowingMarker
end

function MFO:Mobilya()
	if editing == true then
		editing = false
	else
		editing = true
	end
	ESX.TriggerServerCallback('MF_ObjectSpawner:Mobilyalar', function(data)
	self.Data = (data or {})
	SavedObjects = {}
	for k,v in pairs(self.Data) do
	  v.id = tonumber(v.ID)
	  v.pos = json.decode(v.pos)
	  v.rot = json.decode(v.rot)
	  local pos = vector3(v.pos.x, v.pos.y, v.pos.z)
	  local rot = vector3(v.rot.x, v.rot.y, v.rot.z)
	  SavedObjects[k] = {id = tonumber(v.ID), home = tonumber(v.home) , pos = pos, rot = rot, model = tonumber(v.model)}
	end
  end)
	while editing do
		Wait(0)
		for k, v in pairs(SavedObjects) do
			ESX.Game.Utils.DrawText3D(v.pos, ("Mobilya ID: ~r~"..SavedObjects[k]["id"]), 0.9)
		end
	end
end

function MFO:MobilyaSil(id)
	local Kobjpos
	ESX.TriggerServerCallback('MF_ObjectSpawner:Mobilyalar', function(data)
		self.Data = (data or {})
		SavedObjects = {}
		for k,v in pairs(self.Data) do
			if(tonumber(v.ID) == tonumber(id)) then
				v.pos = json.decode(v.pos)
				DeleteObject(ESX.Game.GetClosestObject({}, 	v.pos))
				DeleteObject(GetHashKey(ESX.Game.GetClosestObject({}, 	v.pos)))
			end
		end
	end)
	editing = true;
	MFO:Mobilya()

	TriggerServerEvent('MF_ObjectSpawner:ObjeSil', id)
	ESX.ShowNotification(id.." ID numaralı obje silindi.")

end

RegisterCommand('mobilyasil', function(source,args) MFO:MobilyaSil(args[1]); end)
RegisterCommand('mobilyaduzenle', function(source,args) MFO:MoveObject(true, args[1]); end)
RegisterCommand('mobilyalar', function() MFO:Mobilya(); end)

RegisterNetEvent('MF_ObjectSpawner:Mobilya')
AddEventHandler('MF_ObjectSpawner:Mobilya', function(...) MFO:Mobilya(...); end)

RegisterNetEvent('MF_ObjectSpawner:MoveObject')
AddEventHandler('MF_ObjectSpawner:MoveObject', function(...) MFO:MoveObject(...); end)

RegisterNetEvent('MF_ObjectSpawner:DoBuild')
AddEventHandler('MF_ObjectSpawner:DoBuild', function(...) MFO:ShowMarker(...); end)

RegisterNetEvent('MF_ObjectSpawner:DoSpawn')
AddEventHandler('MF_ObjectSpawner:DoSpawn', function(...) MFO:DoSpawn(...); end)

RegisterNetEvent('MF_ObjectSpawner:SyncObject')
AddEventHandler('MF_ObjectSpawner:SyncObject', function(...) MFO:SyncObject(...); end)

RegisterNetEvent('MF_ObjectSpawner:DeleteObject')
AddEventHandler('MF_ObjectSpawner:DeleteObject', function(...) MFO:DeleteObject(...); end)

RegisterNetEvent('MF_ObjectSpawner:Awake')
AddEventHandler('MF_ObjectSpawner:Awake', function(...) MFO:Awake(...); end)

Citizen.CreateThread(function(...) MFO:Awake(...); end)
