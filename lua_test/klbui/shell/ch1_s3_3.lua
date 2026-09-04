--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   shell/ch1_s3_3.lua
-- @brief  1.3.3 UI ktab
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n 子 ktab 两页 kview; 点页签切页; 开窗由 ui.run
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 补充实现 UI ktab
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
		['ktab'] = {
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
			['title'] = lang.str('KtabHint'),
			['name'] = 'hint',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 44, 1248, 28},
			['title'] = string.format(lang.str('KtabLabFmt'), lang.str('Tab1')),
			['name'] = 'lab',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {16, 80, 90, 32},
			['title'] = lang.str('Get'),
			['name'] = 'btn_get',
		},
		{
			['type'] = 'ktab',
			['pos'] = {328, 80, 640, 400},
			['name'] = 'tab',
			['title'] = lang.str('Tab1'),
			['child'] = {
				{
					['type'] = 'kview',
					['pos'] = {0, 36, 640, 364},
					['name'] = 'tab1',
					['title'] = lang.str('Tab1'),
					['child'] = {
						{
							['type'] = 'kstatic',
							['pos'] = {8, 8, 624, 28},
							['title'] = lang.str('KtabBody1'),
							['name'] = 'tab1_body',
						},
					},
				},
				{
					['type'] = 'kview',
					['pos'] = {0, 36, 640, 364},
					['name'] = 'tab2',
					['title'] = lang.str('Tab2'),
					['child'] = {
						{
							['type'] = 'kstatic',
							['pos'] = {8, 8, 624, 28},
							['title'] = lang.str('KtabBody2'),
							['name'] = 'tab2_body',
						},
					},
				},
			},
		},
	}
}


-----------------------------------------------------------------------------------
-- commands

local function _lab(s, en)
	jq('lab').set('title', s)
	print('  ktab: ' .. (en or s))
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
			local title = jq('tab').get('title')
			_lab(string.format(lang.str('KtabGetFmt'), tostring(title)),
				'get title=' .. tostring(title))
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

	_set_title('hint', lang.str('KtabHint'))
	_set_title('btn_get', lang.str('Get'))
	_set_title('tab1', lang.str('Tab1'))
	_set_title('tab2', lang.str('Tab2'))
	_set_title('tab1_body', lang.str('KtabBody1'))
	_set_title('tab2_body', lang.str('KtabBody2'))
	_set_title('tab', lang.str('Tab1'))
	_set_title('lab', string.format(lang.str('KtabLabFmt'), lang.str('Tab1')))
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

	jq = klbui.select(M.dialog)
	jq0 = klbui.select(M.dialog, true)

	M.jq = jq
	M.jq0 = jq0
end


return M
