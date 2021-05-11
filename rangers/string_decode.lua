--
-- String decoder functions
--

local stringdecode = {}

-- From http://lua-users.org/wiki/LuaUnicode
local function utf8_to_32(utf8str)
    assert(type(utf8str) == "string")
    local res, seq, val = {}, 0, nil

    for i = 1, #utf8str do
        local c = string.byte(utf8str, i)
        if seq == 0 then
            table.insert(res, val)
            seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                  c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
                error("Invalid UTF-8 character sequence")
            val = bit32.band(c, 2^(8-seq) - 1)
        else
            val = bit32.bor(bit32.lshift(val, 6), bit32.band(c, 0x3F))
        end

        seq = seq - 1
    end

    table.insert(res, val)

    return res
end

-- Supposedly these funcs are by Gl00my
function u16toutf8(unicode_string, len)
	local result = ''
	local w,x,y,z = 0,0,0,0
	local i
	local function modulo(a, b)
		return a - math.floor(a/b) * b
	end
	for i = 1, len do
		v1 = string.byte(unicode_string, (i - 1) * 2 + 1)
		v2 = string.byte(unicode_string, (i - 1) * 2 + 2)
		v = v1 + v2 * 0x100;

		if v ~= 0 and v ~= nil then
			if v <= 0x7F then -- same as ASCII
				result = result .. string.char(v)
			elseif v >= 0x80 and v <= 0x7FF then -- 2 bytes
				y = math.floor(modulo(v, 0x000800) / 64)
				z = modulo(v, 0x000040)
				result = result .. string.char(0xC0 + y, 0x80 + z)
			elseif (v >= 0x800 and v <= 0xD7FF) or (v >= 0xE000 and v <= 0xFFFF) then -- 3 bytes
				x = math.floor(modulo(v, 0x010000) / 4096)
				y = math.floor(modulo(v, 0x001000) / 64)
				z = modulo(v, 0x000040)
				result = result .. string.char(0xE0 + x, 0x80 + y, 0x80 + z)
			elseif (v >= 0x10000 and v <= 0x10FFFF) then -- 4 bytes
				w = math.floor(modulo(v, 0x200000) / 262144)
				x = math.floor(modulo(v, 0x040000) / 4096)
				y = math.floor(modulo(v, 0x001000) / 64)
				z = modulo(v, 0x000040)
				result = result .. string.char(0xF0 + w, 0x80 + x, 0x80 + y, 0x80 + z)
			end
		end
	end
	return result
end

function readu16(f)
	local l = read4(f)
	if l == 0 then return end
	local data = f:read(l * 2)
--	return cd:iconv(data):
	return ;
end

function stringdecode.decode(str, encoding)
    if not str then return "" end
    local enc = encoding and encoding:lower() or "ascii"

    if enc == "ascii" then
        return str
    elseif enc == "utf-8" then
        local code_points = utf8_to_32(str)

        return utf8.char(table.unpack(code_points))
    elseif enc == "utf-16le" then
        -- print("len is:",string.len(str))
        return u16toutf8(str, string.len(str)//2)
    else
        error("Encoding " .. encoding .. " not supported")
    end
end

return stringdecode
