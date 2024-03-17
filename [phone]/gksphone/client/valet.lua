--================================================================================================
--==            --    XenKnighT --        https://discord.gg/XUck63E                            ==
--================================================================================================

local fizzPed = nil
local carBlip = nil
local wait = false
local inVehicle = false

RegisterNUICallback('getCarsValetGKS', function(data, cb)
	if not wait then
		local plate = data.plate
		wait =  true

		if data.hash == nil then
			TriggerEvent('gksphone:notifi', {title = _U('vale_title'), message = _U('vale_notclass'), img= '/html/static/img/icons/vale.png' })
			wait = false
			return
		end
		local modelHash = tonumber(data.hash)
		local ClassNumber =  GetVehicleClassFromName(modelHash)
		if ClassNumber == 14 or ClassNumber == 15 or ClassNumber == 16 then
			TriggerEvent('gksphone:notifi', {title = _U('vale_title'), message = _U('vale_notclass'), img= '/html/static/img/icons/vale.png' })
			wait = false
			return
		end

		local vehicles = GetGamePool("CVehicle")
		for _, vehicle in pairs(vehicles) do
			local carplate = GetVehicleNumberPlateText(vehicle)
			if Config.Core.Shared.Trim(carplate) == Config.Core.Shared.Trim(data.plate) then
                local vehicleCoords = GetEntityCoords(vehicle)
                SetNewWaypoint(vehicleCoords.x, vehicleCoords.y)
				TriggerEvent('gksphone:notifi', {title = _U('vale_title'), message = _U('vale_getr'), img= '/html/static/img/icons/vale.png' })
				wait = false
				return
			end
		end
		Config.Core.Functions.TriggerCallback('gksphone:loadVehicle', function(hash, coords)
			if hash ~= false then
				if hash == "nomoney" then
					TriggerEvent('gksphone:notifi', {title = _U('vale_title'), message = _U('vale_checmoney'), img= '/html/static/img/icons/vale.png' })
					wait = false
				else
					TriggerServerEvent("gksphone:valet-car-set-outside", data.plate, hash.garage)
					SpawnVehicle(hash, data.plate)
				end
			else
				if coords then
					SetNewWaypoint(coords.x, coords.y)
					TriggerEvent('gksphone:notifi', {title = _U('vale_title'), message = _U('vale_getr'), img= '/html/static/img/icons/vale.png' })
				else
					TriggerEvent('gksphone:notifi', {title = _U('vale_title'), message = _U('vale_notcoming'), img= '/html/static/img/icons/vale.png' })
				end
				wait = false
			end

		end,plate)
	else
		TriggerEvent('gksphone:notifi', {title = _U('vale_title'), message = _U('vale_coming'), img= '/html/static/img/icons/vale.png' })
	end
	cb('ok')
end)


function SpawnVehicle(vehicle, plate)
	if	Config.ValeNPC  then
		local coords = GetEntityCoords(PlayerPedId())
		local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-Config.ValespawnRadius, Config.ValespawnRadius), coords.y + math.random(-Config.ValespawnRadius, Config.ValespawnRadius), coords.z, 0, 3, 0)
		local coordinates = {x=spawnPos.x,y=spawnPos.y,z=spawnPos.z, spawnHeading}
		local driverhash = 999748158
		local modelHash = tonumber(vehicle.hash)
		modelHash = (type(modelHash) == 'number' and modelHash or joaat(modelHash))


		if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
			RequestModel(modelHash)

			while not HasModelLoaded(modelHash) do
				Wait(500)
			end
		end

		Wait(500)



		TriggerEvent('gksphone:notifi', {title = _U('vale_title'), message = _U('vale_spawntime'), img= '/html/static/img/icons/vale.png' })
		Config.Core.Functions.SpawnVehicle(modelHash,  function(callback_vehicle)
			Config.Core.Functions.TriggerCallback('gksphone:GetVehicleProperties', function(properties)
				Config.Core.Functions.SetVehicleProperties(callback_vehicle, properties)
				SetVehicleHasBeenOwnedByPlayer(callback_vehicle, true)
				SetVehRadioStation(callback_vehicle, "OFF")
				DoCarDamage(callback_vehicle, vehicle)

				while not HasModelLoaded(driverhash) do
					RequestModel(driverhash)
					Wait(500)
				end

				fizzPed = CreatePedInsideVehicle(callback_vehicle, 4, driverhash, -1, true, false)
				SetVehicleNumberPlateText(callback_vehicle, plate)
				SetEntityAsMissionEntity(callback_vehicle, true, true)
				ClearAreaOfVehicles(GetEntityCoords(callback_vehicle), 5000, false, false, false, false, false);
				SetVehicleOnGroundProperly(callback_vehicle)
				SetVehicleEngineOn(callback_vehicle,true)

				carBlip = AddBlipForEntity(callback_vehicle)
				SetBlipSprite(carBlip, 225)                                                      	--Blip Spawning.
				SetBlipFlashes(carBlip, true)
				SetBlipColour(carBlip, 0)
				SetBlipFlashes(carBlip, false)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(plate)
				EndTextCommandSetBlipName(carBlip)

				inVehicle = true
				GiveKeyCar(callback_vehicle, vehicle)
				TaskVehicle(callback_vehicle, modelHash)
			end, plate)
		end, coordinates)

	else

		local coords = GetEntityCoords(PlayerPedId())
		local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-30, 30), coords.y + math.random(-30, 30), coords.z, 0, 3, 0)
		local coordinates = {x=spawnPos.x,y=spawnPos.y,z=spawnPos.z, spawnHeading}
		local modelHash = tonumber(vehicle.hash)

		modelHash = (type(modelHash) == 'number' and modelHash or joaat(modelHash))

		if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
			RequestModel(modelHash)
			while not HasModelLoaded(modelHash)  do
				Wait(0)
			end
		end

		Wait(500)

		TriggerEvent('gksphone:notifi', {title = _U('vale_title'), message = _U('vale_spawntime'), img= '/html/static/img/icons/vale.png' })
		Config.Core.Functions.SpawnVehicle(modelHash,  function(callback_vehicle)
			Config.Core.Functions.TriggerCallback('gksphone:GetVehicleProperties', function(properties)
				Config.Core.Functions.SetVehicleProperties(callback_vehicle, properties)
				SetVehicleHasBeenOwnedByPlayer(callback_vehicle, true)
				SetVehRadioStation(callback_vehicle, "OFF")
				DoCarDamage(callback_vehicle, vehicle)
				SetVehicleNumberPlateText(callback_vehicle, plate)
				SetEntityAsMissionEntity(callback_vehicle, true, true)
				ClearAreaOfVehicles(GetEntityCoords(callback_vehicle), 5000, false, false, false, false, false);
				SetVehicleOnGroundProperly(callback_vehicle)
				SetVehicleEngineOn(callback_vehicle,true)

				carBlip = AddBlipForEntity(callback_vehicle)
				SetBlipSprite(carBlip, 225)                                                      	--Blip Spawning.
				SetBlipFlashes(carBlip, true)
				SetBlipColour(carBlip, 0)
				SetBlipFlashes(carBlip, false)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(plate)
				EndTextCommandSetBlipName(carBlip)
				GiveKeyCar(callback_vehicle, vehicle)

				Citizen.Wait(10000)
				RemoveBlip(carBlip)
				carBlip = nil
				wait = false

			end, plate)
		end, coordinates)

	end

end

function TaskVehicle(vehicle, vehhash)
	Citizen.Wait(750)
	local plycoords = GetEntityCoords(PlayerPedId())

	TaskVehicleDriveToCoord(fizzPed, vehicle, plycoords.x, plycoords.y, plycoords.z, 20.0, 0, model, 786603, 1.0, 1)

	while #(GetEntityCoords(fizzPed) - GetEntityCoords(PlayerPedId())) > 7.5 do
		Wait(1000)
	end

	LeaveIt(vehicle)
end

function LeaveIt(vehicle)
	TaskLeaveVehicle(fizzPed, vehicle, 14)
	inVehicle = false
	while IsPedInAnyVehicle(fizzPed, false) do
		Citizen.Wait(0)
	end

	Citizen.Wait(500)
	TaskWanderStandard(fizzPed, 10.0, 10)
	Citizen.Wait(10000)
	DeleteEntity(fizzPed)
	RemoveBlip(carBlip)
	carBlip = nil
	fizzPed = nil
	wait = false
end


function DoCarDamage(currentVehicle, veh)
	local engine = veh.engine + 0.0
	local body = veh.body + 0.0
	if Config.cdGarages and veh.mods then
		local mods = json.decode(veh.mods)
		if mods.bodyHealth then engine = mods.bodyHealth+0.0 end
		if mods.engineHealth then body = mods.engineHealth+0.0 end
	end
    Wait(100)

        if body < 900.0 then
            SmashVehicleWindow(currentVehicle, 0)
            SmashVehicleWindow(currentVehicle, 1)
            SmashVehicleWindow(currentVehicle, 2)
            SmashVehicleWindow(currentVehicle, 3)
            SmashVehicleWindow(currentVehicle, 4)
            SmashVehicleWindow(currentVehicle, 5)
            SmashVehicleWindow(currentVehicle, 6)
            SmashVehicleWindow(currentVehicle, 7)
        end
        if body < 800.0 then
            SetVehicleDoorBroken(currentVehicle, 0, true)
            SetVehicleDoorBroken(currentVehicle, 1, true)
            SetVehicleDoorBroken(currentVehicle, 2, true)
            SetVehicleDoorBroken(currentVehicle, 3, true)
            SetVehicleDoorBroken(currentVehicle, 4, true)
            SetVehicleDoorBroken(currentVehicle, 5, true)
            SetVehicleDoorBroken(currentVehicle, 6, true)
        end
        if engine < 700.0 then
            SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
        end
        if engine < 500.0 then
            SetVehicleTyreBurst(currentVehicle, 0, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 5, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 6, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 7, false, 990.0)
        end

	SetVehicleBodyHealth(currentVehicle, body)
	SetVehicleEngineHealth(currentVehicle, engine)
end