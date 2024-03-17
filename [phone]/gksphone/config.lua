Config = Config or {}

--- ### Framework Settings ### ---

Config.QBCoreNewversion = true

if Config.QBCoreNewversion then
    Config.CoreName = "QBCore"
    Config.Core = exports['qb-core']:GetCoreObject()
    Config.CoreNotify = "QBCore:Notify"
else
    Config.CoreName = "QBCore:GetObject"
    Config.Core = nil
    TriggerEvent(Config.CoreName, function(obj) Config.Core = obj end)
    Config.CoreNotify = "QBCore:Notify"
end

--- ### Phone settings ### ---

Config.KeyMapping       = true                 --## This setting is for those using slotted inventory. (Prevents key operation)
Config.OpenPhone        = 'f1'                 --## Phone open key ## https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
Config.Locale           = 'en'
Config.RegisterCommand  = "TooglePhone"        -- commandName
Config.ItemName         = {           -- # item name
                            "phone",
                            "pink_phone",
                            "gold_phone"
                        }
Config.ChargeItemName   = "powerbank"           --- PowerBank Item Name
Config.PropActive       = true
Config.CryptoName       = "qbit"
Config.HospitalAmbulanceAlert = false
Config.Fahrenheit       = false
Config.EyeTarget        = false                 -- required qb-target (You can use it for contacts sharing and phone booth)
Config.TargetExport     = "qb-target"           -- exports["qb-target"]  -- Resource Name
Config.UsableItem       = true                  -- If you want to use without items set it to false
Config.OxInvetory       = false                 -- Set to true if you are using Ox Inventory
Config.AirDropID        = false                -- Activate the AirDrop feature if you want the player to see the ID.
Config.AutoMessageDelete    = true             -- Automatically deletes messages (Messages,Mail,Group Messages,Tinder Messages,Advertising)
Config.AutoDeleteTime       = 4                -- How many days ago you want to delete data
Config.AutoWantedTime       = 4                -- How many days ago you want to delete data (Automatic deletion of wanted people in MDT application after how many days if deletion is forgotten)
Config.WaitPhone            = 2                -- Cycle time when phone is on
Config.Signal               = true             -- Signal system (phone downtime in some areas)

--- ### Voice settings ### ---

Config.MumbleExport     = "mumble-voip"       -- exports["mumble-voip"] -- Resource Name
Config.PMAVoiceExport   = "pma-voice"         -- exports["pma-voice"]   -- Resource Name
Config.PMAVoice         = true               -- Use Pma-Voice Resource (Recomended!) https://github.com/AvarianKnight/pma-voice
Config.UseMumbleVoIP    = false               -- Use Frazzle's Mumble-VoIP Resource https://github.com/FrazzIe/mumble-voip
Config.UseTokoVoIP      = false
Config.SaltyChat        = false               -- SaltyChat (Only v2.6 and lower | Not tested in v2.6 higher versions)

--- ## CALL COMMAND ### ---
Config.OnlineContactPlayers = false    -- Activate to see active players in the contacts
Config.CallAnswer = "answer"  -- quick answer (registercommand)
Config.EndCall = "endcall"  -- to close call (registercommand)

Config.SpecificNumberOn = false  --- If you want the SpecificNumber function to work, enable it
 -- When this number is called the trigger on the doc page will work.
 -- server : https://docs.gkshop.org/gksphone/developers/server-event#specific-number
 -- client : https://docs.gkshop.org/gksphone/developers/client-event#specific-number
Config.SpecificNumber = {
    ["5555555"] = true
}



-- ### TAXI APP ### ---
Config.TaxiPrice        = 75     -- Taxi Price ( 75$/KM )
Config.TaxiJobCode      = "taxi"  -- Job Code

-- ### House APP ### ---
Config.loafHouse        = false   -- Activate if you are using Loaf House (https://store.loaf-scripts.com/package/4310850)
Config.bcs_housing      = false   -- Activate if you are using BCS Housing (https://masbagus.tebex.io/package/5090952)

-- ### BANK APP ### ---
Config.BankTransferCom      = 10     -- Bank transfer commission rate
Config.OfflineBankTransfer  = true

---### Dispatch ### ---

-- cd_dispatch => Codesign Dispatch (https://codesign.pro/package/4206357)
-- ps-dispatch => Project-Sloth (https://github.com/Project-Sloth/ps-dispatch)
Config.Dispatch       = ""

-- ### GARAGE APP ### ---
Config.qbGarages        = true   -- Set to false if you are not using qb-garages
Config.cdGarages        = false  -- Activate if you are using Codesign Garage (https://codesign.pro/package/4206352)
Config.loafGarages      = false  -- Activate if you are using Loaf Garage (https://store.loaf-scripts.com/package/4310876)

Config.OwnedVehicles    = "player_vehicles"   -- ## SQL TABLE NAME (VEHICLES)
Config.ValespawnRadius  = 170.0   -- Distance to spaw your car
Config.ValePrice        = 100    -- Vale Price
Config.ValeNPC          = true   -- Activate if you want the valet to bring the car to you.
Config.ImpoundVale      = true   -- Set to true to not fetch impounded cars

Config.ClassList = {
    [0] = "Compact",
    [1] = "Sedan",
    [2] = "SUV",
    [3] = "Coupe",
    [4] = "Muscle",
    [5] = "Sport Classic",
    [6] = "Sport",
    [7] = "Super",
    [8] = "Motorbike",
    [9] = "Off-Road",
    [10] = "Industrial",
    [11] = "Utility",
    [12] = "Van",
    [13] = "Bike",
    [14] = "Boat",
    [15] = "Helicopter",
    [16] = "Plane",
    [17] = "Service",
    [18] = "Emergency",
    [19] = "Military",
    [20] = "Commercial",
    [21] = "Train"
}
Config.Carhashdebug = false  -- car hash (f8)

-- ### CAR SELLER ### ---

Config.OfflineCarSeller = false
Config.DefaultGarage = "pillboxgarage"  -- The garage where the car will go when a car is purchased
Config.CarsellerTax = 10

Config.CarsSellerBlacklist = {
    [-16948145] = false, -- car hash and true/false
    [1234311532] = false
}

Config.CarSellerClassBlock = {
    ["Emergency"] = true,
    ["Super"] = false
}




-- ### Advertising APP ### ---
Config.AdvertisingPrice = 300
Config.AdvertisingSendBlockCommand = "blockAdd" -- (/blockAdd true/false)

-- ### Twitter APP ### ---
Config.TwitterVerifyCommand = "twitterverify"   -- (/twitterverify true/false username) yellow tick
Config.TwitterSendBlockCommand = "blocktwitter" -- (/blockTwitter true/false)
Config.TwitterSendBanCommand = "bantwitter" -- (/bantwitter true/false username)
Config.TwitterSubsDate = 5 -- Twitter subs subscription renewal time
Config.TwitterSubsPay = 15 -- Twitter Subscription fee

-- ### Instagram APP ### ---
Config.InstagramVerifyCommand = "instagramverify"  -- (/instagramverify true/false username)
Config.InstagramSendBlockCommand = "blockInstagram" -- (/blockInstagram true/false)

-- ### Race APP ### ---
Config.RaceAutCommand = "raceaut"
Config.qbcoreaut = "god"  --- qb-core authorization system

-- ### Charge ### --- (/charge playerid charge(0-100))
Config.ChargeAutCommand = "charge"
Config.qbcorechargeaut = "god"  --- qb-core authorization system

-- ### Number Change ### ---
Config.NewNumberChange = "phonenumberchange" -- /phonenumberchange playerid newnumber


-- ## PHONE Box -- ##

Config.PhoneBox = true
Config.PhoneBoxKey = "E"
Config.PhoneBoxRegCom = "phonebox"
Config.PhoneBoothMoney = { actived = true, money = 500 }
Config.PhoneBoothModel = {
	[1281992692] = true,
    [1158960338] = true,
    [295857659] = true,
    [-78626473] = true,
    [-2103798695] = true,
    [1511539537] = true,
    [-1559354806] = true
}
Config.PhoneBootNumber = "22222"



--## Crypto ##--


-- Cryptos to use
-- You can add or turn off any crypto you want. (https://api.coingecko.com/api/v3/coins/list?include_platform=false) Crypto list that can be added
-- The id option will be the first value, and the second value will be true or false.
Config.Crytos = {
    ["bitcoin"] = true,
    ["ethereum"] = true,
    ["tether"] = true,
    ["binance-usd"] = true,
    ["uniswap"] = true,
    ["binancecoi"] = true,
    ["terra-luna"] = true,
    ["avalanche-2"] = true,
    ["cardano"] = true,
    ["ripple"] = true,
    ["usd-coin"] = true,
    ["dogecoin"] = true,
    ["litecoin"] = true,
    ["chainlink"] = true,
    ["stellar"] = true,
    ["tron"] = true,
    ["eos"] = true,
    ["monero"] = true,
    ["iota"] = true
}

---##  Spam ## ---

Config.SpamLimit = 6  -- Default: 6
Config.SpamReset = 10  -- seconds
Config.SpamPlayerKick = true
Config.SpamDropPlayer = "You were kicked from the server for spamming too much"


-- ### Business APP ### ---

-- JOBs that will use the Business APP
Config.UseBusinessJobs = {
    mechanic = true,
    ambulance = true,
    police = true
}


Config.UseBillingCommission = true  -- Invoice commission true/false
-- This is a percentage (0.10) == 10% ( Must be active to receive commission - If the player is not in the game, she/he cannot receive a commission.)
Config.BillingCommissions = {
    mechanic = 0.10,
    police = 0.20
}


-- People who can use the application at a high level (jobs and lowest rank)
Config.JobGrade  = {
    ["police"] = 3,
    ["ambulance"] = 2,
    ["mechanic"] = 2
}


--- ## Live APP --- ##

Config.LiveAPPDonateTax = 0.20 -- deduction rate from incoming money