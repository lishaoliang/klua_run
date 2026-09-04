--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   script/ch1_s2_6.lua
-- @brief  1.2.6 select by id
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
		['type'] = 'kview',
		['name'] = 'root',
		['child'] = {
			{
				['type'] = 'kstatic',
				['id'] = 's1',
				['name'] = 'lab1',
			},
		},
	}

	local f = klbui.select(dialog)
	local r = f('#s1')
	if r == nil or r._wnds == nil or #r._wnds ~= 1 then
		local n = 0
		if r ~= nil and r._wnds ~= nil then
			n = #r._wnds
		end
		common.fail("select", "count=" .. tostring(n))
		return
	end

	if r._wnds[1].id ~= 's1' then
		common.fail("id", tostring(r._wnds[1].id))
		return
	end

	common.pass()
end


return M
