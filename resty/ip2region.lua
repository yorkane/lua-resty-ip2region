local ipr = require('Ip2region')
local bit = require('bit')
local band, bor, rshift = bit.band, bit.bor, bit.rshift
local ipairs, tonumber, tostring, type, ssub, abs, byte, char = ipairs, tonumber, tostring, type, string.sub, math.abs, string.byte, string.char

local inst
---@class resty.ip2region
local _M = { instance = inst }

---@class resty.ip2region.data
---@field city_id number
---@field region string

---init
---@param db_path string
---@return lib.ip2region
function _M.init(db_path, region_csv_path)
	local err
	if not inst then
		inst, err = ipr.new(db_path or '/usr/local/openresty/site/ip2region.db')
		inst:memorySearch('1.1.1.1') -- search instantly to prevent errors in next usage
	end
	return inst or err
end

local n224 = 2 ^ 24
local n216 = 2 ^ 16
local n28 = 2 ^ 8

local function numip_long(a1, a2, a3, a4)
	local ext
	if a1 > 127 then
		ext = a1 - 127
		a1 = 127
	end
	local l1 = bit.lshift(a1, 24)
	local l2 = bit.lshift(a2, 16)
	local l3 = bit.lshift(a3, 8)
	local l4 = bit.lshift(a4, 0)
	local long = bit.bor(l1, l2);
	long = bit.bor(long, l3);
	long = bit.bor(long, l4);
	if ext then
		long = long + (ext * n224)
	end
	return long
end

function _M.ip_long(ip)
	return inst:ip2long(ip)
end

---long_ip
---@param long number
---@param only_digits boolean
---@return string|number
function _M.long_ip(long, only_digits)
	local a1 = band(rshift(long, 24), 0xFF)
	if a1 < 0 then

	end
	local a2 = band(rshift(long, 16), 0xFF)
	local a3 = band(rshift(long, 8), 0xFF)
	local a4 = band(long, 0xFF)
	if only_digits then
		return a1, a2, a3, a4
	end
	return a1 .. '.' .. a2 .. '.' .. a3 .. '.' .. a4
end

---ip_byte convert ip address into 4bytes string
---@param ip string @like "192.168.1.1" or binary ip bytes: ngx.var.binary_remote_addr
---@return string
function _M.ip_byte(ip)
	if not ip then
		ip = ngx.var.binary_remote_addr
	end
	if #ip == 4 then
		return ip
	end
	--local arr = table.array(4)
	local a1, a2, a3, a4
	local ini = 1
	local inx = 0
	for i = 1, #ip do
		if byte(ip, i, i) == 46 then
			inx = inx + 1
			if inx == 1 then
				a1 = tonumber(ssub(ip, ini, i - 1))
			elseif inx == 2 then
				a2 = tonumber(ssub(ip, ini, i - 1))
			elseif inx == 3 then
				a3 = tonumber(ssub(ip, ini, i - 1))
			end
			ini = i + 1;
		end
	end
	if not a3 then
		return nil
	end
	a4 = tonumber(ssub(ip, ini, #ip))
	return char(a1, a2, a3, a4)
end

---byte_ip
---@param bytes string @4 chars
---@return string @ xxx.xxx.xxx.xxx format string
function _M.byte_ip(bytes)
	local a1, a2, a3, a4 = byte(bytes, 1, 4)
	return a1 .. '.' .. a2 .. '.' .. a3 .. '.' .. a4
end

---byte_long
---@param bytes string @4chars
---@return number @ long number as ip
function _M.byte_long(bytes)
	return numip_long(byte(bytes, 1, 4))
end

---@class resty.ip2region.data
---@field city_id number
---@field region string

---search
---@param ip string
---@return resty.ip2region.data
function _M.search(ip)
	if not inst then
		_M.init()
	end
	return inst:memorySearch(ip)
end

---search_long find ip addr in long number form
---@param long_ip number @ 1084752130 = 192.168.1.2
---@return resty.ip2region.data
function _M.search_long(long_ip)
	if not inst then
		_M.init()
	end
	return inst:searchLong(long_ip)
end

---search_bytes
---@param bytes string
---@return resty.ip2region.data
function _M.search_bytes(bytes)
	if not inst then
		_M.init()
	end
	return inst:searchLong(_M.byte_long(bytes))
end

---btree_search  search in file stream
---@param ip string
---@return resty.ip2region.data
function _M.btree_search(ip)
	if not inst then
		_M.init()
	end
	return inst:btreeSearch(ip)
end

---close dispose the object to save memory
function _M.close()
	if inst then
		inst:close()
	end
end

return _M