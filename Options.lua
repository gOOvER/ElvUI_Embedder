local _, ns = ...

local E = unpack(ElvUI)
local EM = ns.EM
local L = ns.L

local function BuildMeterChoices(includeNone)
	local values = {
		auto = L["Auto-Detect"],
	}
	if includeNone then
		values.none = L["None"]
	end
	for _, name in ipairs(EM.AdapterOrder) do
		local adapter = EM.Adapters[name]
		local label = (adapter and adapter.DisplayName) or name
		values[name] = label
	end
	return values
end

function EM:InsertOptions()
	local ACH = E.Libs and E.Libs.ACH
	if not E.Options or not E.Options.args then return end

	E.Options.args.ElvUI_Embedder = {
		type = 'group',
		name = '|cff1784d1ElvUI|r Embedder',
		order = 99,
		get = function(info)
			return EM:GetDB()[info[#info]]
		end,
		set = function(info, value)
			EM:GetDB()[info[#info]] = value
			EM:Refresh()
		end,
		args = {
			header = {
				type = 'header',
				name = L["ElvUI Embedder"],
				order = 1,
			},
			status = {
				type = 'description',
				order = 2,
				fontSize = 'medium',
				name = function()
					local primary = EM.activePrimary or L["No supported meter detected."]
					local secondary = EM.activeSecondary and (' + ' .. EM.activeSecondary) or ''
					return '|cffffd100' .. L["Active Meter:"] .. '|r ' .. primary .. secondary
				end,
			},
			mode = {
				type = 'select',
				order = 10,
				name = L["Embed Mode"],
				values = {
					off = L["Disabled"],
					single = L["Single"],
					dual = L["Dual"],
				},
			},
			targetPanel = {
				type = 'select',
				order = 11,
				name = L["Target Chat Panel"],
				values = {
					right = L["Right Chat"],
					left = L["Left Chat"],
				},
			},
			belowTab = {
				type = 'toggle',
				order = 12,
				name = L["Below Chat Tab"],
				desc = L["Anchor the embedded meter below the chat tab bar instead of covering it."],
			},
			visibility = {
				type = 'select',
				order = 13,
				name = L["Visibility"],
				values = {
					always = L["Always Show"],
					combat = L["Only in Combat"],
					group = L["Only in Group / Instance"],
				},
			},
			primary = {
				type = 'select',
				order = 20,
				name = L["Primary Meter"],
				values = function() return BuildMeterChoices(false) end,
			},
			secondary = {
				type = 'select',
				order = 21,
				name = L["Secondary Meter (Dual)"],
				disabled = function() return EM:GetDB().mode ~= 'dual' end,
				values = function() return BuildMeterChoices(true) end,
			},
			leftPercent = {
				type = 'range',
				order = 22,
				name = L["Left Window Width (%)"],
				min = 20,
				max = 80,
				step = 1,
				disabled = function() return EM:GetDB().mode ~= 'dual' end,
			},
			gap = {
				type = 'range',
				order = 23,
				name = L["Gap Between Windows"],
				min = 0,
				max = 10,
				step = 1,
				disabled = function() return EM:GetDB().mode ~= 'dual' end,
			},
			backdrop = {
				type = 'toggle',
				order = 30,
				name = L["Show Container Backdrop"],
			},
			transparent = {
				type = 'toggle',
				order = 31,
				name = L["Transparent Backdrop"],
				disabled = function() return not EM:GetDB().backdrop end,
			},
			refresh = {
				type = 'execute',
				order = 40,
				name = L["Force Refresh / Re-Embed"],
				func = function() EM:Refresh() end,
			},
		},
	}
end

SLASH_ELVUIEMBEDDER1 = '/embed'
SLASH_ELVUIEMBEDDER2 = '/embedder'
_G.SlashCmdList['ELVUIEMBEDDER'] = function(msg)
	msg = msg and msg:lower():trim() or ''
	if msg == 'toggle' then
		local db = EM:GetDB()
		db.hidden = not db.hidden
		EM:Refresh()
	elseif msg == 'refresh' then
		EM:Refresh()
	else
		E:ToggleOptions('ElvUI_Embedder')
	end
end

