AddCSLuaFile()

local meta_color = FindMetaTable("Color")

local g_angle = Angle
local g_color = Color
local g_entity = Entity
local g_tonumber = tonumber
local g_typeid = TypeID
local g_vector = Vector

local m_abs = math.abs
local m_round = math.Round

local s_explode = string.Explode
local s_find = string.find
local s_format = string.format
local s_gsub = string.gsub
local s_sub = string.sub

local t_concat = table.concat
local t_insert = table.insert

local precision = 3

local pointers = {
	[TYPE_TABLE] = true,
	[TYPE_STRING] = true
}

local encoders, decoders
local encode, decode, decode_raw

encoders = {
	[TYPE_NIL] = function() return "?" end,
	[TYPE_BOOL] = function(val)
		return val and "t" or "f"
	end,
	[TYPE_TABLE] = function(tab)
		if getmetatable(tab) == meta_color then
			return encoders[TYPE_COLOR](tab)
		end

		local ret = {"{"}

		local cache = {}
		local cacheIndex = 1

		local expected = 1
		local broken = false

		local function handleCache(val)
			local encoded = encode(val)

			if pointers[g_typeid(val)] then
				local cached = cache[encoded]

				if cached then
					encoded = "(" .. cached .. ";"
				else
					cache[encoded] = cacheIndex
					cacheIndex = cacheIndex + 1
				end
			end

			return encoded
		end

		for k, v in pairs(tab) do
			if not broken then
				if k == expected then
					expected = expected + 1

					t_insert(ret, handleCache(v))
				else
					broken = true

					t_insert(ret, "$")
					t_insert(ret, handleCache(k))
					t_insert(ret, handleCache(v))
				end
			else
				t_insert(ret, handleCache(k))
				t_insert(ret, handleCache(v))
			end
		end

		t_insert(ret, "}")

		return t_concat(ret)
	end,
	[TYPE_STRING] = function(str)
		local escaped, count = s_gsub(str, ";", "\\;")

		if count == 0 then
			return "'" .. escaped
		else
			return "\"" .. escaped .. "\""
		end
	end,
	[TYPE_COLOR] = function(col)
		return s_format("c%i,%i,%i,%i", col.r, col.g, col.b, col.a)
	end,
	[TYPE_VECTOR] = function(vec)
		return s_format("v%s,%s,%s", m_round(vec.x, precision), m_round(vec.y, precision), m_round(vec.z, precision))
	end,
	[TYPE_ANGLE] = function(ang)
		return s_format("a%s,%s,%s", m_round(ang.p % 360, precision), m_round(ang.y % 360, precision), m_round(ang.r % 360, precision))
	end,
	[TYPE_NUMBER] = function(num)
		num = m_round(num, precision)

		if num == 0 then
			return "0"
		elseif num % 1 != 0 then
			return "n" .. num
		else
			return s_format("%s%x", num > 0 and "+" or "-", m_abs(num))
		end
	end,
	[TYPE_ENTITY] = function(ent)
		return s_format("e%s", IsValid(ent) and ent:EntIndex() or "#")
	end
}

decoders = {
	["?"] = function() return 1, nil end, -- Nil
	["t"] = function() return 1, true end, -- True
	["f"] = function() return 1, false end, -- False
	["("] = function(str, cache) -- Table pointer
		local finish = s_find(str, ";")

		return finish, cache[tonumber(s_sub(str, 1, finish - 1))]
	end,
	["{"] = function(str) -- Table
		local strIndex = 1
		local ret = {}

		local cache = {}

		local tabIndex = 1
		local broken = false

		local function handleCache(val) -- Builds the cache that pointers refer back to
			local index, decoded = decode_raw(val, cache)

			if pointers[g_typeid(decoded)] then
				t_insert(cache, decoded)
			end

			return index, decoded
		end

		while true do
			local char = str[strIndex]

			if char == "}" then
				break
			end

			if char == "$" then
				broken = true
				strIndex = strIndex + 1

				continue
			end

			if broken then
				local keyIndex, key = handleCache(s_sub(str, strIndex))
				local valIndex, val = handleCache(s_sub(str, strIndex + keyIndex + 1))

				ret[key] = val

				strIndex = strIndex + keyIndex + valIndex + 2
			else
				local index, val = handleCache(s_sub(str, strIndex))

				ret[tabIndex] = val

				tabIndex = tabIndex + 1
				strIndex = strIndex + index + 1
			end
		end

		return strIndex + 1, ret
	end,
	["'"] = function(str) -- Unescaped string
		local finish = s_find(str, ";")

		return finish, s_sub(str, 1, finish - 1)
	end,
	["\""] = function(str) -- Escaped string
		local finish = s_find(str, "\";")

		return finish + 1, string.gsub(s_sub(str, 1, finish - 1), "\\;", ";")
	end,
	["c"] = function(str) -- Color
		local finish = s_find(str, ";")
		local args = s_explode(",", s_sub(str, 1, finish - 1))

		return finish, g_color(args[1], args[2], args[3], args[4])
	end,
	["v"] = function(str) -- Vector
		local finish = s_find(str, ";")
		local args = s_explode(",", s_sub(str, 1, finish - 1))

		return finish, g_vector(args[1], args[2], args[3])
	end,
	["a"] = function(str) -- Angle
		local finish = s_find(str, ";")
		local args = s_explode(",", s_sub(str, 1, finish - 1))

		return finish, g_angle(args[1], args[2], args[3])
	end,
	["0"] = function(str) -- 0
		return 1, 0
	end,
	["+"] = function(str) -- Positive int
		local finish = s_find(str, ";")

		return finish, g_tonumber(s_sub(str, 1, finish - 1), 16)
	end,
	["-"] = function(str) -- Negative int
		local finish = s_find(str, ";")

		return finish, -g_tonumber(s_sub(str, 1, finish - 1), 16)
	end,
	["n"] = function(str) -- Float
		local finish = s_find(str, ";")

		return finish, g_tonumber(s_sub(str, 1, finish - 1))
	end,
	["e"] = function(str) -- Entity
		if str[1] == "#" then
			return 2, NULL
		end

		local finish = s_find(str, ";")

		return finish, g_entity(s_sub(str, 1, finish - 1))
	end
}

function encode(data)
	local callback = encoders[g_typeid(data)] or encoders[TYPE_NIL]

	return callback(data) .. ";"
end

function decode_raw(str, cache)
	local identifier = s_sub(str, 1, 1)
	local callback = decoders[identifier]

	if not callback then
		error("No decode type for " .. identifier)
	end

	return callback(s_sub(str, 2), cache)
end

function decode(str)
	if #str == 0 then
		return
	end

	local _, res = decode_raw(str)

	return res
end

cmf.Encode = function(_, data) return encode(data) end
cmf.Decode = function(_, str) return decode(str) end
