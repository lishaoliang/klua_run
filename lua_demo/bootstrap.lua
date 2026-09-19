--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   bootstrap.lua
-- @brief  lua_demo 引导: CLI 参数
-- @history 修改历史
--  \n 2026 创建文件
--]]


local M = {}

local _args = nil


-- @brief 读取 CLI 参数
-- @return 无
function M.setup()
	_args = { require("ksys").get_args() }
end


-- @brief 取宿主路径, 入口脚本, demo id
-- @return prog[string], script[string], demo_id[string]
function M.get_cli_args()
	if not _args then
		M.setup()
	end

	local prog = _args[1]
	local script = _args[2]
	local demo_id = _args[3]

	return prog, script, demo_id
end


-- @brief 取 demo id 之后的额外参数
-- @return 额外参数 (可变长)
function M.get_cli_extra_args()
	if not _args then
		M.setup()
	end

	local extra = {}
	for i = 4, #_args do
		extra[#extra + 1] = _args[i]
	end
	return table.unpack(extra)
end

return M
