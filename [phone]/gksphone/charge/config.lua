ChargeOn = true
ChargeEndCommand = "endcharge"  ---command used to finish charging
ChargeBlipOn = true  --- To see the blips of the charging stations
PowerBankFillingTime = 10 -- seconds
PowerBank = 1  -- Adjust this part how much you want to fill in how many seconds

NormalChargingFillingTime = 5 -- seconds
NormalCharging = 1  -- Adjust this part how much you want to fill in how many seconds
NormalChargingPropName = "gks_charge_normal"
NormalChargePay = 30  -- pay * percent

FastChargingFillingTime = 5 -- seconds
FastCharging = 3  -- Adjust this part how much you want to fill in how many seconds
FastChargingPropName = "gks_charge_fast"
FastChargePay = 50  -- pay * percent

ChargeEyeTarget = false

Charge = {
    ["twitterdata"] = 0.1,
    ["twitterlike"] = 0.1,
    ["twitterpost"] = 0.1,

    ["instapost"] = 0.1,
    ["instalike"] = 0.1,
    ["instadata"] = 0.1,

    ["carsellerdata"] = 0.1,
    ["carseller"] = 0.1,
    ["facetime"] = 0.1,

    ["tindermessage"] = 0.1,
    ["tindermatch"] = 0.1,

    ["gallerydata"] = 0.1,
    ["gallerypost"] = 0.1,
    ["darkchatdata"] = 0.1,
    ["darkchatpost"] = 0.1,

    ["game"] = 0.1,
    ["yellowdata"] = 0.1,
    ["yellowpost"] = 0.1,

    ["banktransfer"] = 0.1,

    ["billing"] = 0.1,
    ["valetdata"] = 0.1,

    ["addcontact"] = 0.1,
    ["groupcrate"] = 0.1,

    ["jobmessage"] = 0.1,
    ["sendmessage"] = 0.1,

    ["calling"] = 0.1,
    ["PlayTube"] = 0.1,
    ["music"] = 0.1,

    ["livestream"] = 3,
    ["livewatch"] = 1,
}

PhoneNormalCharging = {
    vector4(640.49, 257.56, 103.3, 242.0),
    vector4(155.01, -1038.48, 29.3, 159.62),
    vector4(299.61, -571.09, 43.27, 291.86),
    vector4(318.49, -276.56, 53.92, 158.84),
    vector4(-345.18, -47.58, 49.04, 161.18),
    vector4(-1207.72, -324.01, 37.85, 204.98),
    vector4(-720.08, -917.29, 19.21, 1.18),
    vector4(-59.62, -1751.86, 29.41, 318.57),
    vector4(809.67, -2147.67, 29.38, 180.54),
    vector4(2679.87, 3277.53, 55.41, 57.13),
    vector4(1960.4, 3737.2, 32.38, 30.07),
    vector4(1702.24, 4934.94, 42.08, 236.67),
    vector4(130.95, 6637.16, 31.81, 42.95),
    vector4(-381.39, 6038.37, 31.5, 315.51),
    vector4(-1509.64, 1500.67, 115.29, 343.82),
    vector4(538.37, 2672.53, 42.17, 186.84),
}

PhoneFastCharging = {
    vector4(649.88, 273.75, 103.29, 237.7),
    vector4(144.24, -1034.37, 29.35, 162.26),
    vector4(293.61, -598.71, 43.32, 251.23),
    vector4(312.35, -274.33, 53.94, 159.83),
    vector4(-354.34, -44.42, 49.04, 161.77),
    vector4(-1219.88, -328.98, 37.5, 206.76),
    vector4(-704.53, -917.12, 19.21, 0.4),
    vector4(-47.58, -1761.79, 29.43, 320.59),
    vector4(1214.98, -1388.5, 35.41, 90.96),
    vector4(2685.64, 3287.9, 55.41, 60.13),
    vector4(1970.44, 3742.99, 32.35, 30.37),
    vector4(1694.58, 4923.89, 42.23, 236.01),
    vector4(137.76, 6644.05, 31.71, 45.25),
    vector4(-373.57, 6030.43, 31.55, 314.21),
    vector4(-3239.04, 1009.46, 12.35, 86.58),
    vector4(-2973.97, 394.18, 15.04, 262.43),
    vector4(-1501.42, 1521.19, 115.29, 345.84),
    vector4(1187.77, 2702.44, 38.17, 358.46),
}