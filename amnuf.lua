PlayerFrame:ClearAllPoints()
PlayerFrame:SetPoint("CENTER", nil, "CENTER", -150, -200)
PlayerFrame:SetScale(1.2)

TargetFrame:ClearAllPoints()
TargetFrame:SetPoint("LEFT", PlayerFrame, "RIGHT", 50, 0)
TargetFrame:SetScale(1.2)

PartyMemberFrame1:ClearAllPoints()
PartyMemberFrame1:SetPoint("LEFT", TargetFrame, "RIGHT", 50, 0)

amnufdb = {}

local AMNUF_DEFAULT_FONT_NAME, AMNUF_DEFAULT_FONT_SIZE = GameFontNormalSmall:GetFont()

local addon = CreateFrame"Frame"
addon:RegisterEvent"UNIT_HEALTH"
addon:RegisterEvent"UNIT_MANA"
addon:RegisterEvent"UNIT_RAGE"
addon:RegisterEvent"UNIT_ENERGY"
addon:RegisterEvent"UNIT_FOCUS"
addon:RegisterEvent"PLAYER_ENTERING_WORLD"
addon:RegisterEvent"PLAYER_TARGET_CHANGED"
addon:RegisterEvent"PLAYER_LOGIN"
addon:SetScript("OnEvent", function (self, event, unit) 
	self[event](unit)
end)

local bars = {
	["PlayerFrameHealthBar"] = "PlayerFrameHealthText",
	["PlayerFrameManaBar"] = "PlayerFrameManaText",
	["TargetFrameHealthBar"] = "TargetFrameHealthText",
	["TargetFrameManaBar"] = "TargetFrameManaText",
}

local update = function (unit) 
	if unit ~= "player" and unit ~= "target" then return end
	local health = ""
	if not UnitIsDead(unit) then
		health = string.format("%d / %d (%d%%)", UnitHealth(unit), UnitHealthMax(unit), math.ceil(100 * UnitHealth(unit) / UnitHealthMax(unit)))
	end

	-- Bah, Lua sucks sometimes.
	local mpper = 0
	if UnitMana(unit) > 0 then
		mpper = math.ceil(100 * UnitMana(unit) / UnitManaMax(unit))
	end

	local mana = string.format("%d / %d (%d%%)", UnitMana(unit), UnitManaMax(unit), mpper)
	if unit == "player" then
		getglobal("PlayerFrameHealthText"):SetText(health)
		getglobal("PlayerFrameManaText"):SetText(mana)
	else
		getglobal("TargetFrameHealthText"):SetText(health)
		getglobal("TargetFrameManaText"):SetText(mana)
	end
end

addon.PLAYER_LOGIN = function() 
	-- If the database isn't initialized, initialize it with default values
	if amnufdb.fontSize == nil then 
		amnufdb.fontSize = AMNUF_DEFAULT_FONT_SIZE
	end

	for parent, child in pairs(bars) do
		local frame = CreateFrame("Frame", nil, getglobal(parent:sub(1,11)))
		frame:SetFrameStrata"HIGH"
		frame:CreateFontString(child)
		getglobal(child):SetFont(AMNUF_DEFAULT_FONT_NAME, amnufdb.fontSize)
		getglobal(child):SetShadowOffset(1, -1)
		getglobal(child):SetPoint("CENTER", getglobal(parent), "CENTER", -1, 0)
	end
end

addon.PLAYER_ENTERING_WORLD = function ()
	update"player"
end
addon.PLAYER_TARGET_CHANGED = function ()
	update"target"
end
addon.UNIT_HEALTH = update
addon.UNIT_MANA = update
addon.UNIT_FOCUS = update
addon.UNIT_ENERGY = update
addon.UNIT_RAGE = update

-- Hide old strings.
local frames = { PlayerFrameHealthBarText, PlayerFrameManaBarText, TargetFrameTextureFrameHealthBarText, TargetFrameTextureFrameManaBarText }
for i, _ in pairs(frames) do
	frames[i]:Hide()
	frames[i].Show = function() end
end

local help = function() 
	ChatFrame1:AddMessage(string.format("|cff33ff99AmnUF|r: Usage is /amnuf <number> to set font size. Current font size is [%d]", amnufdb.fontSize))
end

local updateFontSizes = function() 
	for parent, child in pairs(bars) do
		getglobal(child):SetFont(AMNUF_DEFAULT_FONT_NAME, amnufdb.fontSize)
	end
end

-- A basic slash handler
SlashCmdList['AMNUF'] = function (size) 
	if not size then return help() end
	local value = tonumber(size) or 0
	if value >= 8 and value <= 20 then
		amnufdb.fontSize = size
		updateFontSizes()
		return
	end

	help()
end

SLASH_AMNUF1 = '/amnuf'
