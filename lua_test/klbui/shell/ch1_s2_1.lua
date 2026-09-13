--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   shell/ch1_s2_1.lua
-- @brief  1.2.1 UI kdialog
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n 根 kdialog 固定 720p(1280x720) 相对画布居中; 九宫格背景 S001 /scale9/dialog_bg
--  \n 内容区 dlg_body 固定 640x480; 左 Get/Set/hide; 开窗由 ui.run
--  \n 文案 lang.str; apply_lang 由 ui.run 调用
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 补充实现 UI kdialog
--]]


local klbui = require("klbcore.klbui")
local lang = require("klbcore.klbui.uires.lang")

local M = {}

local jq = function () end
local jq0 = function () end


-----------------------------------------------------------------------------------
-- css

local css_720p = {
	['type'] = {
	},
}


-----------------------------------------------------------------------------------
-- dialog

local PAGE_W = 1280
local PAGE_H = 720
local BODY_W = PAGE_W - 32
local CONTENT_W = 640
local CONTENT_H = 480
local TITLE_H = 32
local PAD = 16
local ROW_H = 28
local BTN_H = 32
local GAP = 8

local Y_HINT = TITLE_H + PAD
local Y_LAB = Y_HINT + ROW_H + GAP
local Y_BTN = Y_LAB + ROW_H + GAP
local Y_BODY = Y_BTN + BTN_H + GAP


local dialog_720p = {
	['type'] = 'kdialog',
	['pos'] = {0, 0, PAGE_W, PAGE_H},
	['name'] = 'dlg',
	['title'] = lang.str('KdialogTitle'),
	['value'] = 'dlg1',

	['child'] = {
		{
			['type'] = 'kstatic',
			['pos'] = {16, Y_HINT, BODY_W, ROW_H},
			['title'] = lang.str('KdialogHint'),
			['name'] = 'hint',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, Y_LAB, BODY_W, ROW_H},
			['title'] = string.format(lang.str('KdialogLabFmt'), lang.str('KdialogTitle')),
			['name'] = 'lab',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {16, Y_BTN, 90, BTN_H},
			['title'] = lang.str('Get'),
			['name'] = 'btn_get',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {119, Y_BTN, 90, BTN_H},
			['title'] = lang.str('Set'),
			['name'] = 'btn_set',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {222, Y_BTN, 90, BTN_H},
			['title'] = lang.str('ToggleHide'),
			['name'] = 'btn_hide',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, Y_BODY, CONTENT_W, CONTENT_H},
			['title'] = lang.str('KdialogBody'),
			['name'] = 'dlg_body',
		},
	}
}


local function _center_page(rs)
	local pref = require("lua_test.klbui.pref")
	local sz = pref.size(rs)
	local w = sz.w
	local h = sz.h
	local x = math.floor((w - PAGE_W) / 2)
	local y = math.floor((h - PAGE_H) / 2)

	if x < 0 then
		x = 0
	end

	if y < 0 then
		y = 0
	end

	dialog_720p.pos = {x, y, PAGE_W, PAGE_H}
end


-----------------------------------------------------------------------------------
-- commands

-- UI 走 lang; 控制台固定英文 (避免终端乱码)
local function _lab(s, en)
	jq('lab').set('title', s)
	print('  kdialog: ' .. (en or s))
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
	['btn_get'] = {
		['click'] = function ()
			local title = jq('dlg').get('title')
			local value = jq('dlg').get('value')
			_lab(string.format(lang.str('KdialogGetFmt'),
				tostring(title), tostring(value)),
				string.format('get title=%s value=%s',
					tostring(title), tostring(value)))
		end,
	},
	['btn_set'] = {
		['click'] = function ()
			jq('dlg').set('title', lang.str('KdialogTitle2'))
			jq('dlg').set('value', 'dlg2')
			_lab(lang.str('KdialogSet'), 'set dlg title=Dialog2 value=dlg2')
		end,
	},
	['btn_hide'] = {
		['click'] = function ()
			local vis = jq('dlg_body').get('visibility')
			if 'hidden' == vis or false == vis then
				jq('dlg_body').set('visibility', 'visible')
				_lab(lang.str('KdialogVisible'), 'dlg_body visible')
			else
				jq('dlg_body').set('visibility', 'hidden')
				_lab(lang.str('KdialogHidden'), 'dlg_body hidden')
			end
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

	_set_title('hint', lang.str('KdialogHint'))
	_set_title('btn_get', lang.str('Get'))
	_set_title('btn_set', lang.str('Set'))
	_set_title('btn_hide', lang.str('ToggleHide'))
	_set_title('dlg_body', lang.str('KdialogBody'))
	_set_title('dlg', lang.str('KdialogTitle'))
	_set_child(M.dialog, 'dlg', 'value', 'dlg1')
	if type(M.jq) == 'function' then
		pcall(function ()
			M.jq('dlg').set('value', 'dlg1')
		end)
	end

	_set_title('lab', string.format(lang.str('KdialogLabFmt'), lang.str('KdialogTitle')))
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

	_center_page(rs)

	-- 重定向 jq
	jq = klbui.select(M.dialog)
	jq0 = klbui.select(M.dialog, true)

	M.jq = jq
	M.jq0 = jq0
end


return M
