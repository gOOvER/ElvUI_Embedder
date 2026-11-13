local _, ns = ...

local EM = ns.EM
local _G = _G

local RecountAdapter = {
	DisplayName = 'Recount',
	SupportsDual = false,
}

function RecountAdapter:IsAvailable()
	return EM:IsAddOnActive('Recount') and _G.Recount ~= nil and _G.Recount.MainWindow ~= nil
end

function RecountAdapter:Embed(container)
	local Recount = _G.Recount
	local win = Recount and Recount.MainWindow
	if not win then return end

	local width = container:GetWidth()
	local height = container:GetHeight()
	if not width or width <= 0 or not height or height <= 0 then return end

	if Recount.db and Recount.db.profile then
		Recount.db.profile.Locked = true
	end

	win:SetParent(container)
	win:ClearAllPoints()
	win:SetPoint('TOPLEFT', container, 'TOPLEFT', 0, 7)
	win:SetPoint('BOTTOMRIGHT', container, 'BOTTOMRIGHT', 0, 0)
	win:SetSize(width, height + 7)

	if Recount.ResizeMainWindow then
		pcall(Recount.ResizeMainWindow, Recount)
	end
	win:Show()
end

function RecountAdapter:OnHide()
	local win = _G.Recount and _G.Recount.MainWindow
	if win then
		win:Hide()
	end
end

EM:RegisterAdapter('Recount', RecountAdapter)

