--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   script/ch1_s2_1.lua
-- @brief  1.2.1 require kgui / klbui
-- @note   约定 **klua-test-design**; 逻辑条; 模块失败则 skip
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

	if type(klbui.parse) ~= "function" then
		common.fail("parse", "klbui.parse is not a function")
		return
	end

	if type(kgui.append) ~= "function" then
		common.fail("append", "kgui.append is not a function")
		return
	end

	common.pass()
end


return M
