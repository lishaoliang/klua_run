--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   http/ch3_s2_4.lua
-- @brief  3.2.4 klbhttp.listen / co_accept 环回烟测
-- @note   约定 **klua-test-design**
-- @history 修改历史
--  \n 2026 创建文件
--]]
local kco = require("kco")
local common = require("lua_test.klb.http.common")


local M = {}

local PORT = 18724
local BODY = "hello-listen"


function M.run(...)
	local klbhttp = common.require_klbhttp()
	if not klbhttp then
		return
	end

	local l = klbhttp.new_listen()
	l:open(PORT)
	common.arm_timeout(5000)

	kco.fork(function ()
		common.serve_once(l, function (head)
			if not string.find(head, "GET /ping", 1, true) then
				common.fail("req", head)
				return ""
			end

			return BODY
		end)
	end)

	kco.fork(function ()
		local msg, head, body = klbhttp.co_get("http://127.0.0.1:" .. tostring(PORT) .. "/ping")
		l:close()
		if "text" ~= msg then
			common.fail("co_get", tostring(msg) .. " " .. tostring(head))
			return
		end

		if not common.assert_loopback_body(head, body, BODY) then
			return
		end

		common.pass()
	end)
end


return M
