--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   test.lua
-- @brief  klb / kpfs Lua 接口手测唯一入口
-- @note   ./klua test.lua <doc_id|语义id|a|1.x|1.1.x> | list; 约定 **klua-test-design**
--   \n 用例库 bin/lua_test/; 文档 klua_doc/lua/lua_test/readme.md
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

local bootstrap = require("lua_test.bootstrap")
local registry = require("lua_test.registry")
local envinfo = require("lua_test.envinfo")

bootstrap.setup()

local prog, script, case_id = bootstrap.get_cli_args()

envinfo.print()

if not case_id or case_id == "" or case_id == "list" or case_id == "help" or case_id == "-h" or case_id == "--help" then
	registry.print_help(prog, script)
	require("ksys").exit()
	return
end

if registry.is_batch_filter(case_id) then
	registry.run_batch(case_id, prog, script, bootstrap.get_cli_extra_args())
	return
end

registry.run(case_id, bootstrap.get_cli_extra_args())
