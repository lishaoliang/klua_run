--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   envinfo.lua
-- @brief  lua_test 当前系统环境摘要
-- @history 修改历史
--  \n 2026 创建文件
--]]


local lfs = require("lfs")
local kos = require("kos")
local paths = require("lua_test.paths")

local M = {}


local function _env_or_nil(name)
	local v = os.getenv(name)
	if v == nil or v == "" then
		return nil
	end
	return v
end


function M.print()
	if os.getenv("LUA_TEST_NO_ENVINFO") == "1" then
		return
	end
	print("[lua_test env]")
	print("  os:", kos.os, "arch:", kos.arch)

	local home = _env_or_nil("HOME")
	if home then
		print("  HOME:", home)
	end

	local cwd = lfs.currentdir()
	if cwd then
		print("  cwd:", cwd)
	end

	print("  tmp_root:", paths.tmp_root())

	local override = _env_or_nil("LUA_TEST_TMP")
	if override then
		print("  LUA_TEST_TMP:", override)
	end

	local profile = _env_or_nil("LUA_TEST_PROFILE")
	if profile then
		print("  LUA_TEST_PROFILE:", profile)
	end

	print("")
end

return M
