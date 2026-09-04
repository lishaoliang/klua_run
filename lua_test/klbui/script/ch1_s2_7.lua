--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   script/ch1_s2_7.lua
-- @brief  1.2.7 inline style title
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

	local dialog = {
		['path'] = '/home',
		['type'] = 'kview',
		['pos'] = {0, 0, 320, 240},
		['style'] = { ['title'] = 'via-style' },
	}

	klbui.parse(dialog)

	local title = kgui.get('/home', 'title')
	if title ~= 'via-style' then
		common.fail("title", tostring(title))
		return
	end

	common.pass()
end


return M
