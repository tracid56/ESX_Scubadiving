ESX               = nil
local ItemsLabels = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_scubashop:buyScuba')
AddEventHandler('esx_scubashop:buyScuba', function(itemName, price)
	
	local xPlayer  = ESX.GetPlayerFromId(source)

	if xPlayer.get('money') >= price then
		xPlayer.removeMoney(price)
		xPlayer.addInventoryItem(itemName, 1)
		TriggerClientEvent('esx:showNotification', source, "Ostotapahtuma vahvistettu!" )
	else
		TriggerClientEvent('esx:showNotification', source, "Sinulla ei ole tarpeeksi rahaa. ~r~Mene töihin!")
	end

end)

--=====USED SCUBA GEAR======--
RegisterServerEvent('esx_scubashop:giveLoot')
AddEventHandler('esx_scubashop:giveLoot', function(itemName, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addInventoryItem("usedscuba", 1)
end)

--=====SCUBA TIMER======--
RegisterServerEvent('esx_scubashop:scubaTimer')
AddEventHandler('esx_scubashop:scubaTimer', function(data)
	local _source = source
	local timeout = 480000		--time until player runs out of oxygen
	TriggerClientEvent('esx:showNotification', _source, '~w~Sinulla on happea noin kahdeksaksi minuutiksi..')
	SetTimeout(timeout, function()
		TriggerClientEvent('esx_scubashop:scubaStop', _source)
	end)
	SetTimeout(timeout - 60000, function()
		TriggerClientEvent('esx:showNotification', _source, '~w~Happea jäljellä noin ~r~minuutiksi..')
	end)
end)
--===REGISTER AS USABLE==--
ESX.RegisterUsableItem('scuba', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('scuba', 1)

	TriggerClientEvent(('esx_scubashop:scubaStart'), source, "useful data")

end)







