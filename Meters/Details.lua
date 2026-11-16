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

	instance._ElvUIEmbed = true

	local base = instance.baseframe
	local width = container:GetWidth()
	local height = container:GetHeight()
	if not width or width <= 0 or not height or height <= 0 then return end

	if instance.UngroupInstance then
		pcall(instance.UngroupInstance, instance)
	end

	if db and db.applySkin then
		local targetSkin = db.skinTransparent and 'ElvUI Frame Style' or 'ElvUI Style II'
		if Details.skins and Details.skins[targetSkin] and instance.ChangeSkin and instance.skin ~= targetSkin then
			pcall(instance.ChangeSkin, instance, targetSkin)
		end
	end

	-- Match AddOnSkins Details embed geometry:
	-- Details renders its 20px title/toolbar above baseframe (when growing down)
	-- and a 13px statusbar below baseframe when enabled.
	local topOffset = (instance.bars_grow_direction == 2) and -2 or -20
	local effHeight = height
	if instance.show_statusbar then
		effHeight = effHeight - 13
	end
	local innerHeight = math.max(20, effHeight - 20)

	base:ClearAllPoints()
	base:SetParent(container)
	base:SetFrameStrata(container:GetFrameStrata())
	base:SetFrameLevel(container:GetFrameLevel())

	if instance.SetSize then
		pcall(instance.SetSize, instance, width, innerHeight)
	elseif instance.SetWindowSize then
		pcall(instance.SetWindowSize, instance, width, innerHeight)
	else
		base:SetSize(width, innerHeight)
	end

	base:SetPoint('TOPLEFT', container, 'TOPLEFT', 0, topOffset)

	if instance.SaveMainWindowPosition then
		pcall(instance.SaveMainWindowPosition, instance)
	end
	if instance.RestoreMainWindowPosition then
		pcall(instance.RestoreMainWindowPosition, instance)
	end

	if db and db.applySkin then
		if instance.bgframe then
			instance.bgframe:SetAlpha(0)
		end
		if base.SetBackdrop then
			pcall(base.SetBackdrop, base, nil)
		end
		EM:ApplySkinTemplate(container, db)

		local tex = E and E.private and E.private.general and E.private.general.normTex
		local font = E and E.db and E.db.general and E.db.general.font
		local LSM = LibStub and LibStub('LibSharedMedia-3.0', true)
		if instance.row_info and LSM then
			if tex then
				local texPath = LSM:Fetch('statusbar', tex, true)
				if texPath then
					instance.row_info.texture = tex
					instance.row_info.texture_file = texPath
				end
			end
			if font then
				local fontPath = LSM:Fetch('font', font, true)
				if fontPath then
					instance.row_info.font_face = font
					instance.row_info.font_face_file = fontPath
				end
			end
			instance.row_info.texture_class_colors = true
		end
		if instance.RefreshMainWindow then
			pcall(instance.RefreshMainWindow, instance, true)
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

	local id = instance.GetId and instance:GetId() or slotIndex
	local switchFrame = _G['Details_SwitchButtonFrame' .. tostring(id)]
	if switchFrame then
		switchFrame:SetParent(base)
		switchFrame:SetFrameLevel(base:GetFrameLevel() + 3)
	end
	local rowFrame = _G['DetailsRowFrame' .. tostring(id)]
	if rowFrame then
		rowFrame:SetParent(base)
		rowFrame:SetFrameLevel(base:GetFrameLevel() + 2)
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
