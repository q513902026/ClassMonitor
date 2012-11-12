-- Combo Points plugin
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

if UI.MyClass ~= "ROGUE" and UI.MyClass ~= "DRUID" then return end -- combo not needed for other classes

-- ONLY ON PTR
--if not Engine.IsPTR() then return end

local CheckSpec = Engine.CheckSpec
local PixelPerfect = Engine.PixelPerfect
local DefaultBoolean = Engine.DefaultBoolean
local GetColor = Engine.GetColor

--
local plugin = Engine:NewPlugin("COMBO")

local DefaultColors = {
	{0.69, 0.31, 0.31, 1}, -- 1
	{0.65, 0.42, 0.31, 1}, -- 2
	{0.65, 0.63, 0.35, 1}, -- 3
	{0.46, 0.63, 0.35, 1}, -- 4
	{0.33, 0.63, 0.33, 1}, -- 5
}

-- own methods
function plugin:UpdateVisibility(event)
	local inCombat = true
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		inCombat = true
	else
		inCombat = false
	end
	if (self.settings.autohide == false or inCombat) and CheckSpec(self.settings.specs) then
		self.frame:Show()
		self:UpdateValue()
	else
		self.frame:Hide()
	end
end

function plugin:UpdateValue()
	local points = GetComboPoints("player", "target")
	if points and points > 0 then
		for i = 1, points do self.points[i]:Show() end
		for i = points+1, self.count do self.points[i]:Hide() end
	else
		for i = 1, self.count do self.points[i]:Hide() end
	end
end

function plugin:UpdateGraphics()
	-- Create a frame including every points
	local frame = self.frame
	if not frame then
		frame = CreateFrame("Frame", self.name, UI.PetBattleHider)
		frame:Hide()
		self.frame = frame
	end
	frame:ClearAllPoints()
	frame:Point(unpack(self.settings.anchor))
	frame:Size(self.settings.width, self.settings.height)
	-- Create points
	local width, spacing = PixelPerfect(self.settings.width, self.count)
	self.points = self.points or {}
	for i = 1, self.count do
		local point = self.points[i]
		if not point then
			point = CreateFrame("Frame", nil, self.frame)
			point:SetTemplate()
			point:SetFrameStrata("BACKGROUND")
			point:Hide()
			self.points[i] = point
		end
		point:Size(width, self.settings.height)
		point:ClearAllPoints()
		if i == 1 then
			point:Point("TOPLEFT", frame, "TOPLEFT", 0, 0)
		else
			point:Point("LEFT", self.points[i-1], "RIGHT", spacing, 0)
		end
		if self.settings.filled == true and not point.status then
			point.status = CreateFrame("StatusBar", nil, point)
			point.status:SetStatusBarTexture(UI.NormTex)
			point.status:SetFrameLevel(6)
			point.status:Point("TOPLEFT", point, "TOPLEFT", 2, -2)
			point.status:Point("BOTTOMRIGHT", point, "BOTTOMRIGHT", -2, 2)
		end
		local color = GetColor(self.settings.color, i, DefaultColors[i])
		if self.settings.filled == true then
			point.status:SetStatusBarColor(unpack(color))
			point.status:Show()
			point:SetBackdropBorderColor(unpack(UI.BorderColor))
		else
			point:SetBackdropBorderColor(unpack(color))
			if point.status then point.status:Hide() end
		end
	end
end

-- overridden methods
function plugin:Initialize()
	-- set defaults
	self.settings.filled = DefaultBoolean(self.settings.filled, false)
	self.settings.colors = self.settings.colors or DefaultColors
	--
	self.count = 5
	--
	self:UpdateGraphics()
end

function plugin:Enable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", plugin.UpdateVisibility)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", plugin.UpdateVisibility)
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player", plugin.UpdateVisibility)

	self:RegisterUnitEvent("UNIT_COMBO_POINTS", "player", plugin.UpdateValue)
end

function plugin:Disable()
	self:UnregisterAllEvents()

	self.frame:Hide()
end

function plugin:SettingsModified()
	--
	self:Disable()
	--
	self:UpdateGraphics()
	--
	if self.settings.enable == true then
		self:Enable()
		self:UpdateVisibility()
	end
end

-- ----------------------------------------------
-- -- test
-- ----------------------------------------------
-- local C = Engine.Config
-- local settings = C[UI.MyClass]
-- if not settings then return end
-- for i, pluginSettings in ipairs(settings) do
	-- if pluginSettings.kind == "COMBO" then
		-- local setting = Engine.DeepCopy(pluginSettings)
		-- setting.anchor = {"CENTER", UIParent, "CENTER", 0, i*30}
		-- setting.specs = {"any"}
		-- setting.enable = true
		-- setting.autohide = false
		-- setting.filled = false
		-- local instance = Engine:NewPluginInstance("COMBO", "COMBO"..tostring(i), setting)
		-- instance:Initialize()
		-- if setting.enable then
			-- instance:Enable()
		-- end
	-- end
-- end

--[[
-- Create combo points monitor
Engine.CreateComboMonitor = function(name, enable, autohide, anchor, totalWidth, height, colors, filled, specs)
	local count = 5
	local width, spacing = PixelPerfect(totalWidth, count)
	local cmCombos = {}
	for i = 1, count do
		local cmCombo = CreateFrame("Frame", name, UI.PetBattleHider)
		cmCombo:SetTemplate()
		cmCombo:SetFrameStrata("BACKGROUND")
		cmCombo:Size(width, height)
		if i == 1 then
			cmCombo:Point(unpack(anchor))
		else
			cmCombo:Point("LEFT", cmCombos[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmCombo.status = CreateFrame("StatusBar", name.."_status_"..i, cmCombo)
			cmCombo.status:SetStatusBarTexture(UI.NormTex)
			cmCombo.status:SetFrameLevel(6)
			cmCombo.status:Point("TOPLEFT", cmCombo, "TOPLEFT", 2, -2)
			cmCombo.status:Point("BOTTOMRIGHT", cmCombo, "BOTTOMRIGHT", -2, 2)
			cmCombo.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmCombo:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmCombo:Hide()

		tinsert(cmCombos, cmCombo)
	end

	if not enable then
		for i = 1, count do cmCombos[i]:Hide() end
		return
	end


	cmCombos[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmCombos[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmCombos[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmCombos[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmCombos[1]:RegisterUnitEvent("UNIT_COMBO_POINTS", "player")
	cmCombos[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmCombos[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local points = GetComboPoints("player", "target")
		if visible and points and points > 0 and CheckSpec(specs) then
			for i = 1, points do cmCombos[i]:Show() end
			for i = points+1, count do cmCombos[i]:Hide() end
		else
			for i = 1, count do cmCombos[i]:Hide() end
		end
	end)

	return cmCombos[1]
end
--]]
--[[
Engine.CreateComboMonitor = function(name, enable, autohide, anchor, width, height, spacing, colors, filled, specs)
	local cmCombos = {}
	for i = 1, 5 do
		local cmCombo = CreateFrame("Frame", name, UI.PetBattleHider)
		cmCombo:SetTemplate()
		cmCombo:SetFrameStrata("BACKGROUND")
		cmCombo:Size(width, height)
		if i == 1 then
			cmCombo:Point(unpack(anchor))
		else
			cmCombo:Point("LEFT", cmCombos[i-1], "RIGHT", spacing, 0)
		end
		if filled then
			cmCombo.status = CreateFrame("StatusBar", name.."_status_"..i, cmCombo)
			cmCombo.status:SetStatusBarTexture(UI.NormTex)
			cmCombo.status:SetFrameLevel(6)
			cmCombo.status:Point("TOPLEFT", cmCombo, "TOPLEFT", 2, -2)
			cmCombo.status:Point("BOTTOMRIGHT", cmCombo, "BOTTOMRIGHT", -2, 2)
			cmCombo.status:SetStatusBarColor(unpack(colors[i]))
		else
			cmCombo:SetBackdropBorderColor(unpack(colors[i]))
		end
		cmCombo:Hide()

		tinsert(cmCombos, cmCombo)
	end

	if not enable then
		for i = 1, 5 do cmCombos[i]:Hide() end
		return
	end


	cmCombos[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmCombos[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmCombos[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmCombos[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
	cmCombos[1]:RegisterUnitEvent("UNIT_COMBO_POINTS", "player")
	cmCombos[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	cmCombos[1]:SetScript("OnEvent", function(self, event)
		local visible = true
		if autohide == true then
			if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
				visible = true
			else
				visible = false
			end
		end
		local points = GetComboPoints("player", "target")
		if visible and points and points > 0 and CheckSpec(specs) then
			for i = 1, points do cmCombos[i]:Show() end
			for i = points+1, 5 do cmCombos[i]:Hide() end
		else
			for i = 1, 5 do cmCombos[i]:Hide() end
		end
	end)

	return cmCombos[1]
end
--]]