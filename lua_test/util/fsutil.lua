--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   fsutil.lua
-- @brief  lua_test 目录创建 (lfs)
-- @history 修改历史
--  \n 2026 创建文件
--]]


local lfs = require("lfs")

local M = {}


local function _split_path(path)
	local parts = {}
	for seg in string.gmatch(path, "[^/\\]+") do
		parts[#parts + 1] = seg
	end
	return parts
end


function M.exists(path)
	local mode = lfs.attributes(path, "mode")
	return mode ~= nil
end


function M.mkdir_one(path)
	if M.exists(path) then
		return true
	end
	local ok, err = lfs.mkdir(path)
	if ok then
		return true
	end
	if M.exists(path) then
		return true
	end
	return false, err
end


function M.ensure_dir(path)
	if path == nil or path == "" then
		return false, "empty path"
	end

	local is_abs = path:sub(1, 1) == "/" or path:match("^%a:[/\\]")
	local parts = _split_path(path)
	local cur = ""

	if is_abs then
		if path:match("^%a:[/\\]") then
			cur = parts[1]
			table.remove(parts, 1)
		else
			cur = "/"
		end
	end

	for _, seg in ipairs(parts) do
		if cur == "" or cur == "/" then
			cur = cur .. seg
		elseif cur:sub(-1) == "/" or cur:sub(-1) == "\\" then
			cur = cur .. seg
		else
			cur = cur .. "/" .. seg
		end

		local ok, err = M.mkdir_one(cur)
		if not ok then
			return false, err
		end
	end

	return true
end

return M
