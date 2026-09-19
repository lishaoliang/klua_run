--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   demo.lua
-- @brief  lua demo 大型场景入口
-- @note   ./klua demo.lua <id|语义id> | list; **非** lua test
--   \n 场景库 lua_demo/; 禁止走 test.lua
-- @history 修改历史
--  \n 2026 创建文件
--]]


local kenv = require("kenv")
local base = kenv.base_path()

package.path = package.path
	.. ";" .. base .. "lua_demo/?.lua"
	.. ";" .. base .. "lua_demo/?/init.lua"
	.. ";" .. base .. "klbcore/?.lua"
	.. ";" .. base .. "klbcore/?/init.lua"

local bootstrap = require("lua_demo.bootstrap")
local registry = require("lua_demo.registry")

bootstrap.setup()

local prog, script, demo_id = bootstrap.get_cli_args()

if not demo_id or demo_id == "" or demo_id == "list" or demo_id == "help" or demo_id == "-h" or demo_id == "--help" then
	registry.print_help(prog, script)
	require("ksys").exit()
	return
end

if demo_id:match("^%d+$") then
	registry.print_help(prog, script, demo_id)
	require("ksys").exit()
	return
end

registry.run(demo_id, bootstrap.get_cli_extra_args())
