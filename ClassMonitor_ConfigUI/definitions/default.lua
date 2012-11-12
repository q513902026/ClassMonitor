local _, Engine = ...

local L = Engine.Locales
local D = Engine.Definitions

-- Generic configuration if specific definition not found
D.DefaultPluginDefinition = {
	[1] = D.Helpers.Name,
	[2] = D.Helpers.DisplayName,
	[3] = D.Helpers.Kind,
	[4] = D.Helpers.Enable,
	[5] = D.Helpers.Autohide,
	[6] = D.Helpers.Width,
	[7] = D.Helpers.Height,
	[8] = D.Helpers.Specs,
	[9] = D.Helpers.Anchor,
	[10] = D.Helpers.AutoGridVerticalIndex,
	[11] = D.Helpers.AutoGridHorizontalIndex,
}