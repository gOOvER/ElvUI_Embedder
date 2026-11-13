local _, ns = ...

local EM = ns.EM
local _G = _G

local TinyDPSAdapter = {
	DisplayName = 'TinyDPS',
	SupportsDual = false,
}

function TinyDPSAdapter:IsAvailable()
	return EM:IsAddOnActive('TinyDPS') and _G.tdpsFrame ~= nil
end

function TinyDPSAdapter:Embed(container, _, db)
	local frame = _G.tdpsFrame
	if not frame then return end

	local width = container:GetWidth()
	local height = container:GetHeight()
	if not width or width <= 0 or not height or height <= 0 then return end

	frame:SetParent(container)
	frame:ClearAllPoints()
	frame:SetAllPoints(container)
	frame:SetSize(width, height)

	if _G.tdpsRefresh then
		pcall(_G.tdpsRefresh)
	end
	if db and db.applySkin then
		EM:ApplySkinTemplate(frame, db)
	end
	frame:Show()
end

function TinyDPSAdapter:OnHide()
	if _G.tdpsFrame then
		_G.tdpsFrame:Hide()
	end
end

EM:RegisterAdapter('TinyDPS', TinyDPSAdapter)

