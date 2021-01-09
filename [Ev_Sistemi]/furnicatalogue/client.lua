function furnicatalogue:Awake(...)
  while not ESX do Citizen.Wait(0); end
  while not ESX.IsPlayerLoaded() do Citizen.Wait(0); end
  self.PlayerData = ESX.GetPlayerData()
  self:Update()
end

function furnicatalogue:Update(...)
  while true do
    if self.Open then
      DisableAllControlActions(0)
    end
    Citizen.Wait(0)
  end
end

function furnicatalogue:OpenCatalogue(...)
  if (not self.Instance and not self.InHouse) then
    ESX.ShowNotification("Evde olmalısın.")
    return
  end

  self.Open = not self.Open
  SendNUIMessage({
    type = 'openUI',
    enable = self.Open,
    shopData = self.ShopItems,
  })
  SetNuiFocus(self.Open,self.Open)
end

function furnicatalogue:PostData(data)
  local st,fn = string.find(data,"<br>")
  local newString = string.sub(data,1,st-1)
  if self.ItemLookup[newString] then
    ESX.TriggerServerCallback('furnicatalogue:TryBuy', function(canBuy)
      if canBuy then
        TriggerEvent('MF_ObjectSpawner:DoSpawn',self.ItemLookup[newString])
        self:OpenCatalogue();
      else
        ESX.ShowNotification("Üzerinde yeteri kadar para yok!")
      end
    end,tonumber(string.sub(data,fn+9)))
  end
end


RegisterNetEvent('instance:onEnter')
AddEventHandler('instance:onEnter', function(...) furnicatalogue.Instance = true; end)

RegisterNetEvent('instance:onLeave')
AddEventHandler('instance:onLeave', function(...) furnicatalogue.Instance = false; end)

RegisterNetEvent('playerhousing:Entered')
AddEventHandler('playerhousing:Entered', function(...) furnicatalogue.InHouse = true; end)

RegisterNetEvent('playerhousing:Leave')
AddEventHandler('playerhousing:Leave', function(...) furnicatalogue.InHouse = false; end)

RegisterNUICallback('escape', function(data, cb) furnicatalogue:OpenCatalogue(); cb(true); end)
RegisterNUICallback('dopost', function(data, cb) furnicatalogue:PostData(data); cb(true); end)

RegisterCommand('mobilya', function(...) furnicatalogue:OpenCatalogue(...); end)

Citizen.CreateThread(function(...) furnicatalogue:Awake(...); end)
