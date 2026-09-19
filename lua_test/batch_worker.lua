--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   batch_worker.lua
-- @brief  lua_test 批量 worker 入口 (kthread.start → registry.run)
-- @note   约定 **klua-test-design**; 结果经 kmcache 回传主线程
-- @history 修改历史
--  \n 2026 创建文件
--]]


local kenv = require("kenv")
local base = kenv.base_path()

package.path = package.path
	.. ";" .. base .. "lua_test/?.lua"
	.. ";" .. base .. "lua_test/?/init.lua"
	.. ";" .. base .. "klbcore/?.lua"
	.. ";" .. base .. "klbcore/?/init.lua"

local ksys = require("ksys")
local kmcache = require("kmcache")

local args = { ksys.get_args() }
local result_key = args[1]
local doc_id = args[2]
local extra = {}

for i = 3, #args do
	extra[#extra + 1] = args[i]
end

local saw_fail = false
local saw_pass = false
local result_stored = false

local orig_print = print

local function _scan_output(s)
	if s == nil or s == "" then
		return
	end

	if s:find("%[FAIL%]") or s:find("lua_test%.[%w_%.]+%s+FAIL:") then
		saw_fail = true
	end

	if s:find("%[PASS%]") or s:find("lua_test%.[%w_%.]+%s+PASS") then
		saw_pass = true
	end

	if s:find("%[SKIP%]") then
		saw_pass = true
	end
end

print = function (...)
	local n = select("#", ...)
	local parts = {}

	for i = 1, n do
		parts[i] = tostring(select(i, ...))
	end

	local line = table.concat(parts, "\t")
	_scan_output(line)
	orig_print(...)
end

local function _compute_passed(code)
	if saw_fail then
		return false
	end

	if saw_pass then
		return true
	end

	if code == nil then
		return true
	end

	return code == 0
end

local function _store_result(passed, code)
	kmcache.set(result_key, "done", passed, code or 0)
	result_stored = true
end

local orig_exit = ksys.exit

ksys.exit = function (code)
	local passed = _compute_passed(code)
	_store_result(passed, code)
	orig_exit(code or 0)
end

local registry = require("lua_test.registry")
local report = require("lua_test.report")

local item = registry.resolve(doc_id)
if item ~= nil then
	report.set_case(item.doc_id, item.desc)
end

registry.run(doc_id, table.unpack(extra))

-- 与 test.lua 单条一致: run 返回后由 C 循环直至用例 ksys.exit (kco.timeout / HTTP co_recv)
-- 此处禁止 orig_exit, 否则会在异步 IO 未完成时拆掉 netconn
