--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   http/ch3_s2_6.lua
-- @brief  3.2.6 klbhttp.co_post 公网站点
-- @note   约定 **klua-test-design**; 不通则 skip; 须回应体回显 data
-- @history 修改历史
--  \n 2026 创建文件
--]]
local kco = require("kco")
local common = require("lua_test.klb.http.common")


local M = {}

local DATA = "klbhttp-public-post"

local URLS = {
	"http://httpbin.org/post",
	"https://httpbin.org/post",
	"http://postman-echo.com/post",
	"https://postman-echo.com/post",
}


function M.run(...)
	local klbhttp = common.require_klbhttp()
	if not klbhttp then
		return
	end

	common.arm_timeout(20000)

	kco.fork(function ()
		common.try_public(URLS, function (url)
			return klbhttp.co_post(url, DATA, {
				content_type = "text/plain",
			})
		end, DATA)
	end)
end


return M
