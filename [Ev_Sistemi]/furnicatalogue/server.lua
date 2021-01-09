local priceS
function furnicatalogue:TryBuy(source,price)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do xPlayer = ESX.GetPlayerFromId(source); Citizen.Wait(0); end
  local money = xPlayer.getMoney()
  if money >= price then
    xPlayer.removeMoney(price)
    priceS = price
    return true
  else
    return false
  end
end

function furnicatalogue:Iade(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  while not xPlayer do xPlayer = ESX.GetPlayerFromId(source); Citizen.Wait(0); end
  local money = xPlayer.getMoney()
  xPlayer.addMoney(priceS)
  return true
end

RegisterNetEvent('furnicatalogue:Start')
AddEventHandler('furnicatalogue:Start', function(...) TriggerEvent('furnicatalogue:Request', source); end)
ESX.RegisterServerCallback('furnicatalogue:TryBuy', function(source,cb,price) cb(furnicatalogue:TryBuy(source,price)); end)
ESX.RegisterServerCallback('furnicatalogue:Iade', function(source,cb) cb(furnicatalogue:Iade(source)); end)
