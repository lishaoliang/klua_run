--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   script/ch1_s2_9.lua
-- @brief  1.2.9 has_global_css
-- @note   约定 **klua-test-design**; 逻辑条; knotexist 为未注册反例
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

	if not klbui.has_global_css('kview') then
		common.fail("kview", "expected true")
		return
	end

	if klbui.has_global_css('knotexist') then
		common.fail("knotexist", "expected false")
		return
	end

	common.pass()
end


return M
