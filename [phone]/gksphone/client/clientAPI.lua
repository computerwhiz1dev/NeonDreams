PlayerData = Config.Core.Functions.GetPlayerData()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
  PlayerData = Config.Core.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
  PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
  PlayerData = val
  if PlayerData.metadata["ishandcuffed"] or PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] then
    if MenuIsOpen == true then
      ClosePhone()
    end
  end
end)

function  OpenPhoneBlock () -- You can use this function if you want to prevent the phone from being turned on.
  if not PlayerData.metadata["ishandcuffed"] and not IsPauseMenuActive() then
    return true
  else
    return false
  end
end

function  GiveKeyCar (callback_vehicle, vehicle)
    if GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(callback_vehicle, vehicle.fuel)
    end
    TriggerEvent("vehiclekeys:client:SetOwner", Config.Core.Functions.GetPlate(callback_vehicle))  -- You may need to write your car key function
end

--- ## Ox Inventory ### ---

function OxItemCheck()
  local itemName = 'phone'
  local itemCheck = false
  if GetResourceState('ox_inventory') == 'started' or Config.OxInvetory then
      for k, v in pairs(Config.ItemName) do
        local count = exports.ox_inventory:Search('count', v)
        if count ~= nil then
          if count >= 1 then
            itemName = v
            itemCheck = true
            break
          end
        end
      end

      return itemCheck, itemName
  else
    return itemCheck, itemName
  end
end


-- ## JOB APP ## --

RegisterNUICallback('JobMMessages', function(data, cb)
  local myPos = GetEntityCoords(PlayerPedId())
  local GPS = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
  TriggerServerEvent('gksphone:gkcs:jbmessage', data.name, data.number, data.message, data.photo, GPS, data.jobm, data.anon)

  local jobs = json.decode(data.jobm)

  if Config.Dispatch == "cd_dispatch" then
    for k=1, #jobs, 1 do
      if jobs[k] == "police" then
        local plyrdata = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = {'police'},
            coords = plyrdata.coords,
            title = 'Notification sent over the phone',
            message = data.message,
            flash = 0,
            unique_id = tostring(math.random(0000000,9999999)),
            blip = {
                sprite = 817,
                scale = 1.2,
                colour = 3,
                flashes = false,
                text = 'Notification phone',
                time = (5*60*1000),
                sound = 1,
            }
        })
      end
    end
  elseif Config.Dispatch == "ps-dispatch" then
    for k=1, #jobs, 1 do
      if jobs[k] == "police" then
        local currentPos = GetEntityCoords(PlayerPedId())
        local locationInfo = getStreetandZone(currentPos)
        TriggerServerEvent("dispatch:server:notify",{
            dispatchcodename = "911call", -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
            dispatchCode = "911",
            firstStreet = locationInfo,
            priority = 2, -- priority
            origin = {
                x = currentPos.x,
                y = currentPos.y,
                z = currentPos.z
            },
            dispatchMessage = "Notification sent over the phone", -- message
            information = data.message,
            job = {"police"} -- jobs that will get the alerts
        })
      end
    end
  end


  cb('ok')
end)

--- QBCORE MDT ---

RegisterNUICallback('userfetchmdt', function(data,cb)
  Config.Core.Functions.TriggerCallback('gksphone:server:FetchResult', function(result)
    SendNUIMessage({event = 'MDTFetchPerson', MdtPerson = result})
  end, data)
  cb('ok')
end)

RegisterNUICallback('housefetchmdt', function(data,cb)
  Config.Core.Functions.TriggerCallback('qb-phone:server:MeosGetPlayerHouses', function(result)
    SendNUIMessage({event = 'MDTFetchHouse', MdtHouse = result})
  end, data)
  cb('ok')
end)

RegisterNUICallback('platescanmdt', function(data,cb)
  local vehicle = Config.Core.Functions.GetClosestVehicle()
  local plate = Config.Core.Functions.GetPlate(vehicle)
  local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
  local denadwad = {}
  Config.Core.Functions.TriggerCallback('gksphone:server:ScanPlate', function(result)
    Config.Core.Functions.TriggerCallback('police:IsPlateFlagged', function(flagged)
          result.isFlagged = flagged
          if Config.Core.Shared.Vehicles[vehname] ~= nil then
              result.label = Config.Core.Shared.Vehicles[vehname]['name']
          else
              result.label = 'Unknown brand..'
          end
          table.insert(denadwad, result)
          SendNUIMessage({event = 'MDTFetchPlate', MdtPlate = denadwad})
      end, plate)
  end, plate)
  cb('ok')
end)

RegisterNUICallback('platesearchmdt', function(data,cb)
  Config.Core.Functions.TriggerCallback('gksphone:server:GetVehicleSearchResults', function(result)
    if result ~= nil then
        for k, v in pairs(result) do
          Config.Core.Functions.TriggerCallback('police:IsPlateFlagged', function(flagged)
                result[k].isFlagged = flagged
            end, result[k].plate)
            Wait(50)
        end
    end
    SendNUIMessage({event = 'MDTFetchPlate', MdtPlate = result})
  end, data)
  cb('ok')
end)

RegisterNUICallback('wantedekleme', function(data,cb)
  TriggerServerEvent('gksphone:server:wantedekle', data.cid, data.wreason, data.wappear, data.wlastsn)
  cb('ok')
end)

RegisterNUICallback('wantedelete', function(data,cb)
  TriggerServerEvent('gksphone:server:wantedelete', data)
  cb('ok')
end)

RegisterNUICallback('wantedveri', function(data,cb)
  Config.Core.Functions.TriggerCallback('gksphone:server:wantedveri', function(result)
    SendNUIMessage({event = 'MDTWantedFetch', MdtWanted = result})
  end)
  cb('ok')
end)

RegisterNetEvent('gksphone:client:wantedyenile', function(result)
  SendNUIMessage({event = 'MDTWantedFetch', MdtWanted = result})
end)

RegisterNUICallback('setApartLocal', function(data, cb)
  local TypeData = Apartments.Locations[data.type]
  SetNewWaypoint(TypeData.coords.enter.x, TypeData.coords.enter.y)
  TriggerEvent('gksphone:notifi', {title = _U('gps_title'), message = _U('set_gps'), img= '/html/static/img/icons/maps.png' })
  cb('ok')
end)



--- QBCORE House ---

RegisterNUICallback('qbcorehfetch', function(data,cb)
  if Config.loafHouse then
    local ownedHouses = exports.loaf_housing:GetOwnedHouses()
    SendNUIMessage({event = 'FetchPlayerHouse', PlayerHouse = ownedHouses})
  elseif Config.bcs_housing then
    local ownedHouses = exports.bcs_housing:GetOwnedHomes()
    SendNUIMessage({event = 'FetchPlayerHouse', PlayerHouse = ownedHouses})
  else
    Config.Core.Functions.TriggerCallback('qb-phone:server:GetPlayerHouses', function(result)
      SendNUIMessage({event = 'FetchPlayerHouse', PlayerHouse = result})
    end)
  end
  cb('ok')
end)

RegisterNUICallback('qbcorehkeyfetch', function(data,cb)
  if Config.loafHouse then
    local keys = exports.loaf_keysystem:GetKeys()
    local properties = {}
    for _, v in pairs(keys) do
        local _, _, propertyId = v.key_id:find("housing_key_(.*)_")
        if propertyId then
            properties[tonumber(propertyId)] = {HouseData = {adress = v.key_data.name}, id = tonumber(propertyId)}
        end
    end
    SendNUIMessage({event = 'FetchPlayerHouseKeys', PlayerHouseKeys = properties})
  elseif Config.bcs_housing then
    local houses = exports.bcs_housing:GetHouseKeys()
    local keys = {}
    for i=1, #houses do
        houses[i].label = houses[i].name
        houses[i].name = houses[i].identifier
        houses[i].tier = 1
        houses[i].coords = houses[i].entry
        houses[i].keyholders = exports.bcs_housing:GetKeyHolders(houses[i].identifier)
        keys[#keys + 1] = {
            HouseData = houses[i]
        }
    end
    SendNUIMessage({event = 'FetchPlayerHouseKeys', PlayerHouseKeys = keys})
  else
    Config.Core.Functions.TriggerCallback('qb-phone:server:GetHouseKeys', function(result)
      SendNUIMessage({event = 'FetchPlayerHouseKeys', PlayerHouseKeys = result})
    end)
  end
  cb('ok')
end)

RegisterNUICallback('qbhousetransfer', function(data,cb)
  if Config.loafHouse then
    TriggerServerEvent('gksphone:server:evtransfer', data)
  elseif Config.bcs_housing then
    Config.Core.Functions.TriggerCallback('gksphone:server:getCizitinID', function(citizenid, source)
      if source then
        local srcid = source
        TriggerServerEvent('Housing:transferOwner', data.bilgi.identifier, tonumber(srcid))
      end
    end, data)
  else
    Config.Core.Functions.TriggerCallback('gksphone:server:getCizitinID', function(citizenid)
      local TransferedCid = citizenid
      CreateThread(function()
        Config.Core.Functions.TriggerCallback('qb-phone:server:TransferCid', function(transfer)
          if transfer then
            Config.Core.Functions.TriggerCallback('qb-phone:server:GetPlayerHouses', function(result)
              SendNUIMessage({event = 'FetchPlayerHouse', PlayerHouse = result})
            end)
          end
        end, TransferedCid, data.bilgi)
      end)
    end, data)
  end
  cb('ok')
end)

RegisterNUICallback('qbcoreHouseLocal', function(data,cb)
  if Config.loafHouse then
    exports.loaf_housing:MarkProperty(data.id)
    TriggerEvent('gksphone:notifi', {title = _U('gps_title'), message = _U('set_gps'), img= '/html/static/img/icons/maps.png' })
  elseif Config.bcs_housing then
    exports.bcs_housing:SetWaypoint(data.HouseData.name)
    TriggerEvent('gksphone:notifi', {title = _U('gps_title'), message = _U('set_gps'), img= '/html/static/img/icons/maps.png' })
  else
    SetNewWaypoint(data.HouseData.coords.enter.x, data.HouseData.coords.enter.y)
    TriggerEvent('gksphone:notifi', {title = _U('gps_title'), message = _U('set_gps'), img= '/html/static/img/icons/maps.png' })
  end
  cb('ok')
end)

RegisterNetEvent('gksphone:client:transferev', function(plyaerid, proptyid)
  exports.loaf_housing:TransferProperty(proptyid, plyaerid)
  TriggerEvent('gksphone:notifi', {title = _U('house_title'), message = _U('house_transfer'), img= '/html/static/img/icons/home.png' })
end)

--- QBCORE Crypto ---

RegisterNUICallback('qbCryptoTrans', function(data,cb)
  Config.Core.Functions.TriggerCallback('gksphone:server:GetCryptoTrans', function(result)
    SendNUIMessage({event = 'FetchCryotoTrans', myTrans = result})
  end)
  cb('ok')
end)

RegisterNUICallback('qbCrptoValue', function(data,cb)
  local dnadawd = {}
  Config.Core.Functions.TriggerCallback('qb-crypto:server:GetCryptoData', function(CryptoData)
    table.insert(dnadawd, CryptoData)
    SendNUIMessage({event = 'FetchCryptoData', CryptoData = dnadawd})
  end, Config.CryptoName)
  cb('ok')
end)

RegisterNUICallback('qbcrytobuy', function(data,cb)
  local dnadawd = {}
  local sayikontrol = tostring(data.Coins)
	if #sayikontrol >= 15 then
		TriggerEvent('gksphone:notifi', { title = _U('bourse_title'), message = _U('cyrpto_amountwrng'), img = '/html/static/img/icons/stocks.png' })
		return
	end
  Config.Core.Functions.TriggerCallback('qb-crypto:server:BuyCrypto', function(CryptoData)
    if CryptoData ~= false then
      table.insert(dnadawd, CryptoData)
      SendNUIMessage({event = 'FetchCryptoData', CryptoData = dnadawd})
    end
  end, data)
  cb('ok')
end)

RegisterNUICallback('qbcrytosell', function(data, cb)
  local dnadawd = {}
  local sayikontrol = tostring(data.Coins)
	if #sayikontrol >= 15 then
		TriggerEvent('gksphone:notifi', { title = _U('bourse_title'), message = _U('cyrpto_amountwrng'), img = '/html/static/img/icons/stocks.png' })
		return
	end
  Config.Core.Functions.TriggerCallback('qb-crypto:server:SellCrypto', function(CryptoData)
    table.insert(dnadawd, CryptoData)
    SendNUIMessage({event = 'FetchCryptoData', CryptoData = dnadawd})
  end, data)
  cb('ok')
end)

RegisterNUICallback('qbcrytotrnsfer', function(data, cb)
  local dnadawd = {}
  Config.Core.Functions.TriggerCallback('gksphone:server:getWalletID', function(WalletID)
    if WalletID then
      data.WalletId = WalletID
      CreateThread(function()
        Config.Core.Functions.TriggerCallback('qb-crypto:server:TransferCrypto', function(CryptoData)
          table.insert(dnadawd, CryptoData)
          SendNUIMessage({event = 'FetchCryptoData', CryptoData = dnadawd})
        end, data)
      end)
    end
  end, data)
  cb('ok')
end)

RegisterNetEvent('qb-phone:client:AddTransaction', function(SenderData, TransactionData, Message, Title)
  local Data = {
      TransactionTitle = Title,
      TransactionMessage = Message,
  }

  TriggerServerEvent('qb-phone:server:AddTransaction', Data)
end)


-- ## Weather in phone ## --

-- weather --

CreateThread(function()
  while true do
    Wait(250)
    WeatherControl()
    Citizen.Wait(120000)
  end
end)


local water = {
  ExtraSunny = 90,
  Clear = 80,
  Neutral = 80,
  Smog = 90,
  Foggy = 80,
  Clouds = 80,
  Overcast = 80,
  Clearing = 75,
  Raining = 75,
  ThunderStorm = 80,
  Blizzard = -5,
  Snowing = 2,
  Snowlight = 8,
  Christmas = -2,
  Halloween = 60
}

local function temperatureRanges(birincihava)

  local deneyasd = water[birincihava]

  if not Config.Fahrenheit then
    deneyasd = (deneyasd - 32) * (5 / 9)
  end

  local temp_conv_str = string.format('%.0f', deneyasd)

  if Config.Fahrenheit then
    return temp_conv_str .. ' °F'
  else
    return temp_conv_str .. ' °C'
  end

end

function WeatherControl()
  local faruk, deea, waadad = GetWeatherTypeTransition()
    letSleed = false
    local denmee
    local agasdwa
      if (faruk == -1750463879) then
        denmee = 'ExtraSunny'
      elseif (faruk == 916995460) then
        denmee = 'Clear'
      elseif (faruk == -1530260698) then
        denmee = 'Neutral'
      elseif (faruk == 282916021) then
        denmee = 'Smog'
      elseif (faruk == -1368164796) then
        denmee = 'Foggy'
      elseif (faruk == 821931868) then
        denmee = 'Clouds'
      elseif (faruk == -1148613331) then
        denmee = 'Overcast'
      elseif (faruk == 1840358669) then
        denmee = 'Clearing'
      elseif (faruk == 1420204096) then
        denmee = 'Raining'
      elseif (faruk == -1233681761) then
        denmee = 'ThunderStorm'
      elseif (faruk == 669657108) then
        denmee = 'Blizzard'
      elseif (faruk == -273223690) then
        denmee = 'Snowing'
      elseif (faruk == 603685163) then
        denmee = 'Snowlight'
      elseif (faruk == -1429616491) then
        denmee = 'Christmas'
      elseif (faruk == -921030142) then
        denmee = 'Halloween'
      end

      if (deea == -1750463879) then
        agasdwa = 'ExtraSunny'
      elseif (deea == 916995460) then
        agasdwa = 'Clear'
      elseif (deea == -1530260698) then
        agasdwa = 'Neutral'
      elseif (deea == 282916021) then
        agasdwa = 'Smog'
      elseif (deea == -1368164796) then
        agasdwa = 'Foggy'
      elseif (deea == 821931868) then
        agasdwa = 'Clouds'
      elseif (deea == -1148613331) then
        agasdwa = 'Overcast'
      elseif (deea == 1840358669) then
        agasdwa = 'Clearing'
      elseif (deea == 1420204096) then
        agasdwa = 'Raining'
      elseif (deea == -1233681761) then
        agasdwa = 'ThunderStorm'
      elseif (deea == 669657108) then
        agasdwa = 'Blizzard'
      elseif (deea == -273223690) then
        agasdwa = 'Snowing'
      elseif (deea == 603685163) then
        agasdwa = 'Snowlight'
      elseif (deea == -1429616491) then
        agasdwa = 'Christmas'
      elseif (deea == -921030142) then
        agasdwa = 'Halloween'
      end

      local weatherg = {}
      local temperature = temperatureRanges(denmee)
      local temperatureto = temperatureRanges(agasdwa)

      table.insert(weatherg, { weatersi = denmee, waterso = agasdwa, tempsi = temperature, tempso = temperatureto })

      SendNUIMessage({event = 'weatherx', weathers = weatherg})
end

-- ## Clock in phone ## --

local useMilitaryTime = false

RegisterNUICallback('saat', function(data,cb)
  local hour = GetClockHours()
  local minute = GetClockMinutes()

  if useMilitaryTime == false then
    if hour == 0 or hour == 24 then
      hour = 12
    elseif hour >= 13 then
      hour = hour - 12
    end
  end

  if hour <= 9 then
    hour = "0" .. hour
  end
  if minute <= 9 then
    minute = "0" .. minute
  end
  local timeText = hour ..':' ..minute;
  SendNUIMessage({event = 'emuncuk', timeText = timeText})
  cb('ok')
end)


-- qphone trigger --

RegisterNetEvent('qb-phone:client:RemoveBankMoney', function(amount)
  if amount > 0 then
      TriggerEvent('gksphone:notifi', {title = _U('bank_title'), message = "$"..amount.." has been removed from your balance!", img= '/html/static/img/icons/wallet.png'})
  end
end)

RegisterNetEvent('qb-phone:client:AddTransaction', function(SenderData, TransactionData, Message, Title)
  TriggerEvent('gksphone:notifi', {title = _U('qbit_title'), message = Message, img= '/html/static/img/icons/qbit.png'})
end)

if Config.HospitalAmbulanceAlert then
  RegisterNetEvent('hospital:client:ambulanceAlert', function(coords, text)
    local GPS = 'GPS: ' .. coords.x .. ', ' .. coords.y
    TriggerServerEvent('gksphone:gkcs:jbmessage', "Anonymous", "", 'Emergency aid notification ' ..text, '', GPS, '["ambulance"]', true)
  end)
end


-- REGISTER COOMAND --

RegisterCommand("testmailbutton",function(source, args, rawCommand)
	TriggerServerEvent('gksphone:NewMail', {
		sender = 'GKSHOP',
		image = '/html/static/img/icons/mail.png',
		subject = "GKSPHONE",
		message = 'TEST',
    button = {
      buttonEvent = "qb-drugs:client:setLocation",
      buttonData = "test",
      buttonname = "test"
    }
  })
end)

RegisterCommand("testmail",function(source, args, rawCommand)
	TriggerServerEvent('gksphone:NewMail', {
		sender = 'GKSHOP',
		image = '/html/static/img/icons/mail.png',
		subject = "GKSPHONE",
		message = 'TEST'
  })
end)



RegisterCommand("911p",function(source, args, rawCommand)
  local message = args[1]
  local label = ""
  for i=1, #args, 1 do
    label = label .. ' ' ..args[i]
  end
  if message then
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local myPos = GetEntityCoords(PlayerPedId())
    local GPS = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
    local Playerd = Config.Core.Functions.GetPlayerData()
    local display = Playerd.charinfo.firstname .. " " .. Playerd.charinfo.lastname
    local pnumber = Playerd.charinfo.phone
    TriggerServerEvent('gksphone:gkcs:jbmessage', display, pnumber, label, '', GPS, '["police", "sheriff"]', false)
  end
end, false)

RegisterCommand("911e",function(source, args, rawCommand)
  local message = args[1]
  local label = ""
  for i=1, #args, 1 do
    label = label .. ' ' ..args[i]
  end
  if message then
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local myPos = GetEntityCoords(PlayerPedId())
    local GPS = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
    local Playerd = Config.Core.Functions.GetPlayerData()
    local display = Playerd.charinfo.firstname .. " " .. Playerd.charinfo.lastname
    local pnumber = Playerd.charinfo.phone

    TriggerServerEvent('gksphone:gkcs:jbmessage', display, pnumber, label, '', GPS, '["ambulance"]', false)

  end


end, false)

Citizen.CreateThread(function()
  TriggerEvent('chat:addSuggestion', '/911p', _U('911p'), {{ name="message", help=_U('911pmessage')}})
  TriggerEvent('chat:addSuggestion', '/911e', _U('911e'), {{ name="message", help=_U('911emessage')}})
end)

-- REGISTER COMMAND --
