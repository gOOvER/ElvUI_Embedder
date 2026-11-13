local _, ns = ...

local EM = ns.EM
local _G = _G

local OmenAdapter = {
	DisplayName = 'Omen',
	SupportsDual = false,
}

function OmenAdapter:IsAvailable()
	return EM:IsAddOnActive('Omen') and _G.Omen ~= nil and _G.OmenAnchor ~= nil
end

function OmenAdapter:Embed(container)
	local Omen = _G.Omen
	local anchor = _G.OmenAnchor
	if not Omen or not anchor then return end

	local width = container:GetWidth()
	local height = container:GetHeight()
	if not width or width <= 0 or not height or height <= 0 then return end

	if Omen.db and Omen.db.profile then
		Omen.db.profile.Locked = true
	end

	anchor:SetParent(container)
	anchor:ClearAllPoints()
	anchor:SetAllPoints(container)
	anchor:SetSize(width, height)

	if Omen.UpdateBackdrop then
		pcall(Omen.UpdateBackdrop, Omen)
	end
	anchor:Show()
end

function OmenAdapter:OnHide()
	if _G.OmenAnchor then
		_G.OmenAnchor:Hide()
	end
end

EM:RegisterAdapter('Omen', OmenAdapter)

