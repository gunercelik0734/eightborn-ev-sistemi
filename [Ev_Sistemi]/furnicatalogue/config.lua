furnicatalogue = {}

furnicatalogue.Version = '1.0.11'

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj; end)
Citizen.CreateThread(function(...) while not ESX do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj; end); Citizen.Wait(0); end; end)