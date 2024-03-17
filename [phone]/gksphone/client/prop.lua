function ChangePhoneType(type)
	local phoneModel = "prop_npc_phone"
	if Config.PropActive then
		if type == "phone" then
			phoneModel = "patoche_props_phone2"
		elseif type == "pink_phone" then
			phoneModel = "patoche_props_phone3"
		elseif type == "gold_phone" then
			phoneModel = "patoche_props_phone1"
		end
	end
	return phoneModel
end

