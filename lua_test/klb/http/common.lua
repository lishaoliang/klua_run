--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   http/common.lua
-- @brief  第 3 章 3.2 klbhttp 公共辅助
-- @note   约定 **klua-test-design**; khttp 失败则 skip; 环回 listen; 公网不通 skip
-- @history 修改历史
--  \n 2026 创建文件
--]]
local ksys = require("ksys")
local kco = require("kco")
local report = require("lua_test.report")


local M = {}
local g_done = false


function M.fail(tag, msg)
	if g_done then
		return
	end
	g_done = true
	report.fail(tostring(tag) .. ": " .. tostring(msg))
	ksys.exit(1)
end


function M.pass()
	if g_done then
		return
	end
	g_done = true
	report.pass()
	ksys.exit(0)
end


function M.skip(msg)
	if g_done then
		return
	end
	g_done = true
	report.skip(msg)
	ksys.exit(0)
end


function M.require_klbhttp()
	local ok_k = pcall(require, "khttp")
	if not ok_k then
		M.skip("khttp not loaded (no-http)")
		return nil
	end

	local ok, klbhttp = pcall(require, "klbcore.klbhttp")
	if not ok then
		M.skip("klbcore.klbhttp not loaded")
		return nil
	end

	return klbhttp
end


function M.pack_ok_head(body)
	body = body or ""
	local t = {}

	table.insert(t, "HTTP/1.1 200 OK\r\n")
	table.insert(t, "Content-Type: text/plain\r\n")
	table.insert(t, string.format("Content-Length: %d\r\n", #body))
	table.insert(t, "Connection: close\r\n")
	table.insert(t, "\r\n")

	return table.concat(t)
end


function M.pack_get_head(host, port, target)
	local t = {}

	table.insert(t, string.format("GET %s HTTP/1.1\r\n", target))
	table.insert(t, string.format("Host: %s:%s\r\n", host, port))
	table.insert(t, "User-Agent: KLB\r\n")
	table.insert(t, "Connection: close\r\n")
	table.insert(t, "\r\n")

	return table.concat(t)
end


function M.arm_timeout(ms)
	kco.timeout(ms or 5000, function ()
		M.fail("timeout", "klbhttp case hung")
	end)
end


function M.recv_until_text(obj)
	while true do
		local msg, head, body = obj:co_recv()
		if "text" == msg then
			return "text", head or "", body or ""
		elseif "exit" == msg then
			return "exit", "", ""
		elseif "error" == msg then
			local code = tonumber(head) or 1
			if 63 ~= code and 70 ~= code then
				return "error", code, ""
			end
		else
			return "error", 1, ""
		end
	end
end


function M.wait_wbuf_empty(obj)
	while true do
		local msg, head = obj:co_recv()
		if "error" == msg then
			local code = tonumber(head) or 0
			if 70 == code then
				return
			end
			if 63 ~= code then
				return
			end
		elseif "exit" == msg then
			return
		elseif "text" == msg then
			-- keep waiting flush
		else
			return
		end
	end
end


function M.http_status_code(head)
	return tonumber(string.match(head or "", "^HTTP/%d%.%d (%d%d%d)"))
end


function M.http_status_ok(head)
	local code = M.http_status_code(head)
	if not code then
		return false
	end

	return (200 <= code) and (code < 400)
end


-- @brief 从 head 取 Content-Length; 无则为 nil
function M.content_length(head)
	return tonumber(string.match(string.lower(head or ""), "content%-length:%s*(%d+)"))
end


-- @brief 核对 body 长度; expect_len 可选 (环回精确值)
-- @return ok[boolean], err_or_len[string|number]
function M.check_recv_size(head, body, expect_len)
	body = body or ""
	local n = #body

	if expect_len and expect_len ~= n then
		return false, "len " .. tostring(n) .. " want " .. tostring(expect_len)
	end

	local cl = M.content_length(head)
	if cl and cl ~= n then
		return false, "Content-Length " .. tostring(cl) .. " body " .. tostring(n)
	end

	return true, n
end


-- @brief 环回: body 相等且长度 / Content-Length 一致
function M.assert_loopback_body(head, body, expect)
	if expect ~= body then
		M.fail("body", tostring(body))
		return false
	end

	local ok, err = M.check_recv_size(head, body, #expect)
	if not ok then
		M.fail("size", err)
		return false
	end

	return true
end


-- @brief 公网 2xx: 有 CL 则与 #body 相等, 否则 #body >= min_len
function M.public_body_ok(head, body, body_need, min_len)
	min_len = min_len or 64
	local code = M.http_status_code(head)
	if not code or code < 200 or 300 <= code then
		return false, "status " .. tostring(code)
	end

	body = body or ""
	if body_need and not string.find(body, body_need, 1, true) then
		return false, "no echo"
	end

	local cl = M.content_length(head)
	if cl then
		if cl ~= #body then
			return false, "Content-Length " .. tostring(cl) .. " body " .. tostring(#body)
		end
	elseif #body < min_len then
		return false, "body " .. tostring(#body) .. " < " .. tostring(min_len)
	end

	return true, #body
end


-- @brief 依次请求公网 URL; 任一 2xx 且长度合格则 pass; 全失败则 skip
function M.try_public(urls, request, body_need)
	local last = ""

	for i = 1, #urls do
		local url = urls[i]
		local msg, head, body = request(url)
		if "text" == msg then
			local ok, info = M.public_body_ok(head, body, body_need)
			if ok then
				print("  public ok", url, "len", info)
				M.pass()
				return
			end

			if info and string.find(tostring(info), "Content-Length", 1, true) then
				M.fail("size", tostring(url) .. " " .. tostring(info))
				return
			end

			last = tostring(url) .. " " .. tostring(info)
		else
			last = tostring(url) .. " " .. tostring(msg) .. " " .. tostring(head)
		end

		print("  public try", last)
	end

	M.skip("public net unavailable: " .. last)
end


function M.serve_once(l, make_body)
	local serve = l:co_accept()
	if not serve then
		M.fail("accept", "nil")
		return
	end

	local msg, head, body = M.recv_until_text(serve)
	if "text" ~= msg then
		serve:disconnect()
		M.fail("serve_recv", tostring(msg) .. " " .. tostring(head))
		return
	end

	local resp_body = make_body(head or "", body or "")
	local rc = serve:send(M.pack_ok_head(resp_body), resp_body)
	if 0 ~= rc then
		serve:disconnect()
		M.fail("serve_send", tostring(rc))
		return
	end

	M.wait_wbuf_empty(serve)
	kco.co_sleep(50)
	serve:disconnect()
end


return M
