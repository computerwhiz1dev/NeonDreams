-- BANK --

RegisterServerEvent('gksphone:transferPhoneNumber')
AddEventHandler('gksphone:transferPhoneNumber', function(to, totaltt)
    local _source = source
    local xPlayer = Config.Core.Functions.GetPlayer(_source)
    local TotalMoney = tonumber(totaltt)
    local zPlayer = Config.Core.Functions.GetPlayerByPhone(to)
    local totalTax = 0

    if Config.BankTransferCom ~= 0 then
      price = tonumber(TotalMoney * (1+ Config.BankTransferCom / 100))
      checktax = Round(price)
      totalTax = tonumber(checktax - TotalMoney)
    end

    local balance = 0
    if zPlayer ~= nil then
        local zPlayerIden = zPlayer.PlayerData.citizenid
        local name = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
        local name2 = zPlayer.PlayerData.charinfo.firstname .. " " .. zPlayer.PlayerData.charinfo.lastname
        balance = xPlayer.PlayerData.money["bank"]
        if xPlayer.PlayerData.citizenid == zPlayerIden then
            TriggerClientEvent('gksphone:notifi', _source, { title = _U('bank_title'), message = _U('bank_yourself'), img = '/html/static/img/icons/wallet.png' })
        else
            if balance <= 0 or balance < tonumber(TotalMoney) or tonumber(TotalMoney) <= 0 then
                TriggerClientEvent('gksphone:notifi', _source, { title = _U('bank_title'), message = _U('bank_nomoney'), img = '/html/static/img/icons/wallet.png' })
            else
                xPlayer.Functions.RemoveMoney('bank', tonumber(TotalMoney), "Bank depost")
                if Config.BankTransferCom ~= 0 then
                  xPlayer.Functions.RemoveMoney('bank', tonumber(totalTax), "Bank Transfer Fee")
                end
                zPlayer.Functions.AddMoney('bank', tonumber(TotalMoney), "Bank depost")
                -- advanced notification with bank icon
                TriggerClientEvent('gksphone:notifi', zPlayer.PlayerData.source, { title = _U('bank_title'), message = _U('bank_transfer', name), img = '/html/static/img/icons/wallet.png' })

                TriggerClientEvent('gksphone:notifi', _source, { title = _U('bank_title'), message = _U('bank_transfer', name2), img = '/html/static/img/icons/wallet.png' })


                MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                    ["@type"] = 1,
                    ["@identifier"] = xPlayer.PlayerData.citizenid,
                    ["@price"] = TotalMoney,
                    ["@name"] = name2
                }, function(results)
                end)


                MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                    ["@type"] = 2,
                    ["@identifier"] = zPlayerIden,
                    ["@price"] = totaltt,
                    ["@name"] = name
                }, function(resultss)
                end)

                if Config.BankTransferCom ~= 0 then
                    MySQL.Async.insert("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                      ["@type"] = 1,
                      ["@identifier"] = xPlayer.PlayerData.citizenid,
                      ["@price"] = totalTax,
                      ["@name"] = _U('bank_taxbank', name2)
                      }, function(resultss)
                    end)
                end

                if tonumber(TotalMoney) >= Cfg.BankLimit then
                    BankTrasnfer(name, xPlayer.PlayerData.citizenid, tonumber(TotalMoney), name2, zPlayerIden)
                end
                TriggerEvent('gksphone:server:bank_gettransferinfo', zPlayer.PlayerData.source)
                TriggerClientEvent('gksphone:client:changeCharge', _source, 'banktransfer')
            end
        end
    elseif Config.OfflineBankTransfer then
        local zPlayerIden = GetIdentifierByPhoneNumberBank(to)
        if zPlayerIden ~= nil then
            balance = xPlayer.PlayerData.money["bank"]
            local name2 = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
            if xPlayer.PlayerData.citizenid == zPlayerIden then
                TriggerClientEvent('gksphone:notifi', _source, { title = _U('bank_title'), message = _U('bank_yourself'), img = '/html/static/img/icons/wallet.png' })
            else
                if balance <= 0 or balance < tonumber(TotalMoney) or tonumber(TotalMoney) <= 0 then
                    TriggerClientEvent('gksphone:notifi', _source, { title = _U('bank_title'), message = _U('bank_nomoney'), img = '/html/static/img/icons/wallet.png' })
                else

                    MySQL.Async.fetchAll("SELECT money, charinfo FROM players WHERE citizenid = @identifier", {
                        ['@identifier'] = zPlayerIden,
                    }, function(result)

                        if result[1] then
                            local g = json.decode(result[1].money)

                            g['bank'] = g['bank'] + (tonumber(TotalMoney));
                            if Config.BankTransferCom ~= 0 then
                                g['bank']=g['bank']-(tonumber(totalTax));
                              end
                            xPlayer.Functions.RemoveMoney('bank', tonumber(TotalMoney), "Bank depost")
                            MySQL.Async.execute('UPDATE players SET `money` = @bank WHERE `citizenid` = @identifier', {
                                ['@identifier'] = zPlayerIden,
                                ['@bank'] = json.encode(g),
                            })

                            local deneme = json.decode(result[1].charinfo)
                            if tonumber(TotalMoney) >= Cfg.BankLimit then
                                BankTrasnfer(deneme.firstname .. " " .. deneme.lastname, xPlayer.PlayerData.citizenid, tonumber(TotalMoney), name2, zPlayerIden)
                            end
                            local pname = deneme.firstname .. " " .. deneme.lastname
                            TriggerClientEvent('gksphone:notifi', _source, { title = _U('bank_title'), message =  _U('bank_transfer', pname), img = '/html/static/img/icons/wallet.png' })
                            MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                                ["@type"] = 1,
                                ["@identifier"] = xPlayer.PlayerData.citizenid,
                                ["@price"] = TotalMoney,
                                ["@name"] = deneme.firstname .. " " .. deneme.lastname
                            }, function()
                            end)
                            if Config.BankTransferCom ~= 0 then
                                local charname = deneme.firstname .. " " .. deneme.lastname
                                MySQL.Async.insert("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                                  ["@type"] = 1,
                                  ["@identifier"] = xPlayer.PlayerData.citizenid,
                                  ["@price"] = totalTax,
                                  ["@name"] = _U('bank_taxbank', charname)
                                  }, function()
                                end)
                            end

                            MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                                ["@type"] = 2,
                                ["@identifier"] = zPlayerIden,
                                ["@price"] = totaltt,
                                ["@name"] = name2
                            }, function()
                            end)
                        else
                            TriggerClientEvent('gksphone:notifi', _source, { title = _U('bank_title'), message = _U('bank_systemnophone'), img = '/html/static/img/icons/wallet.png' })
                        end

                    end)


                    TriggerClientEvent('gksphone:client:changeCharge', _source, 'banktransfer')
                end
            end
        else
            TriggerClientEvent('gksphone:notifi', _source, { title = _U('bank_title'), message = _U('bank_systemnophone'), img = '/html/static/img/icons/wallet.png' })
        end
    else
        TriggerClientEvent('gksphone:notifi', _source, { title = _U('bank_title'), message = _U('bank_tranfail'), img = '/html/static/img/icons/wallet.png' })
    end
    TriggerEvent('gksphone:server:bank_gettransferinfo', _source)
end)

RegisterServerEvent('gksphone:gks:aracisatt')
AddEventHandler('gksphone:gks:aracisatt', function(a, b, c)

    local src = source
    local buyer = Config.Core.Functions.GetPlayer(src)
    local bidentifier = buyer.PlayerData.citizenid
    local carOwner = Config.Core.Functions.GetPlayerByCitizenId(a)

    if carOwner ~= nil then
        local balance = buyer.PlayerData.money["bank"]
        if bidentifier == carOwner.PlayerData.citizenid then
            TriggerClientEvent('gksphone:notifi', src, { title = _U('cars_title'), message = _U('carseller_ownbuy'), img = '/html/static/img/icons/carsales.png' })
        else

            if balance < tonumber(c) then

                TriggerClientEvent('gksphone:notifi', src, { title = _U('cars_title'), message = _U('carseller_nobank'), img = '/html/static/img/icons/carsales.png' })
            else

                local carcheck = MySQL.scalar.await('SELECT price FROM gksphone_vehicle_sales WHERE plate = ? AND owner = ? ', {b, a})

                if carcheck then

                    local price = tonumber(carcheck * (1+ Config.CarsellerTax / 100))
                    local checktax = Round(price)
                    local totalTax = tonumber(checktax - carcheck)

                   local allVeh = GetAllVehicles()
                   for i=1, #allVeh do
                       local plate = GetVehicleNumberPlateText(allVeh[i])
                        if plate == b then
                            DeleteEntity(allVeh[i])
                        elseif Config.Core.Shared.Trim(plate) == b then
                            DeleteEntity(allVeh[i])
                        end
                   end

                    buyer.Functions.RemoveMoney('bank', tonumber(carcheck), "Bank depost")
                    carOwner.Functions.AddMoney('bank', tonumber(carcheck), "Bank depost")
                    if Config.CarsellerTax ~= 0 then
                        carOwner.Functions.RemoveMoney('bank', tonumber(totalTax), "Bank depost")
                    end

                    TriggerEvent('gksphone:notifi', carOwner.PlayerData.source, { title = _U('vale_title'), message = _U('car_seller'), img = '/html/static/img/icons/vale.png' })
                    TriggerClientEvent('gksphone:notifi', src, { title = _U('cars_title'), message = _U('carseller_buyvehicle'), img = '/html/static/img/icons/carsales.png' })
                    TriggerClientEvent('gksphone:notifi', carOwner.PlayerData.source, { title = _U('cars_title'), message = _U('carseller_soldvehicle'), img = '/html/static/img/icons/carsales.png' })

                    if Config.cdGarages then
                        MySQL.Async.execute('UPDATE ' .. Config.OwnedVehicles .. ' SET `citizenid` = @owneryeni, `carseller` = @carseller, `license` = @license, `garage_id` = @garage WHERE `citizenid` = @owner AND `plate` = @plate', {
                            ['@owner'] = a,
                            ['@license'] = buyer.PlayerData.license,
                            ['@plate'] = b,
                            ['@owneryeni'] = bidentifier,
                            ['@carseller'] = 0,
                            ['@garage'] = Config.DefaultGarage,
                        })
                    else
                        MySQL.Async.execute('UPDATE ' .. Config.OwnedVehicles .. ' SET `citizenid` = @owneryeni, `carseller` = @carseller, `license` = @license, `garage` = @garage WHERE `citizenid` = @owner AND `plate` = @plate', {
                            ['@owner'] = a,
                            ['@license'] = buyer.PlayerData.license,
                            ['@plate'] = b,
                            ['@owneryeni'] = bidentifier,
                            ['@carseller'] = 0,
                            ['@garage'] = Config.DefaultGarage,
                        })
                    end


                    MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                        ["@type"] = 1,
                        ["@identifier"] = bidentifier,
                        ["@price"] = tonumber(c),
                        ["@name"] = b .. ' Car Purchase'
                    })

                    MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                        ["@type"] = 2,
                        ["@identifier"] = carOwner.PlayerData.citizenid,
                        ["@price"] = tonumber(c),
                        ["@name"] = b .. ' Car Sales'
                    })


                    if Config.CarsellerTax ~= 0 then
                        MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                            ["@type"] = 1,
                            ["@identifier"] = carOwner.PlayerData.citizenid,
                            ["@price"] = tonumber(totalTax),
                            ["@name"] = _U('carseller_tax')
                        })
                    end

                    MySQL.Async.execute('DELETE FROM gksphone_vehicle_sales WHERE owner = @owner AND plate = @plate', {
                        ['@owner'] = a,
                        ['@plate'] = b,
                    }, function()
                    end)

                    TriggerClientEvent('gksphone:client:getsellercardel', -1, {plate= b})

                    local name = buyer.PlayerData.charinfo.firstname .. " " .. buyer.PlayerData.charinfo.lastname
                    local name2 = carOwner.PlayerData.charinfo.firstname .. " " .. carOwner.PlayerData.charinfo.lastname

                    TriggerEvent('gksphone:carsellernew', a, name2, bidentifier, name, b, c)  -- webhook
                    TriggerClientEvent('gksphone:client:changeCharge', src, 'carseller')

                else
                    TriggerClientEvent('gksphone:notifi', src, { title = _U('cars_title'), message = _U('carseller_notbuyvehicle'), img = '/html/static/img/icons/carsales.png' })
                end


            end


        end

    elseif Config.OfflineCarSeller then

        local balance = buyer.PlayerData.money["bank"]

        if balance < tonumber(c) then

            TriggerClientEvent('gksphone:notifi', src, { title = _U('cars_title'), message = _U('carseller_nobank'), img = '/html/static/img/icons/carsales.png' })
        else

            local carcheck = MySQL.scalar.await('SELECT price FROM gksphone_vehicle_sales WHERE plate = ? AND owner = ? ', {b, a})

            if carcheck then
                local price = tonumber(c * (1+ Config.CarsellerTax / 100))
                local checktax = Round(price)
                local totalTax = tonumber(checktax - c)
                MySQL.Async.fetchAll("SELECT money FROM players WHERE citizenid = @identifier", {
                    ['@identifier'] = a,
                }, function(result)
                    local g = json.decode(result[1].money)

                    g['bank'] = g['bank'] + (c);
                    if Config.CarsellerTax ~= 0 then
                        g['bank'] = g['bank'] - (totalTax);
                    end
                    local allVeh = GetAllVehicles()
                    for i=1, #allVeh do
                        local plate = GetVehicleNumberPlateText(allVeh[i])
                         if plate == b then
                             DeleteEntity(allVeh[i])
                         elseif Config.Core.Shared.Trim(plate) == b then
                             DeleteEntity(allVeh[i])
                         end
                    end
                    buyer.Functions.RemoveMoney('bank', tonumber(c), "Bank depost")
                    if Config.cdGarages then
                        MySQL.Async.execute('UPDATE ' .. Config.OwnedVehicles .. ' SET `citizenid` = @owneryeni, `carseller` = @carseller, `license` = @license, `garage_id` = @garage WHERE `citizenid` = @owner AND `plate` = @plate', {
                            ['@owner'] = a,
                            ['@license'] = buyer.PlayerData.license,
                            ['@plate'] = b,
                            ['@owneryeni'] = bidentifier,
                            ['@carseller'] = 0,
                            ['@garage'] = Config.DefaultGarage,
                        })
                    else
                        MySQL.Async.execute('UPDATE ' .. Config.OwnedVehicles .. ' SET `citizenid` = @owneryeni, `carseller` = @carseller, `license` = @license, `garage` = @garage WHERE `citizenid` = @owner AND `plate` = @plate', {
                            ['@owner'] = a,
                            ['@license'] = buyer.PlayerData.license,
                            ['@plate'] = b,
                            ['@owneryeni'] = bidentifier,
                            ['@carseller'] = 0,
                            ['@garage'] = Config.DefaultGarage,
                        })
                    end
                    MySQL.Async.execute('UPDATE players SET `money` = @bank WHERE `citizenid` = @identifier', {
                        ['@identifier'] = a,
                        ['@bank'] = json.encode(g),
                    })
                end)


                MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                    ["@type"] = 1,
                    ["@identifier"] = bidentifier,
                    ["@price"] = c,
                    ["@name"] = b .. ' Car purchase'
                }, function()
                end)


                MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                    ["@type"] = 2,
                    ["@identifier"] = a,
                    ["@price"] = c,
                    ["@name"] = b .. ' Car sale'
                }, function()
                end)

                if Config.CarsellerTax ~= 0 then
                    MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)", {
                        ["@type"] = 1,
                        ["@identifier"] = a,
                        ["@price"] = tonumber(totalTax),
                        ["@name"] = _U('carseller_tax')
                    })
                end

                local name = buyer.PlayerData.charinfo.firstname .. " " .. buyer.PlayerData.charinfo.lastname
                local name2 = "Offline " .. a


                TriggerEvent('gksphone:carsellernew', a, name2, bidentifier, name, b, c)
                TriggerClientEvent('gksphone:notifi', src, { title = _U('cars_title'), message = _U('carseller_buyvehicle'), img = '/html/static/img/icons/carsales.png' })

                MySQL.Async.execute('DELETE FROM gksphone_vehicle_sales WHERE owner = @owner AND plate = @plate', {
                    ['@owner'] = a,
                    ['@plate'] = b,
                }, function()

                end)

                TriggerClientEvent('gksphone:client:getsellercardel', -1, {plate= b})
                TriggerClientEvent('gksphone:client:changeCharge', src, 'carseller')
            end



        end
    else

        TriggerClientEvent('gksphone:notifi', src, { title = _U('cars_title'), message = _U('carseller_notperson'), img = '/html/static/img/icons/carsales.png' })

    end
end)

RegisterServerEvent('gksphone:server:bank_gettransferinfo')
AddEventHandler('gksphone:server:bank_gettransferinfo', function(denemee)
    if denemee ~= nil then
        local sourcePlayer = tonumber(denemee)
        BankGetBilling(sourcePlayer)
        local xPlayer = Config.Core.Functions.GetPlayer(sourcePlayer)
        TriggerClientEvent('gksphone:client:setBankBalance', sourcePlayer, xPlayer.PlayerData.money.bank)
    end
end)


function BankGetBilling(test)
    local xPlayer = Config.Core.Functions.GetPlayer(test)
    MySQL.Async.fetchAll([===[
        SELECT * FROM gksphone_bank_transfer WHERE identifier = @identifier ORDER BY time DESC LIMIT 10
        ]===], { ['@identifier'] = xPlayer.PlayerData.citizenid }, function(bankkkkk)
        TriggerClientEvent('gksphone:client:bank_gettransferinfo', test, bankkkkk)
    end)
end

RegisterServerEvent("gksphone:server:BusSendTip")
AddEventHandler("gksphone:server:BusSendTip", function(phoneNumber, amaount)
    local _source = source
    local tip = amaount
    local xPlayer = Config.Core.Functions.GetPlayer(_source)
    local zPlayer = Config.Core.Functions.GetPlayerByPhone(phoneNumber)
    local AuthCheck = false
    if xPlayer and zPlayer then
        local jobs = xPlayer.PlayerData.job.name
        local gradejob = 0
        if type(xPlayer.PlayerData.job.grade) == "number" then
            gradejob = xPlayer.PlayerData.job.grade
        else
            gradejob = xPlayer.PlayerData.job.grade.level
        end

        for k, value in pairs(Config.JobGrade) do
            if jobs == k and gradejob >= value then
                AuthCheck = true
                break
            end
        end

        if not AuthCheck then TriggerEvent("gksphone:exploitwebhook", source, "Bussines Send TIP", "Unauthorized Use of Send TIP") return end
        if GetResourceState("qb-management") == "started" then
            if exports['qb-management']:RemoveMoney(jobs, tip) then
                zPlayer.Functions.AddMoney('bank', tonumber(tip), "tip")
                TriggerClientEvent('gksphone:notifi', source, {title = _U('bank_title'), message = _U('bank_transfer', zPlayer.PlayerData.charinfo.firstname), img = '/html/static/img/icons/wallet.png'})
                TriggerClientEvent('gksphone:notifi', zPlayer.PlayerData.source, {title = _U('bank_title'), message = _U('bank_playertransfer'), img = '/html/static/img/icons/wallet.png'})
            else
                TriggerClientEvent('gksphone:notifi', source, {title = _U('bank_title'), message = _U('bank_societynomoney'), img = '/html/static/img/icons/wallet.png'})
            end
            Wait(500)
        elseif GetResourceState("qb-bossmenu") == "started" then
            TriggerEvent("qb-bossmenu:server:removeAccountMoney", jobs, tip)
            zPlayer.Functions.AddMoney('bank', tonumber(tip), "tip")
            TriggerClientEvent('gksphone:notifi', source, {title = _U('bank_title'), message = _U('bank_transfer'), img = '/html/static/img/icons/wallet.png'})
            TriggerClientEvent('gksphone:notifi', zPlayer.PlayerData.source, {title = _U('bank_title'), message = _U('bank_playertransfer'), img = '/html/static/img/icons/wallet.png'})
            Wait(500)
        end
    else
        TriggerClientEvent('gksphone:notifi', source, {title = _U('bank_title'), message = _U('bill_notplayer', phoneNumber), img = '/html/static/img/icons/wallet.png'})
    end
end)
-- BANK --
