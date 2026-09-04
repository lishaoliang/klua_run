--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   script/ch1_s2_2.lua
-- @brief  1.2.2 parse kview root
-- @note   约定 **klua-test-design**; 逻辑条; 顶层用 kview
-- @history 修改历史
--  \n 2026 创建文件
--]]


local common = require("lua_test.klbui.common")

local M = {}


function M.run(...)
	local kgui, klbui = common.require_klbui()
	if kgui == nil then
		return
	end

	local dialog = {
		['path'] = '/home',
		['type'] = 'kview',
		['pos'] = {0, 0, 320, 240},
	}

	klbui.parse(dialog)

	if dialog.path ~= '/home' then
		common.fail("path", "dialog.path=" .. tostring(dialog.path))
		return
	end

	local wnd = kgui.get_kwnd('/home')
	if wnd == nil then
		common.fail("get_kwnd", "nil")
		return
	end

	common.pass()
end


return M
