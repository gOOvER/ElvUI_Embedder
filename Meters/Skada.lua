local _, ns = ...

local EM = ns.EM
local _G = _G

local SkadaAdapter = {
	DisplayName = 'Skada',
	SupportsDual = true,
	embedded = {},
}

function SkadaAdapter:IsAvailable()
	return EM:IsAddOnActive('Skada') and _G.Skada ~= nil
end

function SkadaAdapter:Embed(container, slotIndex)
	local Skada = _G.Skada
	if not Skada or not Skada.GetWindows then return end

	local windows = Skada:GetWindows()
	local win = windows and windows[slotIndex]
	if not win or not win.bargroup then return end

	local width = container:GetWidth()
	local height = container:GetHeight()
	if not width or width <= 0 or not height or height <= 0 then return end

	local db = win.db
	if db then
		db.barwidth = width
		db.background = db.background or {}
		db.background.height = height - (db.enabletitle and (db.title and db.title.height or 20) or 0)
		db.barslocked = true
	end

	local bg = win.bargroup
	bg:SetParent(container)
	bg:ClearAllPoints()
	bg:SetPoint('TOPLEFT', container, 'TOPLEFT', 0, 0)
	bg:SetPoint('BOTTOMRIGHT', container, 'BOTTOMRIGHT', 0, 0)

	if Skada.ApplySettings then
		pcall(Skada.ApplySettings, Skada)
	end
	if win.Show then
		pcall(win.Show, win)
	else
		bg:Show()
	end

	self.embedded[slotIndex] = win
end

function SkadaAdapter:OnHide()
	for slotIndex, win in pairs(self.embedded) do
		if win then
			if win.Hide then
				pcall(win.Hide, win)
			elseif win.bargroup then
				win.bargroup:Hide()
			end
		end
		self.embedded[slotIndex] = nil
	end
end

EM:RegisterAdapter('Skada', SkadaAdapter)

