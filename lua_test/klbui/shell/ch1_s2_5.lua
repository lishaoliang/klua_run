--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   shell/ch1_s2_5.lua
-- @brief  1.2.5 UI kdiv
-- @note   约定 **klua-test-design**; 页面按 page_tmpl
--  \n kdiv 只排版不绘制; 体内两块 kstatic; 开窗由 ui.run
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 补充实现 UI kdiv
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

local dialog_720p = {
	['type'] = 'kview',
	['pos'] = {0, 0, -1, -1},
	['name'] = 'page',

	['child'] = {
		{
			['type'] = 'kstatic',
			['pos'] = {16, 12, 1248, 28},
			['title'] = lang.str('KdivHint'),
			['name'] = 'hint',
		},
		{
			['type'] = 'kstatic',
			['pos'] = {16, 44, 1248, 28},
			['title'] = string.format(lang.str('KdivLabFmt'), lang.str('KdivTitle'), '1'),
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
			['type'] = 'kdiv',
			['pos'] = {328, 80, 640, 400},
			['name'] = 'box',
			['title'] = lang.str('KdivTitle'),
			['index'] = 1,
			['child'] = {
				{
					['type'] = 'kstatic',
					['pos'] = {0, 0, 640, 28},
					['title'] = lang.str('KdivBody'),
					['name'] = 'box_body1',
				},
				{
					['type'] = 'kstatic',
					['pos'] = {0, 36, 640, 28},
					['title'] = lang.str('KdivBody'),
					['name'] = 'box_body2',
				},
			},
		},
	}
}


-----------------------------------------------------------------------------------
-- commands

local function _lab(s, en)
	jq('lab').set('title', s)
	print('  kdiv: ' .. (en or s))
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
			local title = jq('box').get('title')
			local index = jq('box').get('index')
			_lab(string.format(lang.str('KdivGetFmt'), tostring(title), tostring(index)),
				string.format('get title=%s index=%s', tostring(title), tostring(index)))
		end,
	},
	['btn_set'] = {
		['click'] = function ()
			jq('box').set('title', lang.str('KdivTitle2'))
			jq('box').set('index', 2)
			_lab(lang.str('KdivSet'), 'set box title=Div2 index=2')
		end,
	},
	['btn_hide'] = {
		['click'] = function ()
			local vis = jq('box').get('visibility')
			if 'hidden' == vis or false == vis then
				jq('box').set('visibility', 'visible')
				_lab(lang.str('KdivVisible'), 'box visible')
			else
				jq('box').set('visibility', 'hidden')
				_lab(lang.str('KdivHidden'), 'box hidden')
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

	_set_title('hint', lang.str('KdivHint'))
	_set_title('btn_get', lang.str('Get'))
	_set_title('btn_set', lang.str('Set'))
	_set_title('btn_hide', lang.str('ToggleHide'))
	_set_title('box_body1', lang.str('KdivBody'))
	_set_title('box_body2', lang.str('KdivBody'))
	_set_title('box', lang.str('KdivTitle'))
	_set_child(M.dialog, 'box', 'index', 1)
	if type(M.jq) == 'function' then
		pcall(function ()
			M.jq('box').set('index', 1)
		end)
	end

	_set_title('lab', string.format(lang.str('KdivLabFmt'), lang.str('KdivTitle'), '1'))
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

	jq = klbui.select(M.dialog)
	jq0 = klbui.select(M.dialog, true)

	M.jq = jq
	M.jq0 = jq0
end


return M
