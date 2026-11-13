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

function OmenAdapter:Embed(container, _, db)
	local Omen = _G.Omen
	local E = unpack(_G.ElvUI)
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
	if db and db.applySkin then
		EM:ApplySkinTemplate(Omen.BarList or anchor, db)
		if Omen.Title then
			EM:ApplySkinTemplate(Omen.Title, db)
		end
		if Omen.db and Omen.db.profile and E then
			if Omen.db.profile.Bar and E.private and E.private.general and E.private.general.normTex then
				Omen.db.profile.Bar.Texture = E.private.general.normTex
			end
			if Omen.UpdateBarLabelSettings then
				pcall(Omen.UpdateBarLabelSettings, Omen)
			end
		end
	end
	anchor:Show()
end

function OmenAdapter:OnHide()
	if _G.OmenAnchor then
		_G.OmenAnchor:Hide()
	end
end

EM:RegisterAdapter('Omen', OmenAdapter)

