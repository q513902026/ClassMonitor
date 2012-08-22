local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

if T.myname == "Meuhhnon" then
	C["classmonitor"]["DRUID"][1].anchor = nil -- RESOURCE
	C["classmonitor"]["DRUID"][1].anchors = {
		{ "CENTER", UIParent, "CENTER", 0, -140 }, -- Balance
		{ "CENTER", UIParent, "CENTER", 0, -140 }, -- Feral
		{ "CENTER", UIParent, "CENTER", 0, -140 }, -- Guardian
		{ "CENTER", UIParent, "CENTER", 0, -140 } -- Restoration
	}
end
if T.myname == "Enimouchet" then
	C["classmonitor"]["PALADIN"][1].anchor = nil -- RESOURCE
	C["classmonitor"]["PALADIN"][1].anchors = {
		--{"CENTER", UIParent, "CENTER", -543, 290}, -- Holy
		{ "CENTER", UIParent, "CENTER", 0, -140 }, -- Holy
		{"CENTER", UIParent, "CENTER", -0, -100}, -- Protection
		{"CENTER", UIParent, "CENTER", -0, -100} -- Retribution
	}
end
if T.myname == "Nyara" or T.myname == "Graougraou" then
	C["classmonitor"]["ROGUE"][1].anchor = { "CENTER", UIParent, "CENTER", 0, -150 } -- RESOURCE
end