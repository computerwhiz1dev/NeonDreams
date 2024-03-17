-- BILLING --
Config.Core.Functions.CreateCallback('gksphone:getbilling', function(source, cb)
    local e = Config.Core.Functions.GetPlayer(source)
    MySQL.Async.fetchAll('SELECT * FROM gksphone_invoices WHERE citizenid = @identifier ',
        {["@identifier"] = e.PlayerData.citizenid}, function(result)
            local billingg = {}
            for i = 1, #result, 1 do
                table.insert(billingg,
                    {id = result[i].id, sender = result[i].society, sendercitizenid = result[i].sendercitizenid,
                        label = result[i].label, amount = result[i].amount})
            end
            cb(billingg)
        end)
end)

RegisterServerEvent("gksphone:faturapayBill")
AddEventHandler("gksphone:faturapayBill", function(id)
    local src = source
    local Ply = Config.Core.Functions.GetPlayer(src)

    MySQL.Async.fetchAll('SELECT * FROM gksphone_invoices WHERE id = @id', {
        ['@id'] = id.id
    }, function(data)


        if Ply.PlayerData.money.bank >= data[1].amount then
            if Config.UseBillingCommission then
                local SenderPly = Config.Core.Functions.GetPlayerByCitizenId(data[1].sendercitizenid)
                if SenderPly ~= nil then
                    if Config.BillingCommissions[data[1].society] then
                        local commission = Round(data[1].amount * Config.BillingCommissions[data[1].society])
                        SenderPly.Functions.AddMoney('bank', commission)
                        if GetResourceState("qb-management") == "started" then
                            exports['qb-management']:RemoveMoney(data[1].society, commission)
                            Wait(500)
                        elseif GetResourceState("qb-bossmenu") == "started" then
                            TriggerEvent("qb-bossmenu:server:removeAccountMoney", data[1].society, commission)
                            Wait(500)
                        end
                        TriggerClientEvent('gksphone:notifi', SenderPly.PlayerData.source,
                            {title = _U('billing_title'),
                                message = string.format('You received a commission check of $%s when %s %s paid a bill of $%s.'
                                    , commission, Ply.PlayerData.charinfo.firstname, Ply.PlayerData.charinfo.lastname,
                                    data[1].amount), img = '/html/static/img/icons/logo.png'})
                    end
                end
            end

            Ply.Functions.RemoveMoney('bank', data[1].amount, "paid-invoice")
            if GetResourceState("qb-management") == "started" then
                Wait(500)
                exports['qb-management']:AddMoney(data[1].society, data[1].amount)
            elseif GetResourceState("qb-bossmenu") == "started" then
                Wait(500)
                TriggerEvent("qb-bossmenu:server:addAccountMoney", data[1].society, data[1].amount)
            end
            TriggerEvent('gksphone:server:bank_gettransferinfo', src)
            MySQL.Async.execute('DELETE FROM gksphone_invoices WHERE id=@id', {['@id'] = id.id})
            TriggerClientEvent('updatebilling', src)


            MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)"
                , {
                    ["@type"] = 1,
                    ["@identifier"] = Ply.PlayerData.citizenid,
                    ["@price"] = data[1].amount,
                    ["@name"] = _U('bill_billing') .. data[1].amount
                })
            TriggerClientEvent('gksphone:client:changeCharge', src, 'billing')
        else
            TriggerClientEvent('gksphone:notifi', Ply.PlayerData.source,
                {title = _U('billing_title'), message = _U('bill_nocash'), img = '/html/static/img/icons/logo.png'})
            TriggerEvent('gksphone:server:bank_gettransferinfo', src)
            TriggerClientEvent('updatebilling', src)
        end
    end)
end)

RegisterServerEvent("gksphone:server:faturapayBill")
AddEventHandler("gksphone:server:faturapayBill", function()
    local src = source
    local Ply = Config.Core.Functions.GetPlayer(src)
    local money = Ply.PlayerData.money.bank
    MySQL.Async.fetchAll('SELECT * FROM gksphone_invoices WHERE citizenid = @citizenid', {
        ['@citizenid'] = Ply.PlayerData.citizenid
    }, function(data)
        for i = 1, #data, 1 do
            if money >= data[i].amount then
                if Config.UseBillingCommission then
                    local SenderPly = Config.Core.Functions.GetPlayerByCitizenId(data[i].sendercitizenid)
                    if SenderPly ~= nil then
                        if Config.BillingCommissions[data[i].society] then
                            local commission = Round(data[i].amount * Config.BillingCommissions[data[i].society])
                            SenderPly.Functions.AddMoney('bank', commission)
                            if GetResourceState("qb-management") == "started" then
                                exports['qb-management']:RemoveMoney(data[i].society, commission)
                                Wait(500)
                            elseif GetResourceState("qb-bossmenu") == "started" then
                                TriggerEvent("qb-bossmenu:server:removeAccountMoney", data[i].society, commission)
                                Wait(500)
                            end
                            TriggerClientEvent('gksphone:notifi', tonumber(SenderPly.PlayerData.source),
                                {title = _U('billing_title'),
                                    message = string.format('You received a commission check of $%s when %s %s paid a bill of $%s.'
                                        , commission, Ply.PlayerData.charinfo.firstname, Ply.PlayerData.charinfo.lastname,
                                        data[i].amount), img = '/html/static/img/icons/logo.png'})
                        end
                    end

                end

                money = money - data[i].amount
                Ply.Functions.RemoveMoney('bank', data[i].amount, "paid-invoice")
                if GetResourceState("qb-management") == "started" then
                    Wait(500)
                    exports['qb-management']:AddMoney(data[i].society, data[i].amount)
                elseif GetResourceState("qb-bossmenu") == "started" then
                    Wait(500)
                    TriggerEvent("qb-bossmenu:server:addAccountMoney", data[i].society, data[i].amount)
                end
                MySQL.Async.execute('DELETE FROM gksphone_invoices WHERE id=@id', {['@id'] = data[i].id})

                MySQL.Async.execute("INSERT INTO gksphone_bank_transfer (type, identifier, price, name) VALUES (@type, @identifier, @price, @name)"
                    , {
                        ["@type"] = 1,
                        ["@identifier"] = Ply.PlayerData.citizenid,
                        ["@price"] = data[i].amount,
                        ["@name"] = _U('bill_billing') .. data[i].amount
                    })
                TriggerClientEvent('gksphone:client:changeCharge', src, 'billing')
            else
                TriggerClientEvent('gksphone:notifi', src,
                    {title = _U('billing_title'), message = _U('bill_nocash'), img = '/html/static/img/icons/logo.png'})
                break
            end
        end
        TriggerEvent('gksphone:server:bank_gettransferinfo', src)
        TriggerClientEvent('updatebilling', src)
    end)
end)

--- Business İnvoices ---
Config.Core.Functions.CreateCallback('gksphone:server:bfaturalist', function(source, cb)
    local e = Config.Core.Functions.GetPlayer(source)
    local billingg = {}
    MySQL.query("SELECT * FROM gksphone_invoices WHERE society = @society", {["@society"] = e.PlayerData.job.name},
        function(result)
            for i = 1, #result, 1 do
                local yPlayer = Config.Core.Functions.GetPlayerByCitizenId(result[i].citizenid)
                if yPlayer then
                    table.insert(billingg,
                        {id = result[i].id, alici = yPlayer.PlayerData.charinfo.firstname, society = result[i].society,
                            sender = result[i].sender, sendercitizenid = result[i].sendercitizenid,
                            label = result[i].label, amount = result[i].amount})
                else
                    local players = MySQL.scalar.await("SELECT charinfo FROM `players` WHERE `citizenid` LIKE '%" ..
                        result[i].citizenid .. "%'", {})
                    if players then
                        local name = json.decode(players)
                        table.insert(billingg,
                            {id = result[i].id, alici = name.firstname, society = result[i].society,
                                sender = result[i].sender, sendercitizenid = result[i].sendercitizenid,
                                label = result[i].label, amount = result[i].amount})
                    else
                        table.insert(billingg,
                            {id = result[i].id, alici = "", society = result[i].society, sender = result[i].sender,
                                sendercitizenid = result[i].sendercitizenid, label = result[i].label,
                                amount = result[i].amount})
                    end
                end
            end
            cb(billingg)
        end)
end)

RegisterServerEvent("gksphone:business:delbill")
AddEventHandler("gksphone:business:delbill", function(id)
    local src = source
    local e = Config.Core.Functions.GetPlayer(src)

    MySQL.Async.fetchAll('SELECT * FROM gksphone_invoices WHERE society = @society AND id = @id', {
        ['@society'] = e.PlayerData.job.name,
        ['@id'] = id
    }, function(data)
        if data[1] then
            local Player = Config.Core.Functions.GetPlayerByCitizenId(data[1].citizenid)
            if Player then
                TriggerClientEvent('gksphone:notifi', Player.PlayerData.source,
                    {title = _U('bussines_title'), message = data[1].label .. _U('bill_invoicecancel'),
                        img = '/html/static/img/icons/logo.png'})
            end
            MySQL.Async.fetchAll("DELETE FROM gksphone_invoices WHERE id = @id",
                {
                    ['@id'] = data[1].id
                })
            TriggerClientEvent('gksphone:notifi', src,
                {title = _U('bussines_title'), message = _U('buss_delbill'),
                    img = '/html/static/img/icons/business.png'})
            TriggerClientEvent("gksphone:client:billrefresh", src)
        else
            TriggerClientEvent('gksphone:notifi', src,
                {title = _U('bussines_title'), message = _U('buss_nodelbill'),
                    img = '/html/static/img/icons/business.png'})
        end
    end)
end)

RegisterNetEvent("gksphone:server:createbill", function(data)
    local src
    local biller = Config.Core.Functions.GetPlayer(source)
    if biller then
        if data.id then
            if src ~= data.id then
                local billed = Config.Core.Functions.GetPlayer(tonumber(data.id))
                if not billed then
                    TriggerClientEvent('gksphone:notifi', source, {title = _U('billing_title'), message = _U('bill_notplayer', data.id), img = '/html/static/img/icons/logo.png'})
                    return
                end
                local amount = tonumber(data.amount)
                if amount and amount > 0 then
                    MySQL.Async.execute('INSERT INTO gksphone_invoices (citizenid, amount, society, sender, sendercitizenid, label) VALUES (@citizenid, @amount, @society, @sender, @sendercitizenid, @label)'
                        , {
                            ['@citizenid'] = billed.PlayerData.citizenid,
                            ['@amount'] = amount,
                            ['@society'] = biller.PlayerData.job.name,
                            ['@sender'] = biller.PlayerData.charinfo.firstname .. ' ' .. biller.PlayerData.charinfo.lastname,
                            ['@sendercitizenid'] = biller.PlayerData.citizenid,
                            ['@label'] = data.fine
                        })

                    TriggerClientEvent('gksphone:notifi', source,
                        {title = _U('billing_title'), message = _U('bill_invosucss'),
                            img = '/html/static/img/icons/logo.png'})
                    TriggerClientEvent('gksphone:notifi', billed.PlayerData.source,
                        {title = _U('billing_title'), message = _U('bill_younewin'),
                            img = '/html/static/img/icons/logo.png'})

                    local webhookdata = {
                        receiverSrc = data.id,
                        receiverName = billed.PlayerData.charinfo.firstname .. ' ' .. billed.PlayerData.charinfo.lastname,
                        receiverID = billed.PlayerData.citizenid,
                        billingLabel = data.fine,
                        billingSociety = biller.PlayerData.job.name,
                        billingAmaount = amount,
                        senderName = biller.PlayerData.charinfo.firstname .. ' ' .. biller.PlayerData.charinfo.lastname,
                        senderID = biller.PlayerData.citizenid
                    }

                    TriggerEvent("gksphone:webhook:newbilling", webhookdata)


                else
                    TriggerClientEvent('gksphone:notifi', source,
                        {title = _U('billing_title'), message = _U('bill_amounterror'),
                            img = '/html/static/img/icons/logo.png'})
                end
            end
        elseif data.contact then
            local contact = data.contact
            local amount = tonumber(data.amount)

            if amount and amount > 0 then

                for k, l in pairs(contact) do
                    if l.number then
                        local number = l.number
                        local billed = Config.Core.Functions.GetPlayerByPhone(number)
                        if billed then
                            MySQL.Async.execute('INSERT INTO gksphone_invoices (citizenid, amount, society, sender, sendercitizenid, label) VALUES (@citizenid, @amount, @society, @sender, @sendercitizenid, @label)'
                                , {
                                    ['@citizenid'] = billed.PlayerData.citizenid,
                                    ['@amount'] = amount,
                                    ['@society'] = biller.PlayerData.job.name,
                                    ['@sender'] = biller.PlayerData.charinfo.firstname,
                                    ['@sendercitizenid'] = biller.PlayerData.citizenid,
                                    ['@label'] = data.fine
                                })

                            TriggerClientEvent('gksphone:notifi', source,
                                {title = _U('billing_title'), message = _U('bill_invosucss'),
                                    img = '/html/static/img/icons/logo.png'})
                            TriggerClientEvent('gksphone:notifi', billed.PlayerData.source,
                                {title = _U('billing_title'), message = _U('bill_younewin'),
                                    img = '/html/static/img/icons/logo.png'})

                            local webhookdata = {
                                receiverSrc = data.id,
                                receiverName = billed.PlayerData.charinfo.firstname .. ' ' .. billed.PlayerData.charinfo.lastname,
                                receiverID = billed.PlayerData.citizenid,
                                billingLabel = data.fine,
                                billingSociety = biller.PlayerData.job.name,
                                billingAmaount = amount,
                                senderName = biller.PlayerData.charinfo.firstname .. ' ' .. biller.PlayerData.charinfo.lastname,
                                senderID = biller.PlayerData.citizenid
                            }

                            TriggerEvent("gksphone:webhook:newbilling", webhookdata)

                        else
                            TriggerClientEvent('gksphone:notifi', source, {title = _U('billing_title'), message = _U('bill_notplayer', number), img = '/html/static/img/icons/logo.png'})

                        end
                    end
                end

            else
                TriggerClientEvent('gksphone:notifi', source, {title = _U('billing_title'), message = _U('bill_amounterror'), img = '/html/static/img/icons/logo.png'})
            end
        elseif data.airdrop then
            local airdrop = data.airdrop
            local amount = tonumber(data.amount)

            if amount and amount > 0 then
                for k, l in pairs(airdrop) do
                    if l.pid then
                        local bsrc = tonumber(l.pid)
                        local billed = Config.Core.Functions.GetPlayer(bsrc)
                        if billed then
                            MySQL.Async.execute('INSERT INTO gksphone_invoices (citizenid, amount, society, sender, sendercitizenid, label) VALUES (@citizenid, @amount, @society, @sender, @sendercitizenid, @label)'
                                , {
                                    ['@citizenid'] = billed.PlayerData.citizenid,
                                    ['@amount'] = amount,
                                    ['@society'] = biller.PlayerData.job.name,
                                    ['@sender'] = biller.PlayerData.charinfo.firstname,
                                    ['@sendercitizenid'] = biller.PlayerData.citizenid,
                                    ['@label'] = data.fine
                                })

                            TriggerClientEvent('gksphone:notifi', source,
                                {title = _U('billing_title'), message = _U('bill_invosucss'),
                                    img = '/html/static/img/icons/logo.png'})
                            TriggerClientEvent('gksphone:notifi', billed.PlayerData.source,
                                {title = _U('billing_title'), message = _U('bill_younewin'),
                                    img = '/html/static/img/icons/logo.png'})

                            local webhookdata = {
                                receiverSrc = data.id,
                                receiverName = billed.PlayerData.charinfo.firstname .. ' ' .. billed.PlayerData.charinfo.lastname,
                                receiverID = billed.PlayerData.citizenid,
                                billingLabel = data.fine,
                                billingSociety = biller.PlayerData.job.name,
                                billingAmaount = amount,
                                senderName = biller.PlayerData.charinfo.firstname .. ' ' .. biller.PlayerData.charinfo.lastname,
                                senderID = biller.PlayerData.citizenid
                            }

                            TriggerEvent("gksphone:webhook:newbilling", webhookdata)

                        else
                            TriggerClientEvent('gksphone:notifi', source, {title = _U('billing_title'), message = _U('bill_notplayer', bsrc), img = '/html/static/img/icons/logo.png'})

                        end
                    end
                end

            else
                TriggerClientEvent('gksphone:notifi', source, {title = _U('billing_title'), message = _U('bill_amounterror'), img = '/html/static/img/icons/logo.png'})
            end


        end
    end

end)


-- New Bill Export --
function NewBilling(source, label, society, senderBilling, senderID, amountt)
    local create = false
    local src = source
    local biller = Config.Core.Functions.GetPlayer(source)

    if biller then
        local amount = tonumber(amountt)
        if amount and amount > 0 then
            MySQL.Async.execute('INSERT INTO gksphone_invoices (citizenid, amount, society, sender, sendercitizenid, label) VALUES (@citizenid, @amount, @society, @sender, @sendercitizenid, @label)'
                , {
                    ['@citizenid'] = biller.PlayerData.citizenid,
                    ['@amount'] = amount,
                    ['@society'] = society,
                    ['@sender'] = senderBilling,
                    ['@sendercitizenid'] = senderID,
                    ['@label'] = label
                })
            local webhookdata = {
                receiverSrc = src,
                receiverName = biller.PlayerData.charinfo.firstname .. ' ' .. biller.PlayerData.charinfo.lastname,
                receiverID = biller.PlayerData.citizenid,
                billingLabel = label,
                billingSociety = society,
                billingAmaount = amount,
                senderName = "It was created by the system. " .. senderBilling,
                senderID = "system " .. senderID
            }
            TriggerClientEvent('gksphone:notifi', source, {title = _U('billing_title'), message = _U('bill_invosucss'), img = '/html/static/img/icons/logo.png'})
            TriggerEvent("gksphone:webhook:newbilling", webhookdata)
            create = true
        end

    end

    return create
end
exports("NewBilling", NewBilling)
