local _, ns = ...

local EM = ns.EM
local _G = _G

local DetailsAdapter = {
	DisplayName = 'Details!',
	SupportsDual = true,
	embedded = {},
}

function DetailsAdapter:IsAvailable()
	return EM:IsAddOnActive('Details') and _G.Details ~= nil
end

function DetailsAdapter:Embed(container, slotIndex, db)
	local Details = _G.Details
	local E = unpack(_G.ElvUI)
	if not Details or not Details.GetInstance then return end

	local instance = Details:GetInstance(slotIndex)
	if not instance and Details.CreateInstance then
		instance = Details:CreateInstance(slotIndex)
	end
	if not instance or not instance.baseframe then return end

	if instance.IsEnabled and not instance:IsEnabled() and instance.EnableInstance then
		instance:EnableInstance()
	end

	local base = instance.baseframe
	local width = container:GetWidth()
	local height = container:GetHeight()
	if not width or width <= 0 or not height or height <= 0 then return end

	local topOffset = 0
	if instance.toolbar_side == 1 and not instance.hide_icon then
		topOffset = -20
	end

	if instance.UngroupInstance then
		pcall(instance.UngroupInstance, instance)
	end

	base:SetParent(container)
	base:ClearAllPoints()
	base:SetPoint('TOPLEFT', container, 'TOPLEFT', 0, topOffset)
	base:SetPoint('BOTTOMRIGHT', container, 'BOTTOMRIGHT', 0, 0)
	base:SetSize(width, height + topOffset)

	if instance.SetWindowSize then
		pcall(instance.SetWindowSize, instance, width, height + topOffset)
	end
	if db and db.applySkin then
		local targetSkin = db.skinTransparent and 'ElvUI Frame Style' or 'ElvUI Style II'
		if Details.skins and Details.skins[targetSkin] and instance.ChangeSkin and instance.skin ~= targetSkin then
			pcall(instance.ChangeSkin, instance, targetSkin)
			-- Re-apply size/anchoring after ChangeSkin, since ChangeSkin may reset window frame geometry
			base:SetParent(container)
			base:ClearAllPoints()
			base:SetPoint('TOPLEFT', container, 'TOPLEFT', 0, topOffset)
			base:SetPoint('BOTTOMRIGHT', container, 'BOTTOMRIGHT', 0, 0)
			base:SetSize(width, height + topOffset)
			if instance.SetWindowSize then
				pcall(instance.SetWindowSize, instance, width, height + topOffset)
			end
		end
		if instance.bgframe then
			instance.bgframe:SetAlpha(0)
		end
		if base.SetBackdrop then
			pcall(base.SetBackdrop, base, nil)
		end
		EM:ApplySkinTemplate(container, db)

		local tex = E and E.private and E.private.general and E.private.general.normTex
		local font = E and E.db and E.db.general and E.db.general.font
		if instance.row_info then
			if tex then
				instance.row_info.texture = tex
			end
			if font then
				instance.row_info.font_face = font
			end
		end
		if instance.InstanceRefreshRows then
			pcall(instance.InstanceRefreshRows, instance)
		end
		if instance.RefreshBars then
			pcall(instance.RefreshBars, instance, true)
		end
	elseif container.SetBackdrop then
		container:SetBackdrop(nil)
	end
	if instance.LockInstance then
		pcall(instance.LockInstance, instance, true)
	end
	if instance.ShowWindow then
		pcall(instance.ShowWindow, instance)
	else
		base:Show()
	end
	if instance.SaveMainWindowPosition then
		pcall(instance.SaveMainWindowPosition, instance)
	end

	self.embedded[slotIndex] = instance
end

function DetailsAdapter:OnHide()
	for slotIndex, instance in pairs(self.embedded) do
		if instance and instance.baseframe then
			if instance.HideWindow then
				pcall(instance.HideWindow, instance)
			else
				instance.baseframe:Hide()
			end
		end
		self.embedded[slotIndex] = nil
	end
end

EM:RegisterAdapter('Details', DetailsAdapter)

