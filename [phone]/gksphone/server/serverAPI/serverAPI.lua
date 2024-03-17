Config.Core.Functions.CreateUseableItem('pink_phone', function(source)
  TriggerClientEvent('gks:server:use', source)
end)

Config.Core.Functions.CreateUseableItem('gold_phone', function(source)
  TriggerClientEvent('gks:server:use', source)
end)

Config.Core.Functions.CreateUseableItem('phone', function(source)
  TriggerClientEvent('gks:server:use', source)
end)


Config.Core.Functions.CreateUseableItem(Config.ChargeItemName, function(source, item)  -- Power Bank Item
  local src = source
  local Player = Config.Core.Functions.GetPlayer(src)
  if Player.Functions.RemoveItem(item.name, 1, item.slot) then
    TriggerClientEvent('gksphone:client:powerbank', src)
  end
end)

Config.Core.Functions.CreateCallback('gksphone:server:phone-check', function(source, cb)
  local xPlayer = Config.Core.Functions.GetPlayer(source)
  local cannotopenphone = false
  if not xPlayer then
    cb(nil)
    return
  end
  if xPlayer.PlayerData.metadata["isdead"] or xPlayer.PlayerData.metadata["inlaststand"] then
    cannotopenphone = true
  else
    cannotopenphone = false
  end
  if Config.UsableItem then
    for k, v in pairs(Config.ItemName) do
      if Config.OxInvetory then
        local items = exports.ox_inventory:GetItemCount(source, v)
        if items then
          cb(v, cannotopenphone)
          return
        end
      else
        local items = xPlayer.Functions.GetItemByName(v)
        if items ~= nil then
          if items.amount and items.amount > 0 then
            cb(v, cannotopenphone)
            return
          end
        end
      end
    end
    cb(nil, cannotopenphone)
    return
  else
    cb('phone', cannotopenphone)
    return
  end
end)

function ItemPhoneCheck(source)
  local xPlayer = Config.Core.Functions.GetPlayer(source)
  local cannotopenphone = false
  if xPlayer then
    if xPlayer.PlayerData.metadata["isdead"] or xPlayer.PlayerData.metadata["inlaststand"] then
      cannotopenphone = true
    else
      cannotopenphone = false
    end
    if Config.UsableItem then

      for k, v in pairs(Config.ItemName) do
        if Config.OxInvetory then
          local items = exports.ox_inventory:GetItemCount(source, v)
          if items then
            return true, cannotopenphone
          end
        else
          local items = xPlayer.Functions.GetItemByName(v)
          if items ~= nil then
            if items.amount and items.amount > 0 then
              return true, cannotopenphone
            end
          end
        end
      end
    else
      return true, cannotopenphone
    end
  else
    return false, cannotopenphone
  end

end

-- QB PHONE MAIL --

RegisterNetEvent('qb-phone:server:sendNewMail', function(mailData)
  if mailData.button then
    if mailData.button.enabled then
      mailData.button.enabled = nil
      mailData.button.buttonname = "Ok"
    else
      mailData.button = nil
    end
  end
	mailData.image = "/html/static/img/icons/mail.png"
	TriggerEvent('gksphone:NewMailqb', source, mailData)
end)

RegisterNetEvent('qb-phone:server:sendNewMailToOffline', function(cid, mailData)
  if mailData.button then
    if mailData.button.enabled then
      mailData.button.enabled = nil
      mailData.button.buttonname = "Ok"
    else
      mailData.button = nil
    end
  end
	mailData.image = "/html/static/img/icons/mail.png"
	TriggerEvent('gksphone:NewMailToOffline', cid, mailData)
end)





--- MUSIC ---

RegisterNetEvent('gksphone:server:musicAll', function(type, musicid, volume, loop, pos)
  if type == "volume" then
    TriggerClientEvent("gksphone:server:music", -1, type, source, nil, nil, volume)
  elseif type == "loop" then
    TriggerClientEvent("gksphone:server:music", -1, type, source, nil, nil, nil, loop)
  else
    TriggerClientEvent("gksphone:server:music", -1, type, source, musicid, pos, volume)
  end
end)




-- REGISTER COMMAND --

RegisterCommand('telfix', function(source)
  TriggerEvent('gksphone:gkssc:playerLoad', source)
end)

RegisterCommand('logi', function(source)
  TriggerClientEvent('gksphone:instologout', source)
end)

RegisterCommand('logt', function(source)
  TriggerClientEvent('gksphone:twlogout', source)
end)

RegisterCommand('logti', function(source)
  TriggerClientEvent('gksphone:tnlogout', source)
end)

Config.Core.Commands.Add(Config.TwitterVerifyCommand, 'Twitter Yellow Tick Approval', {{name = "auth", help = "true/false"}, {name = "AccountName", help = "Squawk Account Name"}}, true, function(source, args)
  local src = source
  if args[1] then
    local label = ""
    local first = true
    local auth = args[1]
    table.remove(args, 1)
    for i = 1, #args, 1 do
      if first then
        first = false
        label = label .. '' .. args[i]
      else
        label = label .. ' ' .. args[i]
      end
    end
    if auth == "true" then
      MySQL.Async.execute("UPDATE `gksphone_twt_users` SET `is_verified`= 2 WHERE username = @username", {
        ['@username'] = tostring(label)
      }, function (result)
        if (result == 1) then
          TwitterYellowTick(true, tostring(label))
          TriggerClientEvent(Config.CoreNotify, src, 'The user has been given a yellow tick.')
        else
          TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
        end
      end)
    else
      MySQL.Async.execute("UPDATE `gksphone_twt_users` SET `is_verified`= 0 WHERE username = @username", {
        ['@username'] = tostring(label)
      }, function (result)
        if (result == 1) then
          TwitterYellowTick(false, tostring(label))
          TriggerClientEvent(Config.CoreNotify, src, "User's yellow tick removed")
        else
          TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
        end
      end)
    end
  else
    TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
  end
end, 'god')


Config.Core.Commands.Add(Config.TwitterSendBanCommand, 'Twitter Accout Suspend', {{name = "auth", help = "true/false"}, {name = "AccountName", help = "Squawk Account Name"}}, true, function(source, args)
  local src = source
  if args[1] then
    local label = ""
    local first = true
    local auth = args[1]
    table.remove(args, 1)
    for i = 1, #args, 1 do
      if first then
        first = false
        label = label .. '' .. args[i]
      else
        label = label .. ' ' .. args[i]
      end
    end
    if auth == "true" then
      MySQL.Async.execute("UPDATE `gksphone_twt_users` SET `banned`= 1 WHERE username = @username", {
        ['@username'] = tostring(label)
      }, function (result)
        if (result == 1) then
          TwitterBannedUser(true, tostring(label))
          TriggerClientEvent(Config.CoreNotify, src, 'User banned')
        else
          TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
        end
      end)
    else
      MySQL.Async.execute("UPDATE `gksphone_twt_users` SET `banned`= 0 WHERE username = @username", {
        ['@username'] = tostring(label)
      }, function (result)
        if (result == 1) then
          TwitterBannedUser(false, tostring(label))
          TriggerClientEvent(Config.CoreNotify, src, "User ban lifted")
        else
          TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
        end
      end)
    end
  else
    TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
  end
end, 'god')

Config.Core.Commands.Add(Config.InstagramVerifyCommand, 'Blue Tick Approval', {{name = "auth", help = "true/false"}, {name = "AccountName", help = "SnapGram Account Name"}}, true, function(source, args)
  local src = source
  if args[1] then
    local label = ""
    local first = true
    local auth = args[1]
    table.remove(args, 1)
    for i = 1, #args, 1 do
      if first then
        first = false
        label = label .. '' .. args[i]
      else
        label = label .. ' ' .. args[i]
      end
    end
    if auth == "true" then
      MySQL.Async.execute("UPDATE `gksphone_insto_accounts` SET `averify`= 1 WHERE gksphone_insto_accounts.username = @username", {
        ['@username'] = tostring(label)
      }, function (result)
        if (result == 1) then
          TriggerClientEvent(Config.CoreNotify, src, 'The user has been given a blue tick.')
        else
          TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
        end
      end)
    else
      MySQL.Async.execute("UPDATE `gksphone_insto_accounts` SET `averify`= 0 WHERE gksphone_insto_accounts.username = @username", {
        ['@username'] = tostring(label)
      }, function (result)
        if (result == 1) then
          TriggerClientEvent(Config.CoreNotify, src, 'The user has been given a blue tick.')
        else
          TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
        end
      end)
    end
  else
    TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
  end
end, 'god')

Config.Core.Commands.Add(Config.AdvertisingSendBlockCommand, 'Turn off/on Message Sending', {{name = "auth", help = "true/false"}}, true, function(source, args)
  local src = source
  if args[1] then
    local label = ""
    local first = true
    local auth = args[1]
    if auth == "true" then
      AdvertisingMessageBlock = true
    else
      AdvertisingMessageBlock = false
    end
  else
    TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
  end
end, 'god')

Config.Core.Commands.Add(Config.TwitterSendBlockCommand, 'Turn off/on Message Sending', {{name = "auth", help = "true/false"}}, true, function(source, args)
  local src = source
  if args[1] then
    local label = ""
    local first = true
    local auth = args[1]
    if auth == "true" then
      TwitterMessageBlock = true
    else
      TwitterMessageBlock = false
    end
  else
    TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
  end
end, 'god')



Config.Core.Commands.Add(Config.InstagramSendBlockCommand, 'Turn off/on Message Sending', {{name = "auth", help = "true/false"}}, true, function(source, args)
  local src = source
  if args[1] then
    local label = ""
    local first = true
    local auth = args[1]
    if auth == "true" then
      InstagramMessageBlock = true
    else
      InstagramMessageBlock = false
    end
  else
    TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
  end
end, 'god')

Config.Core.Commands.Add(Config.NewNumberChange, 'Change your players phone number', {{name = "id", help = "player id"}, {name = "newNumber", help = "New Phone Number"}}, true, function(source, args)
  local src = source
  if args[1] then
    local psource = args[1]
    local newNumber = args[2]
    local newPhone = exports["gksphone"]:NumberChange(psource, newNumber)
    if newPhone then
      TriggerClientEvent(Config.CoreNotify, src, 'The player phone number has changed. Player must exit the game and re-enter', 'error')
    else
      TriggerClientEvent(Config.CoreNotify, src, 'The player phone number could not be changed. The player phone number may be in use by someone else', 'error')
    end
  else
    TriggerClientEvent(Config.CoreNotify, src, 'You did not write the required information', 'error')
  end
end, 'god')

-- REGISTER COMMAND --

--- WEBHOOKS ---
RegisterServerEvent('gksphone:jobnotif')
AddEventHandler('gksphone:jobnotif', function(name, number, message, photo, jobm, identifier, new, name2)

  local discord_webhook = Cfg.JobNotif
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end

  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = 'Job Notif',
    ["avatar_url"] = 'https://media.discordapp.net/attachments/722981093455822958/882974778334523392/stock-market.png?width=480&height=480',
    ["embeds"] = { {
      ["color"] = 15258703
    } }
  }
  local isHttp = string.sub(photo, 0, 7) == 'http://' or string.sub(photo, 0, 8) == 'https://'
  local ext = string.sub(photo, -4)
  local isImg = ext == '.png' or ext == '.jpg' or ext == '.gif' or string.sub(photo, -5) == '.jpeg'

  if new == 1 then
    data['embeds'][1]['title']       = '[' .. name .. ']  Occupation Notification : ' .. jobm
    data['embeds'][1]['image']       = { ['url'] = photo }
    data['embeds'][1]['description'] = 'Message : ' .. message
    data['embeds'][1]['footer']      = { ['text'] = ' [Number : ' .. number .. ', identifier : ' .. identifier .. ']' }
  end
  if new == 0 then
    data['embeds'][1]['title']       = '[' .. name2 .. '] Incoming Problem Solved : ' .. jobm
    data['embeds'][1]['image']       = { ['url'] = photo }
    data['embeds'][1]['description'] = 'Message : ' .. message
    data['embeds'][1]['footer']      = { ['text'] = '[Name : ' .. name .. ' ,Number : ' .. number .. ']' }
  end
  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

RegisterServerEvent('gksphone:cryptobuysellwebhook')
AddEventHandler('gksphone:cryptobuysellwebhook', function(test, test2, identifier, adet, coin, color, name, transferto, name2)
  local discord_webhook = Cfg.Crypto
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end

  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = 'Stock Market',
    ["avatar_url"] = 'https://seeklogo.com/images/C/cryptocurrency-blockchain-logo-249415523F-seeklogo.com.png',
    ["embeds"] = { {
      ["color"] = color
    } }
  }

  if test == 'purchased' or test == 'sold' then
    data['embeds'][1]['title'] = '[' .. name .. '] has ' .. test .. ' x' .. tonumber(adet) .. ' of ' .. coin .. '! Worth: $' .. test2 .. '!'
    data['embeds'][1]['description'] = '[' .. name .. '] [' .. identifier .. ']'
  end
  if test == 'transfer' then
    data['embeds'][1]['title'] = '[' .. name .. '] transferred  x' .. test2 .. ' ' .. coin .. ' to ' .. name2 .. ' [' .. transferto .. ']'
    data['embeds'][1]['description'] = '[' .. name .. '] [' .. identifier .. ']'
  end


  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

RegisterServerEvent('gksphone:cryptotranwebhook')
AddEventHandler('gksphone:cryptotranwebhook', function(name, test2, coin, name2, transferto, identifier)
  local discord_webhook = Cfg.Crypto
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end

  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = 'Stock Market',
    ["avatar_url"] = 'https://seeklogo.com/images/C/cryptocurrency-blockchain-logo-249415523F-seeklogo.com.png',
    ["embeds"] = { {
      ["color"] = color
    } }
  }



  data['embeds'][1]['title'] = '[' .. name .. '] transferred  x' .. tonumber(test2) .. ' ' .. coin .. ' to ' .. name2 .. ' [' .. transferto .. ']'
  data['embeds'][1]['description'] = '[' .. name .. '] [' .. identifier .. ']'



  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

RegisterServerEvent('gksphone:carsellernew')
AddEventHandler('gksphone:carsellernew', function(a, name2, bidentifier, name, b, c)

  local discord_webhook = Cfg.Carseller
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end

  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = 'Car Seller',
    ["avatar_url"] = 'https://media.discordapp.net/attachments/722981093455822958/882974778334523392/stock-market.png?width=480&height=480',
    ["embeds"] = { {
      ["color"] = 15258703
    } }
  }


  data['embeds'][1]['title']       = '[' .. name .. ']' .. bidentifier .. ' Sold Vehicle'
  data['embeds'][1]['description'] = 'Car license plate : ' .. b .. ' Sale price : ' .. c
  data['embeds'][1]['footer']      = { ['text'] = 'The person who bought the vehicle : [' .. name2 .. ', identifier : ' .. a .. ']' }


  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

AddEventHandler('gksphone:newcarseller', function(identifier, phonenumber, plate, model, price, image)

  local discord_webhook = Cfg.NewCarSeller
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }

  local data = {
    ["username"] = "New Car Post",
    ["avatar_url"] = "https://media.discordapp.net/attachments/722981093455822958/882974778334523392/stock-market.png?width=480&height=480",
    ["embeds"] = { {
      ["color"] = 1942002
    } }
  }

  data['embeds'][1]['title'] = identifier .. "[" ..phonenumber.." ] " .." Published a new vehicle ad"
  data['embeds'][1]['image'] = { ['url'] = image }
  data['embeds'][1]['description'] = "Model : "..model .. "\nPlate :" ..plate.. "\nPrice :" ..price

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

RegisterServerEvent('gksphone:insto_newinstas')
AddEventHandler('gksphone:insto_newinstas', function(inap, src)
  local discord_webhook = Cfg.InstagramWeb
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end
  local license, steam, xbl, discord, live, fivem = '', '', '', '', '', ''
  local name = GetPlayerName(src)
  for k, v in pairs(GetPlayerIdentifiers(src)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif string.sub(v, 1, string.len('xbl:')) == 'xbl:' then
      xbl = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif string.sub(v, 1, string.len('live:')) == 'live:' then
      live = v
    elseif string.sub(v, 1, string.len('fivem:')) == 'fivem:' then
      fivem = v
    end
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }

  if inap.authorIcon == "/html/static/img/icons/valeuser.png" then
    inap.authorIcon = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Instagram-Icon.png/800px-Instagram-Icon.png"
  end

  local data = {
    ["username"] = inap.username,
    ["avatar_url"] = inap.authorIcon,
    ["embeds"] = { {
      ["color"] = 1942002
    } }
  }

  data['embeds'][1]['title'] = inap.forename .. " The user posted a new post!"
  data['embeds'][1]['image'] = { ['url'] = inap.image }

  if not Cfg.PlayerInfo then
    data['embeds'][1]['description'] = inap.message
  else
    if discord ~= nil then
      data['embeds'][1]['description'] = inap.message ..'\n**Name:** : ' .. name .. '\n  **Hex ID:** : ' .. license .. '\n  **Steam:**' .. steam .. '\n**Discord:** <@' .. string.sub(discord, 9) .. '>' .. '\n **Game ID:** ' .. src
    else
      data['embeds'][1]['description'] =  inap.message .. '\n**Name:** : ' .. name .. '\n  **Hex ID:** : ' .. license .. '\n  **Steam:**' .. steam .. '\n **Game ID:** ' .. src
    end
  end

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

RegisterServerEvent('gksphone:twitter_newTweets')
AddEventHandler('gksphone:twitter_newTweets', function(tweetData, source, TweetUserData, tweetType, pollTime)
  local src = source
  local discord_webhook = Cfg.TwitterWeb
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end
  local license, steam, xbl, discord, live, fivem = '', '', '', '', '', ''
  local name = GetPlayerName(src)
  for k, v in pairs(GetPlayerIdentifiers(src)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif string.sub(v, 1, string.len('xbl:')) == 'xbl:' then
      xbl = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif string.sub(v, 1, string.len('live:')) == 'live:' then
      live = v
    elseif string.sub(v, 1, string.len('fivem:')) == 'fivem:' then
      fivem = v
    end
  end



  local headers = {
    ['Content-Type'] = 'application/json'
  }

  if TweetUserData.avatar == "/html/static/img/icons/valeuser.png" then
    TweetUserData.avatar = "https://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png"
  end

  local data = {
    ["embeds"] = {{
      ["title"] = "There is a new post",
      ["description"] = tweetData.content,
      ["url"] = TweetUserData.avatar,
      ["color"] = 5814783,
      ["author"] = {
        ["name"] = TweetUserData.username
      },
      ["fields"] = {}
    }},
    ["username"] = TweetUserData.username,
    ["avatar_url"] = TweetUserData.avatar,
  }

  if tweetType == "postpoll" then
    local pollId = 1
    data['embeds'][1]['fields'][#data['embeds'][1]['fields'] + 1] = {
      ["name"] = "Started a Poll",
      ["value"] = ""
    }

      for i, item in ipairs(tweetData.poll_options) do
          for key, value in pairs(item) do
              data['embeds'][1]['fields'][1]["value"] = data['embeds'][1]['fields'][1]["value"] ..'\n'..pollId ..'. '..key
              pollId += 1
          end
      end

      data['embeds'][1]['fields'][1]["value"] = data['embeds'][1]['fields'][1]["value"]..'\n\nPoll end time : ' ..pollTime

  end
  if type(tweetData.media) == "table" then
    for k, l in pairs(tweetData.media) do
      if k == 1 then
        data['embeds'][1]['image'] = {
          ["url"] = l
        }
      else
        data['embeds'][k] = {
          ["url"] = TweetUserData.avatar,
          ["image"] = {
            ["url"] = l
          }
        }
      end
    end
  end

  if Cfg.PlayerInfo then
    data['embeds'][1]['fields'][#data['embeds'][1]['fields'] + 1] = {
      ["name"] = "Character Info",
      ["value"] = '\n**Name:** : ' .. name .. '\n**Hex ID:** : ' .. license .. '\n **Steam:**' .. steam .. '\n**Game ID:** ' .. src..'\n**Identifier:** :' ..TweetUserData.identifier
    }
  end

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

RegisterServerEvent('gksphone:yellow_newPagess')
AddEventHandler('gksphone:yellow_newPagess', function(pages, src)

  local discord_webhook = Cfg.YellowWeb
  if discord_webhook == 'DISCORD WEBHOOK' and pages == nil then
    return
  end
  local license, steam, xbl, discord, live, fivem = '', '', '', '', '', ''
  local name = GetPlayerName(src)
  for k, v in pairs(GetPlayerIdentifiers(src)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif string.sub(v, 1, string.len('xbl:')) == 'xbl:' then
      xbl = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif string.sub(v, 1, string.len('live:')) == 'live:' then
      live = v
    elseif string.sub(v, 1, string.len('fivem:')) == 'fivem:' then
      fivem = v
    end
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = pages.firstname,
    ["embeds"] = { {
      ["color"] = 1942002
    } }
  }

  data['embeds'][1]['title'] = pages.firstname .. " The user posted a new post!"
  data['embeds'][1]['image'] = { ['url'] = pages.image }

  if not Cfg.PlayerInfo then
    data['embeds'][1]['description'] = pages.message
  else
    if discord ~= nil then
      data['embeds'][1]['description'] = pages.message ..'\n**Name:** : ' .. name .. '\n  **Hex ID:** : ' .. license .. '\n  **Steam:**' .. steam .. '\n**Discord:** <@' .. string.sub(discord, 9) .. '>' .. '\n **Game ID:** ' .. src
    else
      data['embeds'][1]['description'] =  pages.message .. '\n**Name:** : ' .. name .. '\n  **Hex ID:** : ' .. license .. '\n  **Steam:**' .. steam .. '\n **Game ID:** ' .. src
    end
  end

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

function MessagesWebhook(source, transmitter, receiver, message, cid)

  local license, steam, xbl, discord, live, fivem = '', '', '', '', '', ''
  local name = GetPlayerName(source)

  for k, v in pairs(GetPlayerIdentifiers(source)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif string.sub(v, 1, string.len('xbl:')) == 'xbl:' then
      xbl = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif string.sub(v, 1, string.len('live:')) == 'live:' then
      live = v
    elseif string.sub(v, 1, string.len('fivem:')) == 'fivem:' then
      fivem = v
    end
  end


  local discord_webhook = Cfg.MessageWeb
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end

  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = 'Message APP',
    ["embeds"] = { {
      ["color"] = 15258703
    } }
  }

  local decst = "**Message Sender** :" .. transmitter .. " **Message Recipient** :" .. receiver .. "\n **Message** :" .. message

  data['embeds'][1]['title'] = 'Messages APP'
  if discord ~= nil then
    data['embeds'][1]['description'] = '**Name:** : ' .. name .. '\n  **Citizen ID:** : ' .. cid .. '\n  **Steam:**' .. steam .. '\n**Discord:** <@' .. string.sub(discord, 9) .. '>' .. '\n **Game ID:** ' .. source .. '\n **Detail:** ' .. decst
  else
    data['embeds'][1]['description'] = '**Name:** : ' .. name .. '\n  **Citizen ID:** : ' .. cid .. '\n  **Steam:**' .. steam .. '\n **Game ID:** ' .. source .. '\n **Detail:** ' .. decst
  end

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)

end

function CallWebhook(transmitter, receiver, source, cid)

  local license, steam, xbl, discord, live, fivem = '', '', '', '', '', ''
  local name = GetPlayerName(source)

  for k, v in pairs(GetPlayerIdentifiers(source)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif string.sub(v, 1, string.len('xbl:')) == 'xbl:' then
      xbl = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif string.sub(v, 1, string.len('live:')) == 'live:' then
      live = v
    elseif string.sub(v, 1, string.len('fivem:')) == 'fivem:' then
      fivem = v
    end
  end


  local discord_webhook = Cfg.CallWebhook
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end

  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = 'Calling',
    ["embeds"] = { {
      ["color"] = 15258703
    } }
  }

  local decst = "**Caller** :" .. transmitter .. " **Receiver** :" .. receiver .. "\n "

  data['embeds'][1]['title'] = 'Calling'
  if discord ~= nil then
    data['embeds'][1]['description'] = '**Name:** : ' .. name .. '\n  **Citizen ID:** : ' .. cid .. '\n  **Steam:**' .. steam .. '\n**Discord:** <@' .. string.sub(discord, 9) .. '>' .. '\n **Game ID:** ' .. source .. '\n **Detail:** ' .. decst
  else
    data['embeds'][1]['description'] = '**Name:** : ' .. name .. '\n  **Citizen ID:** : ' .. cid .. '\n  **Steam:**' .. steam .. '\n **Game ID:** ' .. source .. '\n **Detail:** ' .. decst
  end

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)

end

function BankTrasnfer(name, identifier1, amount, name2, identifier2)
  local discord_webhook = Cfg.BankTransfer
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end

  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = 'Bank Transfer',
    ["avatar_url"] = 'https://www.futurebrand.com/uploads/case-studies/_heroImage/3-NatWest-New-Logo.jpg',
    ["embeds"] = { {
      ["color"] = color
    } }
  }

  data['embeds'][1]['title'] = "[**" .. name .. "**] has transferred [**£" .. amount .. "**] to [**" .. name2 .. "**]."
  data['embeds'][1]['description'] = "[**" .. name .. "**]" .. "**[" .. identifier1 .. "**]" .. "\n" .. "[**" .. name2 .. "**]" .. "[**" .. identifier2 .. "**]"

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end

RegisterServerEvent('gksphone:server:racecreateweb')
AddEventHandler('gksphone:server:racecreateweb', function(races, source)

  if races[1] then
    local license, steam, discord = '', '', ''
    local name = GetPlayerName(source)

    for k, v in pairs(GetPlayerIdentifiers(source)) do
      if string.sub(v, 1, string.len('license:')) == 'license:' then
        license = v
      elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
        steam = v
      elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
        discord = v
      end
    end

    local discord_webhook = Cfg.RaceCreate
    if discord_webhook == 'DISCORD WEBHOOK' then
      return
    end
    local headers = {
      ['Content-Type'] = 'application/json'
    }
    local data = {
      ["username"] = "Race Create",
      ["embeds"] = { {
        ["color"] = 1942002
      } }
    }



    data['embeds'][1]['title'] = "Race Create | Race ID: " .. races[1].RaceId .. " | Race Amount : " .. races[1].raceamount
    if discord ~= nil then
      data['embeds'][1]['description'] = '**Name:** : ' .. name .. '\n  **Hex ID:** : ' .. license .. '\n  **Steam:**' .. steam .. '\n**Discord:** <@' .. string.sub(discord, 9) .. '>' .. '\n **Game ID:** ' .. source .. '\n '
    else
      data['embeds'][1]['description'] = '**Name:** : ' .. name .. '\n  **Hex ID:** : ' .. license .. '\n  **Steam:**' .. steam .. '\n **Game ID:** ' .. source .. '\n '
    end

    PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
  end

end)

RegisterServerEvent('gksphone:server:racekazancwebhook')
AddEventHandler('gksphone:server:racekazancwebhook', function(races)

  local discord_webhook = Cfg.RaceWinning
  if races[1] then
    local label = " **Race fee** : " .. races[1].raceamount .. " **Race Checkpoint** : " .. races[1].checkpoint .. " **Race Lap** : " .. races[1].lap .. '\n '
    if discord_webhook == '' then
      return
    end
    local headers = {
      ['Content-Type'] = 'application/json'
    }
    local data = {
      ["username"] = "Race winnings",
      ["embeds"] = { {
        ["color"] = 1942002
      } }
    }

    for k, l in pairs(races) do
      label = label .. '**Source** :' .. l.identifier .. ', **Identifier** :' .. l.steamidentifier .. ', **Race Name** :' .. l.player_name .. ', **Winnings** : ' .. l.kazanc .. '\n '
    end

    data['embeds'][1]['title'] = "Race winnings Race ID:" .. races[1].raceid
    data['embeds'][1]['description'] = label

    PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
  end
end)

RegisterNetEvent('gksphone:exploitwebhook', function(source, app, decst)
  local license, steam, xbl, discord, live, fivem = '', '', '', '', '', ''
  local name = GetPlayerName(source)
  if name == nil then
    return
  end
  for k, v in pairs(GetPlayerIdentifiers(source)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif string.sub(v, 1, string.len('xbl:')) == 'xbl:' then
      xbl = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif string.sub(v, 1, string.len('live:')) == 'live:' then
      live = v
    elseif string.sub(v, 1, string.len('fivem:')) == 'fivem:' then
      fivem = v
    end
  end


  local discord_webhook = Cfg.ExploitWebhook
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end

  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = 'Car Seller',
    ["avatar_url"] = 'https://media.discordapp.net/attachments/722981093455822958/882974778334523392/stock-market.png?width=480&height=480',
    ["embeds"] = { {
      ["color"] = 15258703
    } }
  }


  data['embeds'][1]['title'] = '[' .. app .. ']' .. ' Tried to exploit'
  if discord ~= nil then
    data['embeds'][1]['description'] = '**Name:** : ' .. name .. '\n  **Hex ID:** : ' .. license .. '\n  **Steam:**' .. steam .. '\n**Discord:** <@' .. string.sub(discord, 9) .. '>' .. '\n **Game ID:** ' .. source .. '\n **Detail:** ' .. decst
  else
    data['embeds'][1]['description'] = '**Name:** : ' .. name .. '\n  **Hex ID:** : ' .. license .. '\n  **Steam:**' .. steam .. '\n **Game ID:** ' .. source .. '\n **Detail:** ' .. decst
  end

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

function JobAppWebhook(source, process, data)
  local discord_webhook = Cfg.JobApplication
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end
  local license, steam, xbl, discord, live, fivem = '', '', '', '', '', ''
  local name = GetPlayerName(source)
  for k, v in pairs(GetPlayerIdentifiers(source)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif string.sub(v, 1, string.len('xbl:')) == 'xbl:' then
      xbl = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif string.sub(v, 1, string.len('live:')) == 'live:' then
      live = v
    elseif string.sub(v, 1, string.len('fivem:')) == 'fivem:' then
      fivem = v
    end
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local datatest = nil
  if process == "submit" then
    datatest = {
      ["username"] = 'GKSPHONE',
      ["avatar_url"] = 'https://gkshop.org/images/gkshop.png',
      ["embeds"] = {
        {
          ["title"] = "GKSPHONE",
          ["description"] = "Job application",
          ["color"] = 15258703,
          ["fields"] = {
              {
                  ["name"] = "Information of the person applying for the job",
                  ["value"] = "Steam Name : **"..name.."**\nLicense : **".. license .."**\nSteam : **".. steam.."**\nDiscord : **"..discord.."**\nPlayer ID : **"..source
              },
              {
                  ["name"] = "In-game player information",
                  ["value"] = "Character name : ** " .. data.sender .. " **\nPhone Number : ** " ..data.phoneNumber .."**\nCitizienId/Identifier : **"..data.cid
              },
              {
                  ["name"] = "Business unit applied for",
                  ["value"] = data.jobname
              }
          },
          ["footer"] = {
            ["text"] = "© Copyright 2022 GKSHOP"
          },
          ["thumbnail"] = {
            ["url"] = "https://gkshop.org/images/gkshop.png"
          }
        }
      }
    }
  end


  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(datatest), headers)
end

RegisterServerEvent('gksphone:webhook:news')
AddEventHandler('gksphone:webhook:news', function(pages)

  local discord_webhook = Cfg.NewsWebook
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = "News",
    ["embeds"] = { {
      ["color"] = 1942002
    } }
  }

  data['embeds'][1]['title'] = pages.baslik
  data['embeds'][1]['image'] = { ['url'] = pages.resim }
  data['embeds'][1]['description'] = pages.haber

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

RegisterServerEvent('gksphone:webhook:newbilling')
AddEventHandler('gksphone:webhook:newbilling', function(data)

  local discord_webhook = Cfg.NewBilling
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = "New Billing",
    ["embeds"] = {
      {
        ["color"] = 1942002,
        ['title'] = "New billing",
        ['description'] = '**Created by:**' ..data.senderName.. '**('..data.senderID.. ')**\n**Receiver:**' ..data.receiverName.. '**(' ..data.receiverID.. ')**\n**Billing Reason:**' ..data.billingLabel.. '\n**Billing Amount:**' ..data.billingAmaount
      }
    }
  }

  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

RegisterServerEvent('gksphone:webhook:livedonate')
AddEventHandler('gksphone:webhook:livedonate', function(xPlayer, yPlayer, DonatePrice, DonateCommision)
  local discord_webhook = Cfg.LiveDonate
  if discord_webhook == 'DISCORD WEBHOOK' then
    return
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = "LiveAPP Donate",
    ["embeds"] = {
      {
        ["color"] = 1942002,
        ['title'] = "LiveAPP Donate",
        ['description'] = '**Donation person:** ' ..xPlayer.PlayerData.source.. ' **['..xPlayer.PlayerData.citizenid..']**' ..'\n**Streamer:** ' ..yPlayer.PlayerData.source.. ' **['..yPlayer.PlayerData.citizenid..']**' ..'\n**Amount donated:** '.. DonatePrice .. '\n**Deducted Commission Amount:** ' .. (DonatePrice - DonateCommision.. '\n**Streamer earning:** '..DonateCommision)
      }
    }
  }
  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)



--- WEBHOOKS ---
