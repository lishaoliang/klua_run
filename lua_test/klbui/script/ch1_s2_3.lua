--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   script/ch1_s2_3.lua
-- @brief  1.2.3 parse kview + kstatic child
-- @note   约定 **klua-test-design**; 逻辑条
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

	local child = {
		['type'] = 'kstatic',
		['pos'] = {0, 0, 80, 24},
		['title'] = 'lab',
	}
	local dialog = {
		['path'] = '/home',
		['type'] = 'kview',
		['pos'] = {0, 0, 320, 240},
		['child'] = { child },
	}

	klbui.parse(dialog)

	local sub = child.path
	if type(sub) ~= 'string' or string.sub(sub, 1, 6) ~= '/home/' then
		common.fail("child.path", tostring(sub))
		return
	end

	if kgui.get_kwnd('/home') == nil then
		common.fail("get_kwnd", "root nil")
		return
	end

	if kgui.get_kwnd(sub) == nil then
		common.fail("get_kwnd", "child nil")
		return
	end

	common.pass()
end


return M
