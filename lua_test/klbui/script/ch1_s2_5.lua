--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   script/ch1_s2_5.lua
-- @brief  1.2.5 select by type
-- @note   约定 **klua-test-design**; 逻辑条; 多选
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
				['name'] = 'lab1',
			},
		},
	}

	local f = klbui.select(dialog, true)
	local r = f(':kstatic')
	if r == nil or r._wnds == nil or #r._wnds < 1 then
		common.fail("kstatic", "empty")
		return
	end

	for i = 1, #r._wnds do
		if r._wnds[i].type ~= 'kstatic' then
			common.fail("kstatic", "mixed type")
			return
		end
	end

	local rv = f(':kview')
	if rv == nil or rv._wnds == nil or #rv._wnds < 1 then
		common.fail("kview", "empty")
		return
	end

	local found_root = false
	for i = 1, #rv._wnds do
		if rv._wnds[i] == dialog then
			found_root = true
			break
		end
	end

	if not found_root then
		common.fail("kview", "root missing")
		return
	end

	common.pass()
end


return M
