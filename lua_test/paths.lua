--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   paths.lua
-- @brief  lua_test 临时目录 (Win base_path/tmp, Linux ~/tmp, arm64 /tmp)
-- @note   环境变量 LUA_TEST_TMP 可覆盖; arm64 /tmp 分区约 256MiB
-- @history 修改历史
--  \n 2026 创建文件
--]]


local kenv = require("kenv")
local kos = require("kos")

local M = {}

M.ARM64_TMP_BUDGET = 256 * 1024 * 1024
M.ARM64_MAX_IMAGE = 32 * 1024 * 1024


function M.is_arm64_target()
	local profile = os.getenv("LUA_TEST_PROFILE")
	if profile == "arm64" then
		return true
	end

	local home = os.getenv("HOME")
	if home == "/tmp/app" then
		return true
	end

	return kos.arch == "aarch64" or kos.arch == "arm64"
end


function M.tmp_root()
	local override = os.getenv("LUA_TEST_TMP")
	if override and override ~= "" then
		return override
	end

	if kos.os == "windows" then
		return kenv.base_path() .. "tmp"
	end

	if M.is_arm64_target() then
		return "/tmp"
	end

	local home = os.getenv("HOME") or ""
	if home == "" then
		return "/tmp"
	end

	if home:sub(-1) == "/" then
		return home .. "tmp"
	end
	return home .. "/tmp"
end


function M.join(a, b)
	if a:sub(-1) == "/" or a:sub(-1) == "\\" then
		return a .. b
	end
	return a .. "/" .. b
end


function M.case_dir(case_id)
	local safe = case_id:gsub("%.", "_")
	return M.join(M.join(M.tmp_root(), "lua_test"), safe)
end


function M.max_image_bytes()
	if M.is_arm64_target() then
		return M.ARM64_MAX_IMAGE
	end
	return 512 * 1024 * 1024
end

return M
