--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   shell/ch1_s3_1.lua
-- @brief  1.3.1 UI kdialog
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n 页壳根 kview; 子控件 kdialog 测标题栏 title/value
--  \n 左 Get/Set/hide; 开窗由 ui.run
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
		['kdialog'] = {
			['border-width'] = 1,
			['border-color'] = {255, 160, 120, 120},
			['background-color'] = {255, 48, 48, 56},
		},
		['kbutton'] = {
			['border-width'] = 1,
		},
	}
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
			['title'] = lang.str('KdialogHint'),
			['name'] = 'hint',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 44, 1248, 28},
			['title'] = string.format(lang.str('KdialogLabFmt'), lang.str('KdialogTitle')),
			['name'] = 'lab',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {16, 80, 90, 32},
			['title'] = lang.str('Get'),
			['name'] = 'btn_get',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {119, 80, 90, 32},
			['title'] = lang.str('Set'),
			['name'] = 'btn_set',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {222, 80, 90, 32},
			['title'] = lang.str('ToggleHide'),
			['name'] = 'btn_hide',
		},
		{
			['type'] = 'kdialog',
			['pos'] = {328, 80, 640, 400},
			['name'] = 'dlg',
			['title'] = lang.str('KdialogTitle'),
			['value'] = 'dlg1',
			['child'] = {
				{
					['type'] = 'kstatic',
					['pos'] = {8, 40, 624, 28},
					['title'] = lang.str('KdialogBody'),
					['name'] = 'dlg_body',
				},
			},
		},
	}
}


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
			local vis = jq('dlg').get('visibility')
			if 'hidden' == vis or false == vis then
				jq('dlg').set('visibility', 'visible')
				_lab(lang.str('KdialogVisible'), 'dlg visible')
			else
				jq('dlg').set('visibility', 'hidden')
				_lab(lang.str('KdialogHidden'), 'dlg hidden')
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
	if '720p' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '1366x768' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '900p' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '1080p' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '1440p' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	elseif '4k' == rs then
		M.dialog = dialog_720p
		M.css = css_720p
	else
		M.dialog = dialog_720p
		M.css = css_720p
	end

	-- 重定向 jq
	jq = klbui.select(M.dialog)
	jq0 = klbui.select(M.dialog, true)

	M.jq = jq
	M.jq0 = jq0
end


return M
