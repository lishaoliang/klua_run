--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   kco_fork.lua
-- @brief  kco.fork / kco.timeout 烟测
-- @history 修改历史
--  \n 2026 创建文件
--]]


local kco = require("kco")
local common = require("lua_test.pfs.make.common")

local M = {}


function M.run(...)
	kco.fork(function (a, b)
		print("  fork:", a, b)
	end, "fork", 1, "ok")

	kco.timeout(500, function ()
		common.pass()
	end)
end

return M
