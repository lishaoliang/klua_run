--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   custom/page_tmpl.lua
-- @brief  1.1 custom UI 页面模块模板
-- @note   约定 **klua-test-design**; 复制为 custom/ch1_s1_{z}.lua
--  \n 只改 css / dialog / commands; 开窗由 lua_test.klbui.ui.run
--  \n 本页满窗 parse; 元素只写本文件
--  \n 范例 custom/ch1_s1_1.lua
-- @history 修改历史
--  \n 2026 创建文件
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
		-- 控件
	}
}


-----------------------------------------------------------------------------------
-- commands

M.commands = {
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
