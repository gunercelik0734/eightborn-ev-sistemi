local housing = playerhousing
local ESX = nil
local playerIdent = nil
local kapiacik = "0"

function housing:Awake(...)
  while not ESX do Citizen.Wait(0); end
  while not ESX.IsPlayerLoaded() do Citizen.Wait(0); end
  self.PlayerData = ESX.GetPlayerData()
  TriggerServerEvent('playerhousing:Start')
end
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()
    createBlips()
    playerIdent = ESX.GetPlayerData().identifier
end)

function housing:Respond(var1,tabA,var2,var3)
  ESX.TriggerServerCallback('playerhousing:GetKeys', function(keys)
    self.Keys = (keys or {})
    for k,v in pairs(self.Keys) do
      if v and v.house then
        tabA[v.house].keys = true
      end
    end
    self.HouseData = tabA;
    if var2 and var2 > 0 then
      self:EnterHouse(self.HouseData[var2].Entry,self.HouseData[var2],false,true)
    end
    if var3 then self.PlayerData.identifier = var3; end
    self:RefreshBlips()
    self:Update()
  end)
end

function housing:RefreshBlips()
  if self.Blips then
    for k,v in pairs(self.Blips) do
      RemoveBlip(v)
    end
  end

  self.Blips = {}
  for k,v in pairs(self.HouseData) do
    if (not v.owner and self.ShowEmptyHouses) or (v.owner and v.owner == self.PlayerData.identifier) then
      local blip = AddBlipForCoord(v.Entry.x, v.Entry.y, v.Entry.z)
      SetBlipDisplay              (blip, 4)
      SetBlipScale                (blip, 1.0)
      SetBlipColour               (blip, 4)
      SetBlipSprite               (blip, 369)
      SetBlipAsShortRange         (blip, true)
      SetBlipHighDetail           (blip, true)
      BeginTextCommandSetBlipName ("STRING")
      if v.owner and v.owner == self.PlayerData.identifier then
        AddTextComponentString("Owned House")
        SetBlipSprite(blip, 40)
      else
        AddTextComponentString("Empty House")
      end
      EndTextCommandSetBlipName   (blip)
      table.insert(self.Blips,blip)
    end
  end
end

function housing:Update(...)
  local isOwned,lastHouse,lastAct,onLast
  local text = "Press [~r~E~s~] to purchase this house."
  while true do
    Citizen.Wait(0)
    self.ClearLast,onLast = self:VehCheck(onLast)

    if self.ClearLast then
      lastHouse = false
      lastAct = false
      isOwned = false
      text = false
      self.ClearLast = false
    else
      if not self.CurHouse then
        local closest,closestDist,closestAct,closestPos = self:GetClosestAction()
        if closestDist and closestDist < self.DrawTextDist then
          if not lastHouse or not lastAct or lastHouse ~= closest.id or closestAct ~= lastAct then
            text,isOwned,lastAct,lastHouse,hasKeys = self:GetActionInfo(closest,closestAct)
          end
          ESX.Game.Utils.DrawText3D(closestPos, text, 0.7)
          if closestDist < self.InteractDist then
            self:InputHandler(closest,closestAct,isOwned,hasKeys)
          end
        else
          self.ClearLast = true
        end
      else
        if self.GiveKeysNow then
          self:GiveKeys(lastHouse,isOwned,self.GiveKeysNow)
          self.GiveKeysNow = false
        end

        if self.TakeKeysNow then
          self:TakeKeys(lastHouse,isOwned,self.TakeKeysNow)
          self.TakeKeysNow = false
        end

        if self.SetWardrobe then
          self:PlaceWardrobe(lastHouse,isOwned)
          self.SetWardrobe = false
        end

        local plyPos = GetEntityCoords(GetPlayerPed(-1))
        local pos = self.CurHouse.wardrobe
        local tryDoor = true
        if pos then
          local dist = Vdist(pos.x,pos.y,pos.z, plyPos.x,plyPos.y,plyPos.z)
          if dist and dist < (self.DrawTextDist/2) then
            ESX.Game.Utils.DrawText3D(pos, "Gardorabı açmak için [~r~E~s~] tuşunu kullan.", 0.7)
            if dist < self.InteractDist and IsControlJustPressed(0,38) then
              self:WardrobeMenu()
              tryDoor = false
            end
          end
        end
---YENİ SİSTEM BURADA BAŞLIYOR.----
        if tryDoor then
          local pos = self.CurHouse.exit
          local dist = Vdist(pos.x,pos.y,pos.z, plyPos.x,plyPos.y,plyPos.z)
          NetworkOverrideClockTime(23, 0, 0)
          if dist and dist < (self.DrawTextDist/2) then
            ESX.Game.Utils.DrawText3D(pos, "Çıkmak için [~r~E~s~], Davet için [~r~Z~s~] tuşunu kullan", 0.7)
            if dist < self.InteractDist and IsControlJustPressed(0, 38) then
              self:LeaveHouse()
            end
			if dist < self.InteractDist and IsControlJustPressed(0, 20) then

			local elements      = {}
			local playerPed = PlayerPedId()
			local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 2.0)
			-- player yok durumunu eklemeyi unutma.
			local players_clean = {}
			local found_players = false
			for i = 1, #players, 1 do
				--if players[i] ~= PlayerId() then
					found_players = true
					--table.insert(elements, { label = GetPlayerName(players[0]), id = GetPlayerServerId(players[0]) })
					table.insert(elements, { label = GetPlayerName(players[i]), id = GetPlayerServerId(players[i]) })
				--end
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'room_invite',
			{
				title    = 'Oyuncu',
				align    = 'top-right',
				elements = elements,
            }, function(data2, menu2)
			  local pPos = GetEntityCoords(GetPlayerPed(-1))
			  local tPos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(tonumber(tostring(data2.current.id)))))
			  if not tPos then ESX.ShowNotification("Could not find the target."); return; end
			  local dist = Vdist(pPos.x,pPos.y,pPos.z, tPos.x,tPos.y,tPos.z)
			  if dist and dist < 50.0 then
				playerhousing:InvitePlayer(tonumber(tostring(data2.current.id)))
			  else
				ESX.ShowNotification("Kapı yakınında değil.")
			  end


			end, function(data2, menu2)
				menu2.close()
			end)
            end
          end
        end
      end
    end
  end
end
---YENİ SİSTEM BURADA BİTİYOR.----
---DİSC İNVENTORY SİSTEMİNE GÖRE KASA EKLENTİSİ BURADA BAŞLIYOR.----
function housing:WardrobeMenu()
  local elements = {}
  elements[1] = {label = "Kıyafet Değiştir",val="Change"}
  elements[2] = {label = "Kıyafet Sil",val="Delete"}

 elements[3] = {label = "Depolama",val="Depolama"}

  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing', {
    title    = "Wardrobe",
    align    = 'top-left',
    elements = elements
  }, function(data, menu)
    ESX.TriggerServerCallback('playerhousing:GetPlayerDressing', function(d)
      local dressing = d
      if data.current.val == "Change" then
        local elements = {}
        for i=1, #dressing, 1 do
          table.insert(elements, {
            label = dressing[i],
            value = i
          })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'change_clothes', {
          title    = "Change Clothes",
          align    = 'top-left',
          elements = elements
        }, function(data2, menu2)
          TriggerEvent('skinchanger:getSkin', function(skin)
            ESX.TriggerServerCallback('playerhousing:GetPlayerOutfit', function(clothes)
              TriggerEvent('skinchanger:loadClothes', skin, clothes)
              TriggerEvent('esx_skin:setLastSkin', skin)

              TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('esx_skin:save', skin)
              end)
            end, data2.current.value)
          end)
        end, function(data2, menu2)
          menu2.close()
        end)
      elseif data.current.val == "Delete" then
        local elements = {}

        for i=1, #dressing, 1 do
          table.insert(elements, {
            label = dressing[i],
            value = i
          })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'remove_cloth', {
          title    = "Delete Outfit",
          align    = 'top-left',
          elements = elements
        }, function(data2, menu2)
          menu2.close()
          TriggerServerEvent('playerhousing:RemoveOutfit', data2.current.value)
          ESX.ShowNotification("Outfit deleted.")
        end, function(data2, menu2)
          menu2.close()
        end)

	 elseif data.current.val == "Depolama" then

        owner = ESX.GetPlayerData().identifier
        TriggerEvent('disc-inventoryhud:openInventory', {
        type = 'motel',
        owner = owner,
        slots = 80,
    })

     end


    end)
  end, function(data, menu)
    menu.close()
  end)
end
---DİSC İNVENTORY SİSTEMİNE GÖRE KASA EKLENTİSİ BURADA BİTİYOR.----

function OpenPropertyInventoryMenu(property, owner)
    ESX.TriggerServerCallback(
        "lsrp-motels:getPropertyInventory",
        function(inventory)
            TriggerEvent("disc-inventoryhud:openMotelInventory", inventory)
        end, owner)
end

function OpenPropertyInventoryMenuBed(property, owner)
	ESX.TriggerServerCallback(
		"lsrp-motels:getPropertyInventoryBed",
		function(inventory)
			TriggerEvent("disc-inventoryhud:openMotelsInventoryBed", inventory)
		end, owner)
end
---DİSC İNVENTORY SİSTEMİNE GÖRE KASA EKLENTİSİ BURADA BİTİYOR.----

function housing:VehCheck(onLast)
  local onVeh = IsPedInAnyVehicle(GetPlayerPed(-1),false)
  if onVeh and not onLast then
    self.ClearLast = true
    onLast = true
  elseif not onVeh and onLast then
    self.ClearLast = true
    onLast = false
  end
  return self.ClearLast,onLast
end

function housing:InputHandler(closest,closestAct,isOwned,hasKeys)
  if IsControlJustPressed(0, 38) then
    self:DoAction(closest,closestAct,isOwned,hasKeys)
  end
  if IsControlJustPressed(0, 58) then
    self:DoSecondary(closest,closestAct,isOwned,hasKeys)
  end
end

function housing:GetActionInfo(closest,closestAct)
  local text,isOwned,lastAct,lastHouse,hasKeys
  print(kapiacik)
  if closestAct == "Entry" then
    if closest.owner and closest.owner == self.PlayerData.identifier then
      text = "Eve girmek için [~r~E~s~] tuşunu kullan. \n Kapı Numarası :  [~r~"..closest.id.."~s~]"
      isOwned = true
    elseif closest.owner and closest.owner ~= self.PlayerData.identifier then
      text = "Kapıyı tıklatmak için  [~r~E~s~] tuşunu kullan.\n Kapı Numarası :  [~r~"..closest.id.."~s~]"
      isOwned = false
    else
      text = "[$~r~"..closest.Price.."~s~] Satın almak için [~r~E~s~] tuşunu kullan."
      isOwned = false
    end

    if closest.keys then
      text = "Eve girmek için [~r~E~s~] tuşunu kullan. \n Kapı Numarası :  [~r~"..closest.id.."~s~]"
      hasKeys = true
	end


  elseif closestAct == "Garage" then
    if closest.owner and closest.owner == self.PlayerData.identifier then
      if IsPedInAnyVehicle(GetPlayerPed(-1)) then
        text = "Press [~r~E~s~] to store your vehicle."
      else
        text = "Garajı açmak için [~r~E~s~] tuşunu kullan."
      end
      isOwned = true
    elseif closest.owner and closest.owner ~= self.PlayerData.identifier then
      text = "Press [~r~E~s~] to break into the garage."
      isOwned = false
    else
      text = ''
      isOwned = false
    end

    if closest.keys then
      if IsPedInAnyVehicle(GetPlayerPed(-1)) then
        text = "Press [~r~E~s~] to store the vehicle."
      else
        text = "Press [~r~E~s~] to access the garage."
      end
      hasKeys = true
    end
  else
    text = ''
    isOwned = ''
  end
  lastAct = closestAct
  lastHouse = closest.id
  return text,isOwned,lastAct,lastHouse,hasKeys
end

function housing:DoAction(closest,closestAct,isOwned,hasKeys)
  if closestAct == "Entry" then
    if isOwned or hasKeys then
      self:EnterHouse(closest.Entry,closest,isOwned)
    else
      if not closest.owner then
        self:BuyHouse(closest)
      else
        self:KnockOnDoor(closest)
      end
    end
  elseif closestAct == "Garage" and closest.owner then
    if hasKeys or closest.owner == self.PlayerData.identifier then
      local inCar = IsPedInAnyVehicle(GetPlayerPed(-1),false)
      if inCar then
        self:StoreCar(closest.id)
      else
        self:OpenGarageMenu(closest)
      end
    else
      self.ExpectingGarage = closest
      TriggerEvent('lockpicking:StartMinigame',(closest.Class and closest.Class == "Tier1House" and 5 or 3),'playerhousing:GarageBreakResult')
    end
  end
end

function housing:GarageBreak(res)
  if not self.ExpectingGarage then return false; end
  if res then
    self:OpenGarageMenu(self.ExpectingGarage)
    ESX.ShowNotification("You broke the lock!")
  else
    ESX.ShowNotification("~r~You triggered the alarm!")
    TriggerServerEvent('playerhousing:Alarm',GetEntityCoords(GetPlayerPed(-1)))
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 20.0, 'security-alarm', 1.0)
  end
  self.ExpectingGarage = nil
end

function housing:DoSecondary(closest,closestAct,isOwned,hasKeys)
  if closestAct == "Entry" then
    if not isOwned and not hasKeys then
      if closest.owner then
        self:BreakIn(closest)
      end
    end
  end
end

function housing:OpenGarageMenu(house)
  ESX.TriggerServerCallback('playerhousing:GetVehicles', function(vehicles)
    local elements = {}
    for k,v in pairs(vehicles) do
      local storedText = ''
      if (self.UsingJamGarage and v.state == 1) or (not self.UsingJamGarage and v.state == true) then
        storedText = '<span style="font-weight:bold;color:green;">Garage</span>'
      else
        storedText = '<span style="font-weight:bold;color:red;">Unknown</span>'
      end
      local name = GetDisplayNameFromVehicleModel(v.vehicle.model)
      table.insert(elements,{label = '<span style="font-weight:bold;">'..string.sub(name,1,1)..string.sub(name,2):lower()..'</span>'..storedText, val = v})
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), "Garage_Menu", { title = "Garage", align = 'right', elements = elements },
      function(data,menu)
        if (self.UsingJamGarage and data.current.val.state == 1) or (not self.UsingJamGarage and data.current.val.state == true) then
          self:SpawnCar(data.current.val.vehicle,house.Garage)
          menu.close()
        else
          ESX.ShowNotification("This vehicle isn't in the garage.")
        end
      end,
      function(data,menu)
        menu.close()
      end
    )
  end,house.id)
end

function housing:SpawnCar(vehicle,pos)
  ESX.Game.SpawnVehicle(vehicle.model,{x=pos.x,y=pos.y,z=pos.z + 1},pos.w,function(callback_vehicle)
    ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
    SetVehRadioStation(callback_vehicle, "OFF")

    TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)

    local vehicleId = GetVehiclePedIsUsing(GetPlayerPed(-1))
    SetEntityAsMissionEntity(GetVehicleAttachedToEntity(vehicleId), true, true)

    local vehicleProps = ESX.Game.GetVehicleProperties(callback_vehicle)
    SetModelAsNoLongerNeeded(GetHashKey(vehicle.model))
    self.ClearLast = true
    TriggerServerEvent('playerhousing:SetCarState',vehicleProps.plate,0,nil)
  end)
end

function housing:GetClosestAction()
  local pos = GetEntityCoords(GetPlayerPed(-1))
  local closest,closestDist,closestAct,closestPos
  for k,v in pairs(self.HouseData) do
    local entryDist = Vdist(v.Entry.x,v.Entry.y,v.Entry.z, pos.x,pos.y,pos.z)
    if not closestDist or entryDist < closestDist then
      closestDist = entryDist
      closest = v
      closestAct = "Entry"
      closestPos = v.Entry
    end

    if v.Garage then
      local garageDist = Vdist(v.Garage.x,v.Garage.y,v.Garage.z, pos.x,pos.y,pos.z)
      if not closestDist or garageDist < closestDist then
        closestDist = garageDist
        closest = v
        closestAct = "Garage"
        closestPos = v.Garage
      end
    end
  end
  if not closestDist then return false,999999,false,false
  else return closest,closestDist,closestAct,closestPos
  end
end

function TeleportToInterior(x,y,z,h,enter)
  local self = housing
  self:FadeScreen(false,500,true)

  if enter then
    TriggerEvent('vSync:toggle',false)
    SetBlackout(false)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypePersist('CLEAR')
    SetWeatherTypeNow('CLEAR')
    SetWeatherTypeNowPersist('CLEAR')
    NetworkOverrideClockTime(23, 0, 0)
  else
    TriggerEvent('vSync:toggle',true)
    TriggerServerEvent('vSync:requestSync')
  end

  FreezeEntityPosition(GetPlayerPed(-1),false)
  SetEntityCoords(PlayerPedId(), x, y, z, 0, 0, 0, false)
  SetEntityHeading(PlayerPedId(), h)

  Citizen.Wait(100)

  self:FadeScreen(true,1000,true)
end

function housing:EnterHouse(pos,house,isOwned,firstLogin)
  self.LastPos = pos

  print("ENTER HOUSE : FirstLogin = "..tostring(firstLogin))
  if firstLogin then
    print("ENTER HOUSE : FREEZE PLAYER")
    FreezeEntityPosition(GetPlayerPed(-1),true)
  end

  local pos = vector4(pos.x,pos.y,pos.z-20.0,pos.w)
  if house.Class == "Hotel" then
    self.CurHouse = CreateHotel(pos)
  elseif house.Class == "Tier1House" then
    self.CurHouse = CreateTier1House(pos)
  elseif house.Class == "Tier2House" then
    self.CurHouse = CreateTier2House(pos)
  elseif house.Class == "Tier3House" then
    self.CurHouse = CreateTier3House(pos)
  end
  self.CurHouse.wardrobe = (house.wardrobe or false)
  self.CurHouse.owner = house.owner
  if not self.CurHouse.wardrobe and self.PlayerData.identifier == house.owner then
    ESX.ShowNotification("Gardorabını ayarlamalısın!")
    ESX.ShowNotification("/setwardrobe komutunu kullan.")
  end
  TriggerEvent('playerhousing:Entered')
  TriggerServerEvent('playerhousing:Enter',house.id)
end

function housing:LeaveHouse(...)
  if not self.LastPos or not self.CurHouse then return; end
  local pos = self.LastPos
  TeleportToInterior(pos.x,pos.y,pos.z-1.0,pos.w)
  if self.CurHouse then
    self:DespawnInterior(self.CurHouse.objects)
  end
  self.LastPos = nil
  self.CurHouse = nil
  TriggerEvent('playerhousing:Leave')
  TriggerServerEvent('playerhousing:Leave')
end

function housing:GoToDoor(house)
  local p = house.Entry
  local plyPed = GetPlayerPed(-1)
  TaskGoStraightToCoord(plyPed, p.x, p.y, p.z, 10.0, 10, p.w, 0.5)
  local dist = 999
  local tick = 0
  while dist > 0.5 and tick < 10000 do
    local pPos = GetEntityCoords(plyPed)
    dist = Vdist(pPos.x,pPos.y,pPos.z, p.x,p.y,p.z)
    tick = tick + 1
    Citizen.Wait(100)
  end
  ClearPedTasksImmediately(plyPed)
end

RegisterCommand('geth', function(...)
  local closest,closestDist,closestAct,closestPos = housing:GetClosestAction()
  ESX.ShowNotification("[ ~r~"..closest.id.."~s~ ]")
end)

function housing:BreakIn(house)
  self.DoingLockpick = true

  self:GoToDoor(house)
  ESX.TriggerServerCallback('playerhousing:GetLockpicks', function(c)
    if c then
      local plyPed = GetPlayerPed(-1)
      while not HasAnimDictLoaded("mini@safe_cracking") do RequestAnimDict("mini@safe_cracking"); Citizen.Wait(0); end
      TaskPlayAnim(plyPed, "mini@safe_cracking", "idle_base", 8.0, 8.0, -1, 1, 0, 0, 0, 0 )
      Citizen.Wait(1000)

      self.LockpickingResult = false
      TriggerEvent('lockpicking:StartMinigame')
      while self.DoingLockpick do Citizen.Wait(0); end
      if self.LockpickingResult then
        self:EnterHouse(house.Entry, house)
      end
      self.LockpickingResult = false
    else
      self.DoingLockpick = false
      ESX.ShowNotification("You don't have any lockpicks.")
    end
  end)
end

function housing:KnockOnDoor(house)
  self:GoToDoor(house)
  local plyPed = GetPlayerPed(-1)
  while not HasAnimDictLoaded("timetable@jimmy@doorknock@") do RequestAnimDict("timetable@jimmy@doorknock@"); Citizen.Wait(0); end
  TaskPlayAnim(plyPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 8.0, 8.0, -1, 4, 0, 0, 0, 0 )
  Citizen.Wait(0)
  while IsEntityPlayingAnim(plyPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 3) do Citizen.Wait(0); end
  TriggerServerEvent('playerhousing:KnockOnDoor', house.owner)
  ESX.ShowNotification("Kapıyı çaldın.")
end

function housing:FadeScreen(fadeIn,time,wait)
  if not time then time = 500; end
  if fadeIn then DoScreenFadeIn(time)
  else DoScreenFadeOut(time); end
  if wait then
    if fadeIn then
      while not IsScreenFadedIn() do Citizen.Wait(0); end;
    else
      while not IsScreenFadedOut() do Citizen.Wait(0); end;
    end
  end
end

function housing:DespawnInterior(objects)
  for k, v in pairs(objects) do
    if DoesEntityExist(v) then
      DeleteEntity(v)
    end
  end
end

function getRotation(input)
    return 360 / (10 * input)
end

function housing:SyncHouse(data)
  self.HouseData[data.id] = data
end

function housing:InvitePlayer(id)
  print('Oyuncu geldi ! :'.. tostring(id))
  if not self.CurHouse or not self.LastPos then ESX.ShowNotification("Davet için evde olmalısın."); return; end
  if not id or tonumber(id[1]) <= 0 then ESX.ShowNotification("Davet için ID girmelisin."); return; end
  local pPos = GetEntityCoords(GetPlayerPed(-1))
  local tPos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(tonumber(id))))
  if not tPos then ESX.ShowNotification("Could not find the target."); return; end
  local dist = Vdist(pPos.x,pPos.y,pPos.z, tPos.x,tPos.y,tPos.z)
  if dist and dist < 50.0 then
    playerhousing:InviteInside(tonumber(id),self.LastPos)
  else
    ESX.ShowNotification("Kapı yakınında değil.")
  end

end
function housing:InviteInside(id, pos)
  if (id == GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1)))) then
    Citizen.CreateThread(function(...)
      local house = false
      for k,v in pairs(self.HouseData) do
        if v.Entry == pos then
          house = v
        end
      end
      ESX.ShowNotification("Daveti kabul etmek için [~r~H~s~] tuşuna bas.")
      local timer = GetGameTimer()
      while GetGameTimer() - timer < 10 * 1000 do
        if IsControlJustPressed(0,74) then
          self:EnterHouse(pos,house)
          return
        end
        Citizen.Wait(0)
      end
    end)
  end
end

function housing:LockpickFinished(result)
  if not self.DoingLockpick then return; end
  if not result then
    ESX.ShowNotification("You triggered the alarm!")
    TriggerServerEvent('playerhousing:Alarm',GetEntityCoords(GetPlayerPed(-1)))
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 20.0, 'security-alarm', 1.0)
  end

  self.LockpickingResult = result
  self.DoingLockpick = false
  ClearPedTasksImmediately(GetPlayerPed(-1))
end

function housing:StoreCar(house)
  local veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
  local props = ESX.Game.GetVehicleProperties(veh)
  local maxPassengers = GetVehicleMaxNumberOfPassengers(veh)

  if self.UsingJamGarage then
    ESX.TriggerServerCallback('JAG:StoreVehicle', function(valid)
      if(valid) then
        for seat = -1,maxPassengers-1,1 do
          local ped = GetPedInVehicleSeat(veh,seat)
          if ped and ped ~= 0 then TaskLeaveVehicle(ped,veh,16); end
        end
        SetEntityAsMissionEntity(veh,true,true)
        DeleteVehicle(veh)

        ESX.ShowNotification("Your vehicle has been stored.")
        TriggerServerEvent('playerhousing:SetCarState',props.plate,1,house)
      else
        ESX.ShowNotification("Your don't own this vehicle.")
      end
      self.ClearLast = true
    end, props)
  else
    ESX.TriggerServerCallback('esx_advancedgarage:storeVehicle', function(valid)
      if(valid) then
        for seat = -1,maxPassengers-1,1 do
          local ped = GetPedInVehicleSeat(veh,seat)
          if ped and ped ~= 0 then TaskLeaveVehicle(ped,veh,16); end
        end
        SetEntityAsMissionEntity(veh,true,true)
        DeleteVehicle(veh)

        ESX.ShowNotification("Your vehicle has been stored.")
        TriggerServerEvent('playerhousing:SetCarState',props.plate,1,house)
      else
        ESX.ShowNotification("Your don't own this vehicle.")
      end
      self.ClearLast = true
    end, props)
  end
end

function housing:BuyHouse(closest)
  local plyData = ESX.GetPlayerData()
  if (plyData.money and plyData.money >= closest.Price) or (plyData.accounts and plyData.accounts.bank and plyData.accounts.bank >= closest.Price) then
    TriggerServerEvent('playerhousing:BuyHouse',closest)
    self.ClearLast = true
    local timer = GetGameTimer()
    while GetGameTimer() - timer < 1 * 1000 do
      Citizen.Wait(0)
      ESX.Game.Utils.DrawText3D(closest.Entry, "You purchased this house!", 0.7)
      self:RefreshBlips()
    end
  else
    ESX.ShowNotification("You can't afford this house.")
  end
end

function housing:PlayerKnocked(player)
  if self.CurHouse and self.CurHouse.owner and self.CurHouse.owner == self.PlayerData.identifier then
    ESX.ShowNotification("Kapını çalıyor [ ID : "..tostring(player).." ] /n Çağırmak için [~r~G~s~] tuşuna basınız.")
  end
end

function housing:Alarm(pos)
  if not self.PlayerData then return; end
  if self.PlayerData.job.name == self.PoliceJobName then
    ESX.ShowNotification('A house is being robbed! [~g~LEFTCTRL~s~]')
    Citizen.CreateThread(function(...)
      local blipA = AddBlipForRadius(pos.x, pos.y, pos.z, 50.0)
      SetBlipHighDetail(blipA, true)
      SetBlipColour(blipA, 1)
      SetBlipAlpha (blipA, 128)

      local blipB = AddBlipForCoord(pos.x, pos.y, pos.z)
      SetBlipSprite               (blipB, 458)
      SetBlipDisplay              (blipB, 4)
      SetBlipScale                (blipB, 1.0)
      SetBlipColour               (blipB, 1)
      SetBlipAsShortRange         (blipB, true)
      SetBlipHighDetail           (blipB, true)
      BeginTextCommandSetBlipName ("STRING")
      AddTextComponentString      ("Robbery In Progress")
      EndTextCommandSetBlipName   (blipB)

      local timer = GetGameTimer()
      while GetGameTimer() - timer < 30000 do
        if IsControlJustPressed(0, 36) then
          SetNewWaypoint(pos.x,pos.y)
        end
        Citizen.Wait(0)
      end

      RemoveBlip(blipA)
      RemoveBlip(blipB)
    end)
  end
end

function housing:PlaceWardrobe(id,owner)
  if not self.CurHouse then
    ESX.ShowNotification("You must be inside a house.")
  else
    if owner then
      local pos = GetEntityCoords(GetPlayerPed(-1))
      local tPos = vector3(pos.x,pos.y,pos.z+0.3)
      self.CurHouse.wardrobe = tPos
      ESX.ShowNotification("You set the wardrobe position.")
      ESX.ShowNotification("Add furniture to your house by using the /furni command.")
      TriggerServerEvent('playerhousing:SetWardrobe',id,tPos)
    else
      ESX.ShowNotification("You don't own this house.")
    end
  end
end

function housing:GiveKeys(id,owner,target)
  if not self.CurHouse or not owner then return; end
  ESX.ShowNotification("You gave the keys to the player.")
  TriggerServerEvent('playerhousing:GiveKeys', target, id)
end

function housing:GotKey(id)
  ESX.ShowNotification("Somebody just gave you a set keys to their house.")
  self.HouseData[id].keys = true
  self.ClearLast = true
end

function housing:TakeKeys(id,owner,target)
  if not self.CurHouse or not owner then return; end
  ESX.ShowNotification("You took the keys from the player.")
  TriggerServerEvent('playerhousing:TakeKeys', target, id)
end

function housing:TookKey(id)
  ESX.ShowNotification("Somebody just revoked a key to their house.")
  self.HouseData[id].keys = nil
  self.ClearLast = true
end

function housing:KapilarAcik()
  ESX.ShowNotification("Kapiları Açtın.")
  kapiacik = "1"
end
function housing:KapilarKapali()
  ESX.ShowNotification("Kapıları Kilitledin.")
  kapiacik = "0"
end

RegisterNetEvent('playerhousing:SyncHouse')
AddEventHandler('playerhousing:SyncHouse', function(...) housing:SyncHouse(...); end)

RegisterNetEvent('playerhousing:GiveKey')
AddEventHandler('playerhousing:GiveKey', function(...) housing:GotKey(...); end)

RegisterNetEvent('playerhousing:TakeKey')
AddEventHandler('playerhousing:TakeKey', function(...) housing:TookKey(...); end)

RegisterNetEvent('playerhousing:Alarm')
AddEventHandler('playerhousing:Alarm', function(...) housing:Alarm(...); end)

RegisterNetEvent('playerhousing:InviteInside')
AddEventHandler('playerhousing:InviteInside', function(...) housing:InviteInside(...); end)

RegisterNetEvent('playerhousing:PlayerKnocked')
AddEventHandler('playerhousing:PlayerKnocked', function(...) housing:PlayerKnocked(...); end)

RegisterNetEvent('lockpicking:MinigameComplete')
AddEventHandler('lockpicking:MinigameComplete', function(...) housing:LockpickFinished(...); end)

RegisterNetEvent('playerhousing:Respond')
AddEventHandler('playerhousing:Respond', function(...) housing:Respond(...); end)
AddEventHandler('playerhousing:GarageBreakResult', function(...) housing:GarageBreak(...); end)



RegisterCommand('davet', function(source,id) housing:InvitePlayer(id); end)
RegisterCommand('ayarla', function(...) housing.SetWardrobe = true; end)
RegisterCommand('anahtarver', function(...) housing.DoGiveKeys = true; end)
RegisterCommand('anahtaral', function(...) housing.DoTakeKeys = true; end)
RegisterCommand('kilitac', function(...) housing.KapilarAcik = true; end)
RegisterCommand('kilitle', function(...) housing.KapilarKapali = true; end)

Citizen.CreateThread(function(...) housing:Awake(...); end)

function housing:KeyThread(...)
  local allPlayers = false
  local selectedPlayer = false
  local instructions = CreateInstuctionScaleform("instructional_buttons")
  while true do
    if self.CurHouse and self.CurHouse.owner and self.CurHouse.owner == self.PlayerData.identifier and (self.DoGiveKeys or self.DoTakeKeys) then
      if not allPlayers then
        allPlayers = ESX.Game.GetPlayersInArea(GetEntityCoords(GetPlayerPed(-1)), 20.0)
      else
        if not selectedPlayer then selectedPlayer = 1; end
        local pos = GetEntityCoords(GetPlayerPed(allPlayers[selectedPlayer]))
        local r = 0
        local g = 0
        if self.DoGiveKeys then
          g = 255
        else
          r = 255
        end

        if IsControlJustPressed(0, 174) then
          selectedPlayer = selectedPlayer + 1
          if selectedPlayer > #allPlayers then
            selectedPlayer = 1
          end
        end

        if IsControlJustPressed(0, 175) then
          selectedPlayer = selectedPlayer - 1
          if selectedPlayer < 1 then
            selectedPlayer = #allPlayers
          end
        end

        if IsControlJustPressed(0, 200) then
          self.DoGiveKeys = false
          self.DoTakeKeys = false
          allPlayers = false
          selectedPlayer = false
        end

        if IsControlJustPressed(0, 191) then
            print(allPlayers[selectedPlayer],PlayerId())
          if allPlayers[selectedPlayer] == PlayerId() then
            print(allPlayers[selectedPlayer],PlayerId())
          elseif self.DoTakeKeys then
            self.TakeKeysNow = GetPlayerServerId(allPlayers[selectedPlayer])
          else
            self.GiveKeysNow = GetPlayerServerId(allPlayers[selectedPlayer])
          end

          self.DoGiveKeys = false
          self.DoTakeKeys = false
          allPlayers = false
          selectedPlayer = false
        end

        DrawMarker(0, pos.x,pos.y,pos.z + 1.2, 0.0,0.0,0.0, 0.0,0.0,0.0, 0.2,0.2,0.2, r,g,0,255, true, true, 2, false,false,false,false)
        DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
      end
    else
      self.DoGiveKeys = false
      self.DoTakeKeys = false
      allPlayers = false
      selectedPlayer = false
      Citizen.Wait(1000)
    end
    Citizen.Wait(0)
  end
end

function CreateInstuctionScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    InstructionButton(GetControlInstructionalButton(1, 174, true))
    InstructionButtonMessage("Player-")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    InstructionButton(GetControlInstructionalButton(1, 175, true))
    InstructionButtonMessage("Player+")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    InstructionButton(GetControlInstructionalButton(1, 191, true))
    InstructionButtonMessage("Select")
    PopScaleformMovieFunctionVoid()


    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    InstructionButton(GetControlInstructionalButton(1, 200, true))
    InstructionButtonMessage("Cancel")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function InstructionButton(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

Citizen.CreateThread(function(...) housing:KeyThread(...); end)
