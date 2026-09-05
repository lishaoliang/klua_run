--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   shell/ch1_s2_8.lua
-- @brief  1.2.8 UI messagebox
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n 无 kmessagebox type; parse kdialog /lua_test/s2_8 走 messagebox 栈
--  \n Open messagebox; Ok/Cancel messagebox_end
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 补充实现 UI messagebox
--]]


local klbui = require("klbcore.klbui")
local lang = require("klbcore.klbui.uires.lang")

local M = {}

local jq = function () end
local jq0 = function () end
local g_parsed = false

local BOX_PATH = '/lua_test/s2_8'
local SHWND_PATH = '/klbui/messagebox'


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
			['title'] = lang.str('KmsgHint'),
			['name'] = 'hint',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 44, 1248, 28},
			['title'] = string.format(lang.str('KmsgLabFmt'), '-', '0'),
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


local box_dialog = {
	['path'] = BOX_PATH,
	['type'] = 'kdialog',
	['pos'] = {400, 160, 480, 240},
	['name'] = 'msgbox',
	['title'] = lang.str('KmsgTitle'),
	['child'] = {
		{
			['type'] = 'kstatic',
			['pos'] = {8, 40, 464, 28},
			['title'] = lang.str('KmsgBody'),
			['name'] = 'msg_body',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {226, 196, 120, 32},
			['title'] = lang.str('Ok'),
			['name'] = 'msg_ok',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {352, 196, 120, 32},
			['title'] = lang.str('Cancel'),
			['name'] = 'msg_cancel',
		},
	}
}


-- UI 走 lang; 控制台固定英文 (避免终端乱码)
local function _lab(s, en)
	jq('lab').set('title', s)
	print('  messagebox: ' .. (en or s))
end


local function _end_box(value)
	klbui.messagebox_end()
	local n = klbui.messagebox_num()
	_lab(string.format(lang.str('KmsgLabFmt'), value, tostring(n)),
		'value=' .. tostring(value) .. ' num=' .. tostring(n))
end


local box_commands = {
	['msg_ok'] = {
		['click'] = function ()
			_end_box('ok')
		end,
	},
	['msg_cancel'] = {
		['click'] = function ()
			_end_box('cancel')
		end,
	},
}


-----------------------------------------------------------------------------------
-- commands

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
				klbui.parse(box_dialog, box_commands, css_720p)
				g_parsed = true
			end
		end,
	},
	['btn_open'] = {
		['click'] = function ()
			pcall(function ()
				klbui.shwnd_css(SHWND_PATH, { ['title'] = lang.str('KmsgTitle') })
			end)
			klbui.messagebox(BOX_PATH)
			local n = klbui.messagebox_num()
			_lab(string.format(lang.str('KmsgLabFmt'), '-', tostring(n)),
				'messagebox num=' .. tostring(n))
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

	_set_title('hint', lang.str('KmsgHint'))
	_set_title('btn_open', lang.str('Open'))
	box_dialog.title = lang.str('KmsgTitle')
	if type(box_dialog.child) == 'table' then
		box_dialog.child[1].title = lang.str('KmsgBody')
		box_dialog.child[2].title = lang.str('Ok')
		box_dialog.child[3].title = lang.str('Cancel')
	end

	pcall(function ()
		local kgui = require("kgui")
		kgui.set(BOX_PATH, 'title', lang.str('KmsgTitle'))
	end)

	_set_title('lab', string.format(lang.str('KmsgLabFmt'), '-', '0'))
end


-----------------------------------------------------------------------------------
-- 处理导出

M.css = {}
M.dialog = {}
M.jq = jq
M.jq0 = jq0


-- 重定向
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
