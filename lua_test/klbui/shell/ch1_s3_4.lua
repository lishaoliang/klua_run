--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   shell/ch1_s3_4.lua
-- @brief  1.3.4 UI kmenu
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n 子 kmenu; onload append 三项; onchange 写 lab; 开窗由 ui.run
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 补充实现 UI kmenu
--]]


local klbui = require("klbcore.klbui")
local lang = require("klbcore.klbui.uires.lang")

local M = {}

local jq = function () end
local jq0 = function () end
local g_appended = false


-----------------------------------------------------------------------------------
-- css

local css_720p = {
	['type'] = {
		['kmenu'] = {
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
			['title'] = lang.str('KmenuHint'),
			['name'] = 'hint',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 44, 1248, 28},
			['title'] = string.format(lang.str('KmenuLabFmt'), '-'),
			['name'] = 'lab',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {16, 80, 90, 32},
			['title'] = lang.str('Get'),
			['name'] = 'btn_get',
		},
		{
			['type'] = 'kmenu',
			['pos'] = {328, 80, 240, 160},
			['name'] = 'menu',
		},
	}
}


-----------------------------------------------------------------------------------
-- commands

local function _lab(s, en)
	jq('lab').set('title', s)
	print('  kmenu: ' .. (en or s))
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


local function _append_items()
	if g_appended then
		return
	end

	jq('menu').append({
		{ ['value'] = '1', ['title'] = lang.str('Item1') },
		{ ['value'] = '2', ['title'] = lang.str('Item2') },
		{ ['value'] = '3', ['title'] = lang.str('Item3') },
	})
	g_appended = true
end


M.commands = {
	['page'] = {
		['onload'] = function ()
			_append_items()
		end,
	},
	['btn_get'] = {
		['click'] = function ()
			local value = jq('menu').get('value')
			_lab(string.format(lang.str('KmenuGetFmt'), tostring(value)),
				'get value=' .. tostring(value))
		end,
	},
	['menu'] = {
		['onchange'] = function ()
			local value = jq('menu').get('value')
			_lab(string.format(lang.str('KmenuLabFmt'), tostring(value)),
				'onchange value=' .. tostring(value))
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

	_set_title('hint', lang.str('KmenuHint'))
	_set_title('btn_get', lang.str('Get'))
	_set_title('lab', string.format(lang.str('KmenuLabFmt'), '-'))
end


-----------------------------------------------------------------------------------
-- 处理导出

M.css = {}
M.dialog = {}
M.jq = jq
M.jq0 = jq0


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

	g_appended = false
	jq = klbui.select(M.dialog)
	jq0 = klbui.select(M.dialog, true)

	M.jq = jq
	M.jq0 = jq0
end


return M
