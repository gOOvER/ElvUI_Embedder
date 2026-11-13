local _, ns = ...

local EM = ns.EM
local _G = _G

local BlizzardMeterAdapter = {
	DisplayName = 'Blizzard Damage Meter (Retail)',
	SupportsDual = true,
	embedded = {},
}

local function GetWindowFrame(slotIndex)
	return _G['DamageMeterSessionWindow' .. slotIndex] or (slotIndex == 1 and _G.DamageMeter) or nil
end

function BlizzardMeterAdapter:IsAvailable()
	return GetWindowFrame(1) ~= nil
end

function BlizzardMeterAdapter:Embed(container, slotIndex, db)
	local frame = GetWindowFrame(slotIndex)
	if not frame then return end

	local width = container:GetWidth()
	local height = container:GetHeight()
	if not width or width <= 0 or not height or height <= 0 then return end

	frame:SetParent(container)
	frame:ClearAllPoints()
	frame:SetAllPoints(container)
	frame:SetSize(width, height)
	if db and db.applySkin then
		if frame.NineSlice then frame.NineSlice:SetAlpha(0) end
		if frame.Background then frame.Background:SetAlpha(0) end
		if frame.Bg then frame.Bg:SetAlpha(0) end
		EM:ApplySkinTemplate(frame, db)
	end
	frame:Show()

	self.embedded[slotIndex] = frame
end

function BlizzardMeterAdapter:OnHide()
	for slotIndex, frame in pairs(self.embedded) do
		if frame then
			frame:Hide()
		end
		self.embedded[slotIndex] = nil
	end
end

EM:RegisterAdapter('BlizzardDamageMeter', BlizzardMeterAdapter)

