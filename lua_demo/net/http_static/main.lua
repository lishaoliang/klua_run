--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   main.lua
-- @brief  lua demo 2.2 HTTP/HTTPS 静态服务器 (demores/html + lua_demo + lua_test)
-- @note   klua demo.lua 2.2 [port]; 默认 8000; 同端口 HTTP+HTTPS; 第2参 `0` 关闭 TLS
--   \n 语义 id net.http.static; `/lua_demo` `/lua_test` 源码浏览; **非** lua test
-- @history 修改历史
--  \n 2026 创建文件
--]]


local io = require("io")
local lfs = require("lfs")
local kco = require("kco")
local kenv = require("kenv")
local ksys = require("ksys")
local http_mime = require("klbcore.util.http_mime")
local pathex = require("klbcore.util.pathex")
local klbhttp = require("klbcore.klbhttp")


local M = {}

local DEFAULT_PORT = 8000
local SERVER_NAME = "lua_demo/2.2"
local KLB_SOCKET_CONNECT = 63
local KLB_NETCODE_WBUF_EMPTY = 70


local function parse_request(head)
	local line = string.match(head or "", "^([^\r\n]+)")
	if not line then
		return "", ""
	end

	local method, target = string.match(line, "^(%S+)%s+(%S+)")
	if not method then
		return "", ""
	end

	local path = string.match(target, "^([^?]*)") or "/"
	return string.upper(method), path
end


local function pack_head(status, mime, size)
	local t = {}

	table.insert(t, status .. "\r\n")
	table.insert(t, string.format("Server: %s\r\n", SERVER_NAME))
	table.insert(t, "Connection: close\r\n")
	table.insert(t, string.format("Content-Type: %s\r\n", mime))
	table.insert(t, string.format("Content-Length: %d\r\n", size))
	table.insert(t, "Cache-Control: max-age=0\r\n")
	table.insert(t, "Access-Control-Allow-Origin: *\r\n")
	table.insert(t, "\r\n")

	return table.concat(t)
end


local function recv_until_text(serve)
	while true do
		local msg, head, body = serve:co_recv()
		if "text" == msg then
			return "text", head or "", body or ""
		elseif "exit" == msg then
			return "exit", "", ""
		elseif "error" == msg then
			local code = tonumber(head) or 1
			if KLB_SOCKET_CONNECT ~= code and KLB_NETCODE_WBUF_EMPTY ~= code then
				return "error", code, ""
			end
		else
			return "error", 1, ""
		end
	end
end


local function wait_wbuf_empty(serve)
	while true do
		local msg, head = serve:co_recv()
		if "error" == msg then
			local code = tonumber(head) or 0
			if KLB_NETCODE_WBUF_EMPTY == code then
				return
			end
			if KLB_SOCKET_CONNECT ~= code then
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


local function send_and_close(serve, head, body)
	local rc = serve:send(head, body)
	if 0 == rc then
		wait_wbuf_empty(serve)
	end
	serve:disconnect()
end


local function read_file(path)
	local f = io.open(path, "rb")
	if not f then
		return nil
	end

	local body = f:read("*a")
	f:close()
	return body
end


local function html_escape(s)
	s = string.gsub(s, "&", "&amp;")
	s = string.gsub(s, "<", "&lt;")
	s = string.gsub(s, ">", "&gt;")
	s = string.gsub(s, '"', "&quot;")
	return s
end


local function parent_url(url_path)
	local parent = string.match(url_path, "^(.+)/[^/]+$")
	if not parent or "" == parent then
		return "/"
	end

	return parent
end


local function child_url(url_path, name)
	if "/" == url_path then
		return "/" .. name
	end

	return url_path .. "/" .. name
end


local function make_listing(url_path, dir_path)
	local names = {}

	for name in lfs.dir(dir_path) do
		if "." ~= name and ".." ~= name and ".svn" ~= name then
			names[#names + 1] = name
		end
	end

	table.sort(names)

	local t = {}
	t[#t + 1] = "<!DOCTYPE html>\n<html><head><meta charset=\"utf-8\"><title>Index of "
	t[#t + 1] = html_escape(url_path)
	t[#t + 1] = "</title></head><body><h1>Index of "
	t[#t + 1] = html_escape(url_path)
	t[#t + 1] = "</h1><ul>"

	if "/" ~= url_path then
		t[#t + 1] = string.format("<li><a href=\"%s\">../</a></li>", html_escape(parent_url(url_path)))
	end

	for i = 1, #names do
		local name = names[i]
		local mode = lfs.attributes(dir_path .. "/" .. name, "mode")
		local href = child_url(url_path, name)
		local label = name
		if "directory" == mode then
			href = href .. "/"
			label = name .. "/"
		end
		t[#t + 1] = string.format("<li><a href=\"%s\">%s</a></li>", html_escape(href), html_escape(label))
	end

	t[#t + 1] = "</ul></body></html>"
	return table.concat(t)
end


local BODY_404 = [[<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>404</title>
</head>
<body>
<h1>Not Found</h1>
<p>404</p>
</body>
</html>
]]


local function send_status(serve, status_line, mime, body)
	send_and_close(serve, pack_head(status_line, mime, #body), body)
end


local BROWSE_TEXT = {
	lua = true,
	md = true,
	txt = true,
	c = true,
	h = true,
	cpp = true,
	hpp = true,
	json = true,
	mdc = true,
}


local function browse_mime(filename)
	local ext = string.match(filename, "[^.]*$") or ""
	ext = string.lower(ext)
	if BROWSE_TEXT[ext] then
		return "text/plain; charset=utf-8"
	end

	return http_mime(filename)
end


local function resolve_mount(url_rel, mounts)
	for i = 1, #mounts do
		local prefix = mounts[i].prefix
		if "/" ~= prefix then
			if url_rel == prefix then
				return mounts[i].root, "/", prefix
			end

			local head = prefix .. "/"
			if head == string.sub(url_rel, 1, #head) then
				return mounts[i].root, string.sub(url_rel, #prefix + 1), prefix
			end
		end
	end

	for i = 1, #mounts do
		if "/" == mounts[i].prefix then
			return mounts[i].root, url_rel, ""
		end
	end

	return nil, nil, nil
end


local function mount_url(prefix, fs_rel)
	if "" == prefix then
		return fs_rel
	end

	if "/" == fs_rel then
		return prefix
	end

	return prefix .. fs_rel
end


local function handle_get(serve, root, rel, url_path, tag)
	tag = tag or "http"
	url_path = url_path or rel

	local real
	if "/" == rel then
		real = root
	else
		real = root .. rel
	end

	local mode = lfs.attributes(real, "mode")
	if "directory" == mode then
		local index_path = real .. "/index.html"
		if "file" == lfs.attributes(index_path, "mode") then
			local body = read_file(index_path)
			if body then
				print("GET", tag, url_path, "index.html")
				send_status(serve, "HTTP/1.1 200 OK", http_mime("index.html"), body)
				return
			end
		end

		print("GET", tag, url_path, "listing")
		local body = make_listing(url_path, real)
		send_status(serve, "HTTP/1.1 200 OK", "text/html", body)
		return
	end

	if "file" ~= mode then
		print("GET", tag, url_path, "404")
		send_status(serve, "HTTP/1.1 404 Not Found", "text/html", BODY_404)
		return
	end

	local body = read_file(real)
	if not body then
		print("GET", tag, url_path, "404")
		send_status(serve, "HTTP/1.1 404 Not Found", "text/html", BODY_404)
		return
	end

	local filename = string.match(rel, "[^/]*$") or rel
	print("GET", tag, url_path)
	send_status(serve, "HTTP/1.1 200 OK", browse_mime(filename), body)
end


local function serve_conn(serve, mounts, tag)
	local msg, head = recv_until_text(serve)
	if "text" ~= msg then
		serve:disconnect()
		return
	end

	local method, raw_path = parse_request(head)
	local url_rel = pathex.filter_path(raw_path)
	if not url_rel then
		send_status(serve, "HTTP/1.1 400 Bad Request", "text/plain", "bad path")
		return
	end

	if "GET" ~= method then
		send_status(serve, "HTTP/1.1 405 Method Not Allowed", "text/plain", "Method Not Allowed")
		return
	end

	local root, fs_rel, prefix = resolve_mount(url_rel, mounts)
	if not root then
		send_status(serve, "HTTP/1.1 404 Not Found", "text/html", BODY_404)
		return
	end

	handle_get(serve, root, fs_rel, mount_url(prefix, fs_rel), tag)
end


local function fork_accept(listener, mounts)
	kco.fork(function ()
		while true do
			local serve = listener:co_accept()
			if not serve then
				break
			end

			kco.fork(function ()
				local tag = "http"
				if serve.tls and serve:tls() then
					tag = "https"
				end
				serve_conn(serve, mounts, tag)
			end)
		end
	end)
end


local function parse_port(...)
	local args = { ... }
	local port = tonumber(args[1]) or DEFAULT_PORT
	local want_https = true

	if nil ~= args[2] then
		local flag = tonumber(args[2])
		if not flag then
			return nil, nil, "invalid https flag"
		end

		want_https = (0 ~= flag)
	end

	if port < 1 or 65535 < port then
		return nil, nil, "invalid port"
	end

	return port, want_https, nil
end


local function load_tls_pem()
	local dir = kenv.base_path() .. "demores/tls/"
	dir = string.gsub(dir, "\\", "/")

	local cert = read_file(dir .. "cert.pem")
	local key = read_file(dir .. "key.pem")
	if not cert or not key or 0 == #cert or 0 == #key then
		return nil, nil, dir
	end

	return cert, key, dir
end


local function collect_mounts()
	local base = kenv.base_path()
	base = string.gsub(base, "\\", "/")
	base = string.gsub(base, "/+$", "")

	local html = base .. "/demores/html"
	if "directory" ~= lfs.attributes(html, "mode") then
		return nil, "static root missing: " .. html
	end

	local mounts = {}
	local extras = {
		{ prefix = "/lua_demo", rel = "lua_demo" },
		{ prefix = "/lua_test", rel = "lua_test" },
	}

	for i = 1, #extras do
		local root = base .. "/" .. extras[i].rel
		if "directory" == lfs.attributes(root, "mode") then
			mounts[#mounts + 1] = {
				prefix = extras[i].prefix,
				root = root,
			}
		else
			print("mount skip (missing):", extras[i].prefix, root)
		end
	end

	mounts[#mounts + 1] = {
		prefix = "/",
		root = html,
	}

	return mounts, nil
end


local function main(...)
	local port, want_https, err = parse_port(...)
	if err then
		print(err)
		ksys.exit(1)
		return
	end

	local mounts, mount_err = collect_mounts()
	if not mounts then
		print(mount_err)
		ksys.exit(1)
		return
	end

	local cert, key, tls_dir = nil, nil, ""
	local mixed = false
	if want_https then
		cert, key, tls_dir = load_tls_pem()
		if not cert then
			print("https  skip (missing cert/key):", tls_dir)
		end
	else
		print("https  off")
	end

	local listener
	if want_https and cert then
		listener = klbhttp.listen(port, {
			tls = true,
			plain = true,
			cert = cert,
			key = key,
		})
		if listener then
			mixed = true
		else
			print("https mixed listen failed (no-ssl or bad cert):", port)
		end
	end

	if not listener then
		listener = klbhttp.listen(port)
	end

	if not listener then
		print("http listen failed:", port)
		ksys.exit(1)
		return
	end

	print("lua demo 2.2  net.http.static")
	for i = 1, #mounts do
		print("mount ", mounts[i].prefix, mounts[i].root)
	end
	print("listen ", string.format("http://127.0.0.1:%d/", port))
	if mixed then
		print("listen ", string.format("https://127.0.0.1:%d/", port))
		print("tls    ", "self-signed demo cert; browser warn expected")
	end
	print("stop   Ctrl+C")

	fork_accept(listener, mounts)
end


-- @brief 启动 HTTP/HTTPS 静态服务, 长期运行至人工停止
-- @param [in] ...[any] 第1参 端口, 默认 8000; 第2参 `0` 关闭 TLS (同端口混用)
-- @return 无
function M.run(...)
	main(...)
end


return M
