--================================================================================================
--==            --    XenKnighT --        https://discord.gg/XUck63E                            ==
--================================================================================================

local phone = false

local function cameraOpen (caminfo)
	Cameraacik = caminfo
	local frontCam = false
	Citizen.CreateThread(function()
		while Cameraacik == true do
			Citizen.Wait(0)

			if IsControlJustPressed(1, 27)  then -- SELFIE MODE
				frontCam = not frontCam
				CellFrontCamActivate(frontCam)
			end

			HideHudComponentThisFrame(7)
			HideHudComponentThisFrame(8)
			HideHudComponentThisFrame(9)
			HideHudComponentThisFrame(6)
			HideHudComponentThisFrame(19)
			HideHudAndRadarThisFrame()
			EnableAllControlActions(0)
			SetPauseMenuActive(false)
		end
	end)
end


RegisterNetEvent('gksphone:gkssc:camera:open')
AddEventHandler('gksphone:gkssc:camera:open', function()
	phone = true
    PhonePlayOut()
	Wait(0)
	CreateMobilePhone(0)
	CellCamActivate(true, true)
	cameraOpen(phone)
end)

RegisterNetEvent('gksphone:camera:stop')
AddEventHandler('gksphone:camera:stop', function(stop)
	if phone then
		PhonePlayIn()
	end
	phone = stop
	cameraOpen(phone)
end)



function CellFrontCamActivate(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end



