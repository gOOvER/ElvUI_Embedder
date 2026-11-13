local _, ns = ...

local E, _, _, P = unpack(ElvUI)
local EM = E:NewModule('ElvUI_Embedder', 'AceEvent-3.0', 'AceHook-3.0')
ns.EM = EM

local _G = _G
local pairs, ipairs, math_max, math_floor = pairs, ipairs, math.max, math.floor
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsInInstance = IsInInstance
local C_Timer = C_Timer

local ADAPTER_ORDER = {
	'Details',
	'BlizzardDamageMeter',
	'Skada',
	'Recount',
	'Omen',
	'TinyDPS',
}

EM.Adapters = {}
EM.AdapterOrder = ADAPTER_ORDER

P.embedder = {
	mode = 'single', -- 'off', 'single', 'dual'
	targetPanel = 'right', -- 'right', 'left'
	belowTab = true,
	primary = 'auto',
	secondary = 'auto',
	leftPercent = 50,
	gap = 2,
	visibility = 'always', -- 'always', 'combat', 'group'
	backdrop = false,
	transparent = true,
	hidden = false,
}

local function IsAddOnLoadedCompat(name)
	if _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded then
		return _G.C_AddOns.IsAddOnLoaded(name)
	elseif _G.IsAddOnLoaded then
		return _G.IsAddOnLoaded(name)
	end
	return false
end

function EM:IsAddOnActive(name)
	return IsAddOnLoadedCompat(name)
end

function EM:RegisterAdapter(name, adapter)
	self.Adapters[name] = adapter
end

function EM:GetDB()
	return E.db.embedder or P.embedder
end

function EM:ResolveAdapter(choice)
	if not choice or choice == 'none' then
		return nil, nil
	end

	if choice ~= 'auto' then
		local adapter = self.Adapters[choice]
		if adapter and adapter:IsAvailable() then
			return choice, adapter
		end
		return nil, nil
	end

	for _, name in ipairs(ADAPTER_ORDER) do
		local adapter = self.Adapters[name]
		if adapter and adapter:IsAvailable() then
			return name, adapter
		end
	end

	return nil, nil
end

function EM:CreateContainers()
	if self.Main then return end

	local main = CreateFrame('Frame', 'ElvUI_EmbedderMain', _G.UIParent, 'BackdropTemplate')
	main:SetFrameStrata('LOW')
	main:SetFrameLevel(10)

	local left = CreateFrame('Frame', 'ElvUI_EmbedderLeft', main)
	left:SetFrameLevel(main:GetFrameLevel() + 1)

	local right = CreateFrame('Frame', 'ElvUI_EmbedderRight', main)
	right:SetFrameLevel(main:GetFrameLevel() + 1)

	self.Main = main
	self.Left = left
	self.Right = right
end

function EM:ShouldShow()
	local db = self:GetDB()
	if db.mode == 'off' or db.hidden then
		return false
	end

	if db.visibility == 'combat' then
		return InCombatLockdown() or _G.UnitAffectingCombat('player')
	elseif db.visibility == 'group' then
		local inInstance = IsInInstance()
		return IsInGroup() or inInstance
	end

	return true
end

function EM:UpdateLayout()
	local db = self:GetDB()
	if not self.Main then return end

	if InCombatLockdown() then
		self.pendingUpdate = true
		return
	end

	local isRight = db.targetPanel ~= 'left'
	local chatPanel = isRight and _G.RightChatPanel or _G.LeftChatPanel
	local chatTab = isRight and _G.RightChatTab or _G.LeftChatTab
	if not chatPanel then return end

	self.Main:SetParent(chatPanel)
	self.Main:ClearAllPoints()
	if db.belowTab and chatTab then
		self.Main:SetPoint('TOPRIGHT', chatTab, 'BOTTOMRIGHT', 0, -1)
	else
		self.Main:SetPoint('TOPRIGHT', chatPanel, 'TOPRIGHT', 0, 0)
	end
	self.Main:SetPoint('BOTTOMLEFT', chatPanel, 'BOTTOMLEFT', 0, E.PixelMode and 0 or -1)

	if db.backdrop then
		self.Main:SetTemplate(db.transparent and 'Transparent' or 'Default')
	else
		self.Main:SetBackdrop(nil)
	end

	local width = math_max(100, self.Main:GetWidth() or 400)
	local height = math_max(60, self.Main:GetHeight() or 180)
	local gap = db.gap or 2

	if db.mode == 'dual' then
		local leftWidth = math_floor((width - gap) * ((db.leftPercent or 50) / 100))
		leftWidth = math_max(50, leftWidth)
		local rightWidth = math_max(50, width - leftWidth - gap)

		self.Left:ClearAllPoints()
		self.Left:SetPoint('TOPLEFT', self.Main, 'TOPLEFT', 0, 0)
		self.Left:SetPoint('BOTTOMLEFT', self.Main, 'BOTTOMLEFT', 0, 0)
		self.Left:SetWidth(leftWidth)
		self.Left:Show()

		self.Right:ClearAllPoints()
		self.Right:SetPoint('TOPRIGHT', self.Main, 'TOPRIGHT', 0, 0)
		self.Right:SetPoint('BOTTOMRIGHT', self.Main, 'BOTTOMRIGHT', 0, 0)
		self.Right:SetWidth(rightWidth)
		self.Right:Show()
	else
		self.Left:ClearAllPoints()
		self.Left:SetAllPoints(self.Main)
		self.Left:Show()

		self.Right:ClearAllPoints()
		self.Right:Hide()
	end
end

function EM:Refresh()
	if not self.Main then return end

	if InCombatLockdown() then
		self.pendingUpdate = true
		-- Visibility toggle for combat mode still updates container visibility safely
		if not self:ShouldShow() then
			self.Main:Hide()
		end
		return
	end

	self:UpdateLayout()

	local db = self:GetDB()
	local visible = self:ShouldShow()
	self.Main:SetShown(visible)

	if not visible or db.mode == 'off' then
		for _, adapter in pairs(self.Adapters) do
			if adapter.OnHide then
				pcall(adapter.OnHide, adapter)
			end
		end
		return
	end

	local primaryName, primaryAdapter = self:ResolveAdapter(db.primary)
	self.activePrimary = primaryName

	if primaryAdapter then
		pcall(primaryAdapter.Embed, primaryAdapter, self.Left, 1, db)
	end

	if db.mode == 'dual' then
		local secondaryChoice = db.secondary
		if secondaryChoice == 'auto' then
			-- If primary is Details or Skada and supports 2 windows, use window 2 of same adapter;
			-- otherwise fall back to Omen or next available adapter.
			if primaryAdapter and primaryAdapter.SupportsDual then
				self.activeSecondary = primaryName
				pcall(primaryAdapter.Embed, primaryAdapter, self.Right, 2, db)
				return
			end
			for _, name in ipairs(ADAPTER_ORDER) do
				if name ~= primaryName then
					local adapter = self.Adapters[name]
					if adapter and adapter:IsAvailable() then
						self.activeSecondary = name
						pcall(adapter.Embed, adapter, self.Right, 1, db)
						return
					end
				end
			end
		else
			local secName, secAdapter = self:ResolveAdapter(secondaryChoice)
			self.activeSecondary = secName
			if secAdapter then
				local slot = (secName == primaryName) and 2 or 1
				pcall(secAdapter.Embed, secAdapter, self.Right, slot, db)
			end
		end
	else
		self.activeSecondary = nil
	end
end

function EM:SetupChatToggleHook()
	local L = ns.L
	local btn = _G.RightChatToggleButton
	if not btn or btn.__EmbedderHooked then return end
	btn.__EmbedderHooked = true

	btn:RegisterForClicks('AnyUp')
	btn:HookScript('OnClick', function(_, mouseBtn)
		if mouseBtn == 'RightButton' then
			local db = self:GetDB()
			db.hidden = not db.hidden
			self:Refresh()
		end
	end)

	btn:HookScript('OnEnter', function(s)
		if not _G.GameTooltip:IsForbidden() and _G.GameTooltip:IsShown() then
			_G.GameTooltip:AddDoubleLine(L["Right-Click:"], L["Toggle Embedded Meter"], 1, 1, 1)
			_G.GameTooltip:Show()
		end
	end)
end

function EM:Initialize()
	self:CreateContainers()

	local CH = E:GetModule('Chat', true)
	if CH and CH.PositionChat then
		self:SecureHook(CH, 'PositionChat', function(_, override)
			if override then
				self:Refresh()
			end
		end)
	end

	local LO = E:GetModule('Layout', true)
	if LO and LO.ToggleChatPanels then
		self:SecureHook(LO, 'ToggleChatPanels', function()
			self:Refresh()
		end)
	end

	self:SetupChatToggleHook()

	self:RegisterEvent('PLAYER_REGEN_DISABLED', 'Refresh')
	self:RegisterEvent('PLAYER_REGEN_ENABLED', function()
		if self.pendingUpdate then
			self.pendingUpdate = nil
		end
		self:Refresh()
	end)
	self:RegisterEvent('GROUP_ROSTER_UPDATE', 'Refresh')
	self:RegisterEvent('PLAYER_ENTERING_WORLD', function()
		C_Timer.After(0.5, function()
			self:SetupChatToggleHook()
			self:Refresh()
		end)
	end)

	local EP = _G.LibStub and _G.LibStub('LibElvUIPlugin-1.0', true)
	if EP then
		EP:RegisterPlugin('ElvUI_Embedder', function()
			self:InsertOptions()
		end)
	end

	C_Timer.After(1, function()
		self:Refresh()
	end)
end

E:RegisterModule(EM:GetName())

