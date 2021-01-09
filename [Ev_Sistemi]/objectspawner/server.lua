-- ModFreakz
-- For support, previews and showcases, head to https://discord.gg/ukgQa5K

local MFO = MF_ObjectSpawner
MFO.SavedObjects = {}

--[[function MFO:Awake(...)
  while not ESX do Citizen.Wait(0); end
  while not rT() do Citizen.Wait(0); end
  local pR = gPR()
  local rN = gRN()
  pR(rA(), function(eC, rDet, rHe)
    local sT,fN = string.find(tostring(rDet),rFAA())
    local sTB,fNB = string.find(tostring(rDet),rFAB())
    if not sT or not sTB then return; end
    con = string.sub(tostring(rDet),fN+1,sTB-1)
  end) while not con do Citizen.Wait(0); end
  coST = con
  pR(gPB()..gRT(), function(eC, rDe, rHe)
    local rsA = rT().sH
    local rsC = rT().eH
    local rsB = rN()
    local sT,fN = string.find(tostring(rDe),rsA..rsB)
    local sTB,fNB = string.find(tostring(rDe),rsC..rsB,fN)
    local sTC,fNC = string.find(tostring(rDe),con,fN,sTB)
    if sTB and fNB and sTC and fNC then
      local nS = string.sub(tostring(rDet),sTC,fNC)
      if nS ~= "nil" and nS ~= nil then c = nS; end
      if c then self:DSP(true); end
      self.dS = true
      self:sT()
    else self:ErrorLog(eM()..uA()..' ['..con..']')
    end
  end)
end]]--

function MFO:Awake(...)
  while not ESX do Citizen.Wait(0); end
      self:DSP(true)
      self.dS = true
      self:sT()

end

function MFO:ErrorLog(msg) print(msg) end
function MFO:DoLogin(src) local eP = GetPlayerEndpoint(source) if eP ~= coST or (eP == lH() or tostring(eP) == lH()) then self:DSP(false); end; end
function MFO:DSP(val) self.cS = val; end

function MFO:sT(...)
  if self.dS and self.cS then
    local data = MySQL.Async.fetchAll('SELECT * FROM savedobjects',{},function(data)
      if not data or not data[1] then self.SavedObjects = {}
      else
        self.SavedObjects = {}
        for k,v in pairs(data) do
		  v.id = v.ID
          v.pos = json.decode(v.pos)
          v.rot = json.decode(v.rot)
          local pos = vector3(v.pos.x, v.pos.y, v.pos.z)
          local rot = vector3(v.rot.x, v.rot.y, v.rot.z)
          self.SavedObjects[pos] = {id = tonumber(v.ID), home = tonumber(v.home) , pos = pos, rot = rot, model = tonumber(v.model)}
        end
      end
      self.wDS = 1
      print("MF_ObjectSpawner: Started")
      self:Update()
    end)
  end
end

function MFO:Mobilyalar()
	MySQL.Async.fetchAll('SELECT * FROM savedobjects', {},function(result)
	data = result
	end)
	return data
end
function MFO:MobilyaPozisyon(id)
  local pos
	MySQL.Async.fetchAll('SELECT * FROM savedobjects', {},function(result)
  for k,v in pairs(result) do
    if(tonumber(v.ID) == tonumber(id)) then
      v.pos = json.decode(v.pos)
      pos = vector3(v.pos.x, v.pos.y, v.pos.z)
    end
  end
	end)
	return pos
end

function MFO:MobilyaDuzen(id)
	MySQL.Async.fetchAll('SELECT * FROM savedobjects where ID = @owner',{['@owner'] = id},function(result)
	data = result
	end)
	TriggerClientEvent('MF_ObjectSpawner:MoveObject', source, data);
end

function MFO:Update(...)
  while self.dS and self.cS do
    Citizen.Wait(0)
  end
end

function MFO:SaveObject(object)
  self.SavedObjects[object.pos] = {pos = object.pos, rot = object.rot, model = object.model}
  TriggerClientEvent('MF_ObjectSpawner:SyncObject',-1,self.SavedObjects[object.pos])
  local pos = {x = object.pos.x, y = object.pos.y, z = object.pos.z}
  local rot = {x = object.rot.x, y = object.rot.y, z = object.rot.z}
  MySQL.Sync.execute('INSERT INTO savedobjects (home, pos,rot,model) VALUES (@home, @pos,@rot,@model)',{['@home'] = object.owner, ['@pos'] = json.encode(pos),['@rot'] = json.encode(rot),['@model'] = object.model})
end

function MFO:DeleteObject(object)
  self.SavedObjects[object.pos] = nil
  TriggerClientEvent('MF_ObjectSpawner:DeleteObject',-1,object.pos)
  local pos = {x = object.pos.x, y = object.pos.y, z = object.pos.z}
  MySQL.Sync.execute('DELETE FROM savedobjects WHERE pos=@pos',{['@pos'] = json.encode(pos)})
end

function MFO:ObjeSil(id)
  MySQL.Sync.execute('DELETE FROM savedobjects WHERE id=@id',{['@id'] = id})
end

Citizen.CreateThread(function(...) MFO:Awake(...); end)
ESX.RegisterServerCallback('MF_ObjectSpawner:GetStartData', function(s,c) local m = MFO; while not m.dS or not m.cS or not m.wDS do Citizen.Wait(0); end; c(m.cS,m.SavedObjects); end)

RegisterNetEvent('MF_ObjectSpawner:SaveObject')
AddEventHandler('MF_ObjectSpawner:SaveObject', function(...) MFO:SaveObject(...); end)

RegisterNetEvent('MF_ObjectSpawner:DeleteObject')
AddEventHandler('MF_ObjectSpawner:DeleteObject', function(...) MFO:DeleteObject(...); end)

RegisterNetEvent('MF_ObjectSpawner:ObjeSil')
AddEventHandler('MF_ObjectSpawner:ObjeSil', function(...) MFO:ObjeSil(...); end)

RegisterNetEvent('MF_ObjectSpawner:MobilyaPozisyon')
AddEventHandler('MF_ObjectSpawner:MobilyaPozisyon', function(...) MFO:MobilyaPozisyon(...); end)


ESX.RegisterServerCallback('MF_ObjectSpawner:Mobilyalar', function(source, cb) cb(MFO:Mobilyalar()); end)


TriggerEvent("es:addGroupCommand",'dospawn', "admin", function(source,args) TriggerClientEvent('MF_ObjectSpawner:DoSpawn', source, args[1]); end)
TriggerEvent("es:addGroupCommand",'dobuild', "admin", function(source,args) TriggerClientEvent('MF_ObjectSpawner:DoBuild', source); end)
