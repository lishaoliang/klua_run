--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   mtd/common.lua
-- @brief  kpfs.mtd 用例公共辅助 (2.6)
-- @note   约定 **klua-test-design**; 固定盘槽 M 用于 mount 盘名
-- @history 修改历史
--  \n 2026 创建文件
--]]


local kco = require("kco")
local ksys = require("ksys")
local paths = require("lua_test.paths")
local fsutil = require("lua_test.util.fsutil")
local common = require("lua_test.pfs.make.common")
local mount_common = require("lua_test.pfs.mount.common")
local test_disk = require("lua_test.pfs.test_disk")

local M = {}

M.MTD_DRIVE = "M"


function M.fail(tag, msg)
	mount_common.fail(tag, msg)
end


function M.pass(tag)
	mount_common.pass(tag)
end


function M.require_kpfs()
	if common.require_kpfs() == nil then
		return nil
	end

	local ok_mtd = pcall(require, "kpfs.mtd")
	if not ok_mtd then
		print("skip: kpfs.mtd not loaded (deploy libkpfs plugin)")
		ksys.exit(0)
		return nil
	end

	return true
end


function M.setup_work(doc_id)
	return common.setup_work(doc_id)
end


function M.mtd_size_str()
	if paths.is_arm64_target() then
		return "2M"
	end
	return "4M"
end


function M.write_tree(work, name, content)
	local tree = paths.join(work, name)
	local ok, err = fsutil.ensure_dir(tree)
	if not ok then
		return nil, "mkdir " .. tostring(err)
	end

	local hello = paths.join(tree, "hello.txt")
	local fh, err_open = io.open(hello, "wb")
	if fh == nil then
		return nil, "open hello " .. tostring(err_open)
	end

	fh:write(content or "hello mtd\n")
	fh:close()
	return tree
end


function M.write_empty_tree(work, name)
	local tree = paths.join(work, name)
	local ok, err = fsutil.ensure_dir(tree)
	if not ok then
		return nil, "mkdir " .. tostring(err)
	end
	return tree
end


function M.raw_create(work, name, size_str, force)
	local mtd = require("kpfs.mtd")
	local path = paths.join(work, name)

	local rc, msg = mtd.raw.create({
		path = path,
		size = size_str or M.mtd_size_str(),
		force = force or true,
	})
	if rc ~= 0 then
		return nil, "raw.create rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	return path
end


function M.mount_flash(image_path, mode)
	local kpfs = require("kpfs")
	mode = mode or "r"
	return kpfs.mount(M.MTD_DRIVE, image_path, mode)
end


function M.umount_flash()
	local kpfs = require("kpfs")
	return kpfs.umount(M.MTD_DRIVE)
end


function M.drive_path(rel)
	rel = rel or "/"
	if rel:sub(1, 1) ~= "/" then
		rel = "/" .. rel
	end
	return M.MTD_DRIVE .. "1:" .. rel
end


function M.drive_path_part(part_index, rel)
	part_index = part_index or 1
	rel = rel or "/"
	if rel:sub(1, 1) ~= "/" then
		rel = "/" .. rel
	end
	return M.MTD_DRIVE .. tostring(part_index) .. ":" .. rel
end


function M.probe_fs_type(image_path)
	local probe = require("kpfs.probe")
	local info, rc, msg = probe.fs(image_path)
	if rc ~= 0 then
		return nil, rc, msg
	end

	local part = (info.parts or {})[1]
	if part ~= nil and part.fs_type ~= nil then
		return part.fs_type:lower(), 0, "OK"
	end

	local bare = info.bare_fs
	if bare ~= nil and bare.fs_type ~= nil then
		return bare.fs_type:lower(), 0, "OK"
	end

	return nil, -1, "no fs_type"
end


function M.probe_fs_type_part(image_path, part_index)
	local probe = require("kpfs.probe")
	local info, rc, msg = probe.fs(image_path)
	if rc ~= 0 then
		return nil, rc, msg
	end

	local part = (info.parts or {})[part_index]
	if part ~= nil and part.fs_type ~= nil then
		return part.fs_type:lower(), 0, "OK"
	end

	return nil, -1, "no fs_type for part " .. tostring(part_index)
end


function M.verify_mounted_fs(image_path, expected_type)
	local fs_type, rc, msg = M.probe_fs_type(image_path)
	if fs_type == nil then
		return false, "probe rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	if expected_type ~= nil and fs_type ~= expected_type:lower() then
		return false, "fs_type=" .. tostring(fs_type)
	end

	local rc_m, msg_m = M.mount_flash(image_path, "r")
	if rc_m ~= 0 then
		return false, "mount rc=" .. tostring(rc_m) .. " " .. tostring(msg_m)
	end

	local ok = mount_common.access_ok(M.drive_path("/"), "f")
	M.umount_flash()
	if not ok then
		return false, "access root failed after mount"
	end

	return true
end


function M.read_hello(image_path)
	local rc, msg = M.mount_flash(image_path, "r")
	if rc ~= 0 then
		return nil, "mount rc=" .. tostring(rc) .. " " .. tostring(msg)
	end

	local data = mount_common.read_file(M.drive_path("/hello.txt"))
	M.umount_flash()

	if data == nil then
		return nil, "read hello failed"
	end

	return data
end

return M
