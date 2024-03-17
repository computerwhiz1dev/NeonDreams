local chargeProp = {}
if ChargeOn then
  CreateThread(function()
    Citizen.Wait(500)
    RequestModel(GetHashKey(NormalChargingPropName))
    RequestModel(GetHashKey(FastChargingPropName))
    while not HasModelLoaded(GetHashKey(NormalChargingPropName)) do
      Citizen.Wait(1000)
    end
    while not HasModelLoaded(GetHashKey(FastChargingPropName)) do
      Citizen.Wait(1000)
    end
      for _, coords in pairs(PhoneNormalCharging) do
          local prop = CreateObject(GetHashKey(NormalChargingPropName), coords.x, coords.y, coords.z - 1.0, false)
          SetEntityHeading(prop, coords.w)
          FreezeEntityPosition(prop, true)
          chargeProp[#chargeProp + 1] = prop

          if ChargeBlipOn then
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, 354)
            SetBlipColour(blip, 0)
            SetBlipDisplay(blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(_U('charging_normal'))
            EndTextCommandSetBlipName(blip)
          end
      end
      for _, coords in pairs(PhoneFastCharging) do
          local prop = CreateObject(GetHashKey(FastChargingPropName), coords.x, coords.y, coords.z - 1.0, false)
          SetEntityHeading(prop, coords.w)
          FreezeEntityPosition(prop, true)
          chargeProp[#chargeProp + 1] = prop

          if ChargeBlipOn then
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, 354)
            SetBlipColour(blip, 7)
            SetBlipDisplay(blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(_U('charging_fast'))
            EndTextCommandSetBlipName(blip)
          end
      end

      if ChargeEyeTarget then

          --- Normal Charging
          exports[Config.TargetExport]:AddTargetModel(GetHashKey(NormalChargingPropName), {
              options = {
                  {
                    icon = "fa fa-mobile",
                    label = _U('charging_normal'),
                    action = function()
                      NormalChargePhone()
                    end
                  },
                  {
                    icon = "fa fa-bolt",
                    label = _U('cancelcharge'),
                    action = function()
                      CancelCharge()
                    end
                  },
              },
              distance = 2.5,
          })

          --- Fast Charging
          exports[Config.TargetExport]:AddTargetModel(GetHashKey(FastChargingPropName), {
              options = {
                  {
                    icon = "fa fa-mobile",
                    label = _U('charging_fast'),
                    action = function()
                      FastChargePhone()
                    end
                  },
                  {
                    icon = "fa fa-bolt",
                    label = _U('cancelcharge'),
                    action = function()
                      CancelCharge()
                    end
                  },
              },
              distance = 2.5,
          })
      end
  end)

end


RegisterCommand("deletecharge", function()
  for _, coords in pairs(chargeProp) do
    DeleteEntity(coords)
  end
end)

AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    for _, coords in pairs(chargeProp) do
      DeleteEntity(coords)
    end
    DeletePhone()
  end
end)
