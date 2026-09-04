--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   probe/ch2_s1_1.lua
-- @brief  kpfs.version 烟测
-- @note   须 libkpfs 插件
-- @history 修改历史
--  \n 2026 创建文件
--]]


local common = require("lua_test.pfs.make.common")

local M = {}


function M.run(...)
	local kpfs = common.require_kpfs()
	if kpfs == nil then
		return
	end

	local ver = kpfs.version()
	if ver == nil or ver == "" then
		common.fail("version", "empty version")
		return
	end

	print("  version:", ver)
	common.pass()
end

return M
