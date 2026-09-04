--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   make/common.lua
-- @brief  kpfs 制盘用例公共辅助 (2.2)
-- @note   约定 **klua-test-design**
-- @history 修改历史
--  \n 2026 创建文件
--]]


local ksys = require("ksys")
local kco = require("kco")
local paths = require("lua_test.paths")
local fsutil = require("lua_test.util.fsutil")
local report = require("lua_test.report")

local M = {}


function M.fail(tag, msg)
	report.fail(msg)
	ksys.exit(1)
end


function M.pass()
	kco.timeout(100, function ()
		report.pass()
		ksys.exit(0)
	end)
end


function M.require_kpfs()
	local ok, kpfs = pcall(require, "kpfs")
	if not ok then
		report.skip("kpfs not loaded (deploy libkpfs plugin)")
		ksys.exit(0)
		return nil
	end
	return kpfs
end


function M.dynamic_size_str()
	if paths.is_arm64_target() then
		return "2M"
	end
	return "4M"
end


function M.fixed_size_str()
	if paths.is_arm64_target() then
		return "2M"
	end
	return "8M"
end


--- exFAT mkfs/mkvol 需更大容量 (2.2.6/2.2.7)
function M.exfat_disk_size_str()
	if paths.is_arm64_target() then
		return "8M"
	end
	return "16M"
end


function M.size_str_to_bytes(size_str)
	local n, unit = string.match(tostring(size_str), "^(%d+)%s*([KMGkmg]?)$")
	if n == nil then
		return nil
	end

	local bytes = tonumber(n)
	if bytes == nil then
		return nil
	end

	unit = string.upper(unit or "")
	if unit == "K" then
		bytes = bytes * 1024
	elseif unit == "M" then
		bytes = bytes * 1024 * 1024
	elseif unit == "G" then
		bytes = bytes * 1024 * 1024 * 1024
	elseif unit ~= "" then
		return nil
	end

	return bytes
end


function M.setup_work(doc_id)
	local work = paths.case_dir(doc_id)
	local ok_dir, err_dir = fsutil.ensure_dir(work)
	if not ok_dir then
		return nil, "mkdir " .. tostring(err_dir)
	end
	return work
end


function M.probe_mount_ok(info)
	local part_count = info.part_count or 0

	if part_count > 0 then
		local part = (info.parts or {})[1]
		if part ~= nil and part.mount_ok == true then
			return true
		end
		return false
	end

	local bare = info.bare_fs
	if bare ~= nil and bare.mount_ok == true then
		return true
	end
	return false
end


function M.fs_type_match(actual, expected)
	if actual == nil or expected == nil then
		return false
	end
	return string.lower(tostring(actual)) == string.lower(tostring(expected))
end


--- probe.all / probe.fs 单分区项是否已格式化且 FS 类型匹配
function M.part_formatted(part, fs_type)
	if part == nil or part.mount_ok ~= true then
		return false
	end
	if fs_type == nil or fs_type == "" then
		return true
	end
	return M.fs_type_match(part.fs_type, fs_type)
end

return M
