--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   main.lua
-- @brief  lua demo 2.3 klbweb HTTP/HTTPS 静态服务器 (demores/html + lua_demo + lua_test)
-- @note   klua demo.lua 2.3 [port]; 默认 8000; 同端口 HTTP+HTTPS; 第2参 `0` 关闭 TLS
--   \n 语义 id net.web.static; 能力对齐 2.2; 走 klbweb; **非** lua test
-- @history 修改历史
--  \n 2026 创建文件
--]]


local lfs = require("lfs")
local kenv = require("kenv")
local ksys = require("ksys")
local klbweb = require("klbcore.klbweb")


local M = {}

local DEFAULT_PORT = 8000


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

	local tls_dir = kenv.base_path() .. "demores/tls/"
	tls_dir = string.gsub(tls_dir, "\\", "/")
	local cert = tls_dir .. "cert.pem"
	local key = tls_dir .. "key.pem"
	local mixed = false
	local listen = {
		port = port,
	}

	if not want_https then
		print("https  off")
	elseif "file" == lfs.attributes(cert, "mode") and "file" == lfs.attributes(key, "mode") then
		listen.tls = true
		listen.plain = true
		listen.cert = cert
		listen.key = key
		mixed = true
	else
		print("https skip (missing cert/key):", tls_dir)
	end

	if not klbweb.setup({
		server = "lua_demo/2.3",
		listen = listen,
	}) then
		print("klbweb setup failed")
		ksys.exit(1)
		return
	end

	for i = 1, #mounts do
		local listing = "/" ~= mounts[i].prefix
		klbweb.static(mounts[i].prefix, mounts[i].root, { listing = listing })
	end

	print("lua demo 2.3  net.web.static")
	for i = 1, #mounts do
		print("mount ", mounts[i].prefix, mounts[i].root)
	end
	print("listen ", string.format("http://127.0.0.1:%d/", port))

	if not klbweb.serve() then
		if mixed then
			print("https mixed listen failed (no-ssl or bad cert), retry http:", port)
			klbweb.stop()
			if not klbweb.setup({
				server = "lua_demo/2.3",
				listen = { port = port },
			}) then
				print("klbweb setup failed")
				ksys.exit(1)
				return
			end

			if not klbweb.serve() then
				print("http listen failed:", port)
				ksys.exit(1)
				return
			end

			mixed = false
		else
			print("http listen failed:", port)
			ksys.exit(1)
			return
		end
	end

	if mixed then
		print("listen ", string.format("https://127.0.0.1:%d/", port))
		print("tls    ", "self-signed demo cert; browser warn expected")
	end
	print("stop   Ctrl+C")
end


-- @brief 启动 klbweb HTTP/HTTPS 静态服务, 长期运行至人工停止
-- @param [in] ...[any] 第1参 端口, 默认 8000; 第2参 `0` 关闭 TLS (同端口混用)
-- @return 无
function M.run(...)
	main(...)
end


return M
