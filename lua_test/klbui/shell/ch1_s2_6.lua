--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   shell/ch1_s2_6.lua
-- @brief  1.2.6 UI modal
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n 叠一层 kdialog /lua_test/s2_6; Open modal; Close modal_end
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 补充实现 UI modal
--]]


local klbui = require("klbcore.klbui")
local lang = require("klbcore.klbui.uires.lang")

local M = {}

local jq = function () end
local jq0 = function () end
local g_parsed = false

local OVERLAY_PATH = '/lua_test/s2_6'


-----------------------------------------------------------------------------------
-- css

local css_720p = {
	['type'] = {
	},
}


-----------------------------------------------------------------------------------
-- dialog

local dialog_720p = {
	['type'] = 'kview',
	['pos'] = {0, 0, -1, -1},
	['name'] = 'page',

	['child'] = {
		{
			['type'] = 'kstatic',
			['pos'] = {16, 12, 1248, 28},
			['title'] = lang.str('KmodalHint'),
			['name'] = 'hint',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 44, 1248, 28},
			['title'] = string.format(lang.str('KmodalLabFmt'), '1'),
			['name'] = 'lab',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {16, 80, 90, 32},
			['title'] = lang.str('Open'),
			['name'] = 'btn_open',
		},
	}
}


local overlay_dialog = {
	['path'] = OVERLAY_PATH,
	['type'] = 'kdialog',
	['pos'] = {400, 160, 480, 240},
	['name'] = 'overlay',
	['title'] = lang.str('KmodalTitle'),
	['child'] = {
		{
			['type'] = 'kstatic',
			['pos'] = {8, 40, 464, 28},
			['title'] = lang.str('KmodalBody'),
			['name'] = 'ov_body',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {8, 80, 90, 32},
			['title'] = lang.str('Close'),
			['name'] = 'ov_close',
		},
	}
}


local overlay_commands = {
	['ov_close'] = {
		['click'] = function ()
			klbui.modal_end(false, OVERLAY_PATH)
			local n = klbui.modal_num()
			jq('lab').set('title', string.format(lang.str('KmodalLabFmt'), tostring(n)))
			print('  modal: end num=' .. tostring(n))
		end,
	},
}


-----------------------------------------------------------------------------------
-- commands

-- UI 走 lang; 控制台固定英文 (避免终端乱码)
local function _lab(s, en)
	jq('lab').set('title', s)
	print('  modal: ' .. (en or s))
end


local function _set_child(dialog, name, key, val)
	local function walk(node)
		if type(node) ~= 'table' then
			return false
		end

		if node.name == name then
			node[key] = val
			return true
		end

		local child = node.child
		if type(child) ~= 'table' then
			return false
		end

		for i = 1, #child do
			if walk(child[i]) then
				return true
			end
		end

		return false
	end

	walk(dialog)
end


local function _set_title(name, title)
	_set_child(M.dialog, name, 'title', title)
	if type(M.jq) == 'function' then
		pcall(function ()
			M.jq(name).set('title', title)
		end)
	end
end


M.commands = {
	['page'] = {
		['onload'] = function ()
			if not g_parsed then
				klbui.parse(overlay_dialog, overlay_commands, css_720p)
				g_parsed = true
			end
		end,
	},
	['btn_open'] = {
		['click'] = function ()
			klbui.modal(OVERLAY_PATH)
			local n = klbui.modal_num()
			_lab(string.format(lang.str('KmodalLabFmt'), tostring(n)),
				'modal num=' .. tostring(n))
		end,
	},
}


-- @brief 按语言更新本页文案
-- @param [in] code[string]
-- @return 无
M.apply_lang = function (code)
	if type(code) == 'string' and code ~= '' then
		lang.apply(code)
	end

	_set_title('hint', lang.str('KmodalHint'))
	_set_title('btn_open', lang.str('Open'))
	overlay_dialog.title = lang.str('KmodalTitle')
	if type(overlay_dialog.child) == 'table' then
		overlay_dialog.child[1].title = lang.str('KmodalBody')
		overlay_dialog.child[2].title = lang.str('Close')
	end

	pcall(function ()
		klbui.get_wnd(OVERLAY_PATH)
		local kgui = require("kgui")
		kgui.set(OVERLAY_PATH, 'title', lang.str('KmodalTitle'))
	end)

	local n = '1'
	pcall(function ()
		n = tostring(klbui.modal_num())
	end)
	_set_title('lab', string.format(lang.str('KmodalLabFmt'), n))
end


-----------------------------------------------------------------------------------
-- 处理导出

M.css = {}
M.dialog = {}
M.jq = jq
M.jq0 = jq0


M.relocation = function (rs)
	if 'HD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'WXGA' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'HD+' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'Full HD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif 'QHD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '4K UHD' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	else
		M.dialog = dialog_720p
		M.css = css_720p
	end

	g_parsed = false
	jq = klbui.select(M.dialog)
	jq0 = klbui.select(M.dialog, true)

	M.jq = jq
	M.jq0 = jq0
end


return M
