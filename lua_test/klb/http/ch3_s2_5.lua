--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   http/ch3_s2_5.lua
-- @brief  3.2.5 klbhttp.co_get 公网站点
-- @note   约定 **klua-test-design**; 不通则 skip
-- @history 修改历史
--  \n 2026 创建文件
--]]
local kco = require("kco")
local common = require("lua_test.klb.http.common")


local M = {}

local URLS = {
	"http://example.com/",
	"http://neverssl.com/",
	"http://www.baidu.com/",
	"https://example.com/",
}


function M.run(...)
	local klbhttp = common.require_klbhttp()
	if not klbhttp then
		return
	end

	common.arm_timeout(20000)

	kco.fork(function ()
		common.try_public(URLS, function (url)
			return klbhttp.co_get(url)
		end)
	end)
end


return M
