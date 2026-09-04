--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   bootstrap.lua
-- @brief  lua_test 引导: package.path 与 CLI 参数
-- @history 修改历史
--  \n 2026 创建文件
--]]


local M = {}

local _args = nil


function M.setup()
	_args = { require("ksys").get_args() }
end


function M.get_cli_args()
	if not _args then
		M.setup()
	end

	local prog = _args[1]
	local script = _args[2]
	local case_id = _args[3]

	return prog, script, case_id
end


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
