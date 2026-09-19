--[[
-- Copyright (c) 2026, GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007
-- @file   main.lua
-- @brief  lua demo 2.3 klbweb HTTP/HTTPS 静态服务器 (demores/html + lua_demo + lua_test)
-- @note   klua demo.lua 2.3 [http_port] [https_port]; 默认 8000/8443; https_port=0 关闭 TLS
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
local DEFAULT_HTTPS_PORT = 8443


local function parse_ports(...)
	local args = { ... }
	local http_port = tonumber(args[1]) or DEFAULT_PORT
	local https_port = DEFAULT_HTTPS_PORT

	if nil ~= args[2] then
		https_port = tonumber(args[2])
		if not https_port then
			return nil, nil, "invalid https port"
		end
	end

	if http_port < 1 or 65535 < http_port then
		return nil, nil, "invalid http port"
	end

	if 0 ~= https_port and (https_port < 1 or 65535 < https_port) then
		return nil, nil, "invalid https port"
	end

	if 0 ~= https_port and http_port == https_port then
		return nil, nil, "http/https port conflict"
	end

	return http_port, https_port, nil
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
	local http_port, https_port, err = parse_ports(...)
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

	if not klbweb.setup({
		server = "lua_demo/2.3",
	}) then
		print("klbweb setup failed")
		ksys.exit(1)
		return
	end

	for i = 1, #mounts do
		local listing = "/" ~= mounts[i].prefix
		klbweb.static(mounts[i].prefix, mounts[i].root, { listing = listing })
	end

	if not klbweb.listen(http_port) then
		print("http listen failed:", http_port)
		ksys.exit(1)
		return
	end

	print("lua demo 2.3  net.web.static")
	for i = 1, #mounts do
		print("mount ", mounts[i].prefix, mounts[i].root)
	end
	print("listen ", string.format("http://127.0.0.1:%d/", http_port))

	if 0 == https_port then
		print("https  off")
	else
		local tls_dir = kenv.base_path() .. "demores/tls/"
		tls_dir = string.gsub(tls_dir, "\\", "/")

		if not klbweb.listen(https_port, {
			tls = true,
			cert = tls_dir .. "cert.pem",
			key = tls_dir .. "key.pem",
		}) then
			print("https skip (missing cert/key or no-ssl):", tls_dir)
		else
			print("listen ", string.format("https://127.0.0.1:%d/", https_port))
			print("tls    ", "self-signed demo cert; browser warn expected")
		end
	end

	klbweb.fork_accept()
	print("stop   Ctrl+C")
end


-- @brief 启动 klbweb HTTP/HTTPS 静态服务, 长期运行至人工停止
-- @param [in] ...[any] 第1参 HTTP 端口, 默认 8000; 第2参 HTTPS 端口, 默认 8443, 0 关闭
-- @return 无
function M.run(...)
	main(...)
end


return M
