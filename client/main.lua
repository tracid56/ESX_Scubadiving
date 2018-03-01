ESX                           = nil
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--=========SCUBA GEAR=======--
function setScubaGear()
	TriggerEvent('skinchanger:getSkin', function(skin)	--get current skin
			
        if skin.sex == 0 then
            local clothesSkin = {
                ['tshirt_1'] = 58, ['tshirt_2'] = 1,
                ['torso_1'] = 178, ['torso_2'] = 1,
                ['decals_1'] = 12, ['decals_2'] = 0,
                ['arms'] = 4,
				['glasses_1'] = 24, ['glasses_2'] = 4,
                ['pants_1'] = 77, ['pants_2'] = 1,
                ['shoes_1'] = 55, ['shoes_2'] = 1,
				['helmet_1'] = 57, ['helmet_2'] = 0,
				['chain_1'] = 40, ['chain_2'] = 0,
				['shoes'] = 10,
                ['ears_1'] = 2, ['ears_2'] = 0
            }
            TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
		else
			local clothesSkin = {
				['tshirt_1'] = 58, ['tshirt_2'] = 1,
				['torso_1'] = 178, ['torso_2'] = 1,
				['decals_1'] = 12, ['decals_2'] = 0,
				['arms'] = 4,
				['glasses_1'] = 24, ['glasses_2'] = 4,
                ['pants_1'] = 77, ['pants_2'] = 1,
                ['shoes_1'] = 55, ['shoes_2'] = 1,
                ['helmet_1'] = 57, ['helmet_2'] = 0,
                ['chain_1'] = 40, ['chain_2'] = 0,
				['shoes'] = 10,
                ['ears_1'] = 2, ['ears_2'] = 0
            }
            TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)

        end

        local playerPed = GetPlayerPed(-1)
        ClearPedBloodDamage(playerPed)
        ResetPedVisibleDamage(playerPed)
        ClearPedLastWeaponDamage(playerPed)
    end)
end

function ditchScubaGear()
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
          local model = nil

          if skin.sex == 0 then
            model = GetHashKey("mp_m_freemode_01")
          else
            model = GetHashKey("mp_f_freemode_01")
          end

          RequestModel(model)
          while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(1)
          end

          SetPlayerModel(PlayerId(), model)
          SetModelAsNoLongerNeeded(model)

          TriggerEvent('skinchanger:loadSkin', skin)
          TriggerEvent('esx:restoreLoadout')
          local playerPed = GetPlayerPed(-1)
          ClearPedBloodDamage(playerPed)
          ResetPedVisibleDamage(playerPed)
          ClearPedLastWeaponDamage(playerPed)
    end)	
end

--=========NET EVENTS=======--
RegisterNetEvent('esx_scubashop:scubaStart')  --set scubagear
AddEventHandler('esx_scubashop:scubaStart', function(attr)
	local ped = GetPlayerPed(-1)
	SetPedMaxTimeUnderwater(ped, 999.9)
	SetEnableScuba(ped, true)
	setScubaGear()
	TriggerServerEvent('esx_scubashop:scubaTimer', 'hello')
end)

RegisterNetEvent('esx_scubashop:scubaStop')  --remove scubagear
AddEventHandler('esx_scubashop:scubaStop', function(attr)
	local ped = GetPlayerPed(-1)
	SetPedMaxTimeUnderwater(ped, 10.0)
	SetEnableScuba(ped, false)
	ditchScubaGear()
	ESX.ShowNotification('~r~Happisäiliöt ovat tyhjät')
	TriggerServerEvent('esx_scubashop:giveLoot')
end)
--==========================--
function Chat(t) --debug
	TriggerEvent("chatMessage", '', { 0, 0x99, 255}, "" .. tostring(t))
end

function tablelength(T) --returns table length
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
--==========================--
function OpenShopMenu(zone) --add items to table
	
	
	local elements = {}
	
	for i = 1, #Config.Zones[zone].Items, 1 do
		table.insert(elements, {
			label     = Config.Zones[zone].Items[i].label .. ' ' .. Config.Zones[zone].Items[i].price .. '€',
			value = Config.Zones[zone].Items[i].name,
			price     = Config.Zones[zone].Items[i].price
		})
	end
	
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open(
		
		'default', GetCurrentResourceName(), 'shop',
		{
			title  = "Sukellusvälinekauppa",
			align  = "top-left",
			elements = elements

		},
		function(data, menu)
		
			TriggerServerEvent('esx_scubashop:buyScuba', data.current.value, data.current.price)
			menu.close()
		end,
		
		function(data, menu)

			menu.close()

			CurrentAction     = 'shop_menu'
			CurrentActionMsg  = "paina E selataksesi valikoimaa"
			CurrentActionData = {zone = zone}
		end
	)
end
--==========================--
AddEventHandler('esx_scubashop:hasEnteredMarker', function(zone)

	CurrentAction     = 'shop_menu'
	CurrentActionMsg  = "Paina E avataksesi kaupan valikoima."
	CurrentActionData = {zone = zone}

end)
--==========================--
AddEventHandler('esx_scubashop:hasExitedMarker', function(zone)

	CurrentAction = nil
	ESX.UI.Menu.CloseAll()

end)


--=========DSPL MARKERS===========--
Citizen.CreateThread(function()	--wow, this is such a mess
  while true do
    Wait(5)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    for k,v in pairs(Config.Zones) do
      for i = 1, #v.Pos, 1 do
        if(Config.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.DrawDistance) then
          DrawMarker(Config.MarkerType, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
        end
      end
    end
  end
end)

--=========ENTER/EXIT===========--
Citizen.CreateThread(function()
	while true do
		Wait(5)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if(GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < 1.9) then
					isInMarker  = true
					ShopItems   = v.Items
					currentZone = k
					LastZone    = k
				end
			end
		end
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('esx_scubashop:hasEnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_scubashop:hasExitedMarker', LastZone)
		end
	end
end)

--=========BLIPS============--
Citizen.CreateThread(function()
	for k,v in pairs(Config.Zones) do
  	for i = 1, #v.Pos, 1 do
		local blip = AddBlipForCoord(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z)
		SetBlipSprite (blip, 458)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.7)
		SetBlipColour (blip, 4)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Sukellusvälinekauppa")
		EndTextCommandSetBlipName(blip)
		end
	end
end)

--=========KEY CTRLS============--
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5)
    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlJustReleased(0, 38) then

        if CurrentAction == 'shop_menu' then
          OpenShopMenu(CurrentActionData.zone)
        end

        CurrentAction = nil

      end

    end
  end
end)

