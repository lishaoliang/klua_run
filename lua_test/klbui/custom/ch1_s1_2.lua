--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   custom/ch1_s1_2.lua
-- @brief  1.1.2 UI 自定义文本与按钮
-- @note   约定 **klua-test-design**; 页面按 page_tmpl; 点 Ping 后标签应变
--  \n 本页满窗 parse; 开窗由 lua_test.klbui.ui.run
-- @history 修改历史
--  \n 2026 创建文件
--  \n 2026 省略 dialog path, parse 自动分配
--]]


local klbui = require("klbcore.klbui")

local M = {}

local jq = function () end
local jq0 = function () end


-----------------------------------------------------------------------------------
-- css

local css_720p = {
	['type'] = {
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
			['pos'] = {16, 16, 480, 32},
			['title'] = 'custom widgets',
			['name'] = 'lab',
		},
		{
			['type'] = 'kbutton',
			['pos'] = {16, 64, 120, 32},
			['title'] = 'Ping',
			['name'] = 'btn_ping',
		},
	}
}


-----------------------------------------------------------------------------------
-- commands

M.commands = {
	['btn_ping'] = {
		['click'] = function ()
			jq('lab').set('title', 'ping ok')
			print('  ping: lab title=ping ok')
		end,
	},
}


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

	-- 重定向 jq
	jq = klbui.select(M.dialog)
	jq0 = klbui.select(M.dialog, true)

	M.jq = jq
	M.jq0 = jq0
end


return M
