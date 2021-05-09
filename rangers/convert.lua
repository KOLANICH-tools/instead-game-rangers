--#!/usr/bin/lua

deterministicTimestamp = 1359108621

function u16toutf8(unicode_string, len)
	local result = ''
	local w,x,y,z = 0,0,0,0
	local i
	local function modulo(a, b)
		return a - math.floor(a/b) * b
	end
	for i = 1, len do
		v = string.byte(unicode_string, (i - 1) * 2 + 1) + 
			string.byte(unicode_string, (i - 1) * 2 + 2) * 0x100; 

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

function parse_start(s)
	if not s then return '' end
	return "expr '"..s.."'"
end

parse_expr = function(s)
	if not s then return '' end
	return "expr '"..s.."'"
end

readd = function(f)
  local x = f:read(8)
  local sign = 1
  local mantissa = string.byte(x, 7) % 16
  for i = 6, 1, -1 do mantissa = mantissa * 256 + string.byte(x, i) end
  if string.byte(x, 8) > 127 then sign = -1 end
  local exponent = (string.byte(x, 8) % 128) * 16 +
                   math.floor(string.byte(x, 7) / 16)
  if exponent == 0 then return 0 end
  mantissa = (math.ldexp(mantissa, -52) + 1) * sign
  return math.ldexp(mantissa, exponent - 1023)
end

quest = { parameters = { }, locations = {} }

function skip(f, l)
	f:seek("cur", l)
end
local systems  = { {"Вега 7", "Ракксла"},
					{"Коззи", "Тесла"},
					{"Инумбра", "Куба"}, 
					{"Икси", "Иксурион"}, 
					{"Инстед", "Рейдира"}, 
					{"Урка", "Заксон"}, 
					{"Кайлет", "Куспи"}, 
					{"Далекая", "Цебетелла"}, 
					{"Изора", "Рейн"}, 
					{"Ксенон", "Квадир"},
					{"Красная", "Плюк"},
					{"Кинза", "Хануд"},
					{"Эл", "Узм"},
					{"Пирра", "Тентура"},
					{"Рилот", "Татуин"},
					 };

function dump(fname)
	local k,v
	local file
	local print = print
	if fname then
		file = io.open(fname, "w")
		if file then
			print = function(s)
				file:write(s)
				file:write("\n")
			end
		end
	end

	print "require 'rangers'"
	local xx = math.random(#systems)
	if quest.race == 1 then
		print [[Ranger="Урк Ужасный"]]
		print [[Player="малок"]]
		print [[FromPlanet="Квагга"]]
		print [[FromStar="Глобза"]]
	elseif quest.race == 2 then
		print [[Ranger="Зумакка"]]
		print [[Player="пеленг"]]
		print [[FromPlanet="Хулгакка"]]
		print [[FromStar="Пиллазон"]]
	elseif quest.race == 8 then
		print [[Ranger="Фьюб"]]
		print [[Player="фэянин"]]
		print [[FromPlanet="Химоза"]]
		print [[FromStar="Тиа"]]
	elseif quest.race == 10 then
		print [[Ranger="Горк"]]
		print [[Player="гаалец"]]
		print [[FromPlanet="Шена"]]
		print [[FromStar="Го"]]
	else
		print [[Ranger="Макс"]]
		print [[Player="землянин"]]
		print [[FromPlanet="Земля"]]
		print [[FromStar="Солнце"]]
	end
	print ([[ToStar="]]..systems[xx][1]..[["]])
	print ([[ToPlanet="]]..systems[xx][2]..[["]])
	print ([[Money="]]..tostring(math.random(20)*250)..[["]])
	print ([[Day="]]..tostring(math.random(7) + 5)..[["]])
	local tm
	tm = deterministicTimestamp
	local tt = os.date("*t", tm)
	tt.year = 2011
	tm = os.time(tt)
	print ("global { CurTime = "..tostring(tm).." };");
	print ([[Date="]]..os.date ("%d-%m-%Y", tm):gsub("2011", "3011")..[["]])
	if quest.dsc then
		print ("main.desc="..string.format("%q", quest.dsc))
	end
	if quest.happy then
		print ("happyend.desc = "..string.format("%q", quest.happy));
	end
	for k,v in ipairs(quest.parameters) do
		if v.active then
			print("p"..tostring(k).." = param {");
			print("\tnam = "..string.format("%q", tostring(v.name))..";");
			print("\tmin = "..tostring(v.min)..";");
			print("\tmax = "..tostring(v.max)..";");
			print("\tstart = "..tostring(v.start)..";");
			if v.fail or v.dead  then
				print("\tfailed = true;");
			end
			if v.success then
				print("\tsuccess = true;");
			end
			if v.ifzero then
				print("\tshowIfZero = true;");
			end
			if v.critical then
				print("\tcritical = '"..v.critical.."';");
				if not v.dsc then -- BUG???
					v.dsc = '';
				end
				print("\tdesc = "..string.format("%q", v.dsc)..";");
			end
			if #v.ranges > 0 then
				print("\tranges = {");
				local kk,vv
				for kk,vv in ipairs(v.ranges) do
					if vv.title then
						print("\t\t{ from = "..tostring(vv.from).."; to = "..tostring(vv.to).."; title = "..string.format("%q", vv.title).." };");
					end
				end
				print("\t};");
			end
			print("}");
--			print(v.min, v.max, v.name, v.dsc);
		end
	end
	for k,v in pairs(quest.locations) do
		print("l"..k.." = loc {");
		local kk,vv
		if v.start then
			print("\tstart = true;");
		end
		if v.success then
			print("\tsuccess = true;");
		end
		if v.failed then
			print("\tfailed = true;");
		end
		if v.empty then
			print("\tempty = true;");
		end
		if v.day then
			print("\tday = true;");
		end
		if v.dscsel and #v.descriptions > 0 then
			local c
			if not v.dscselexpr then
				c = "randomdesc("..tostring(#v.descriptions)..")";
			else
				c = parse_expr(v.dscselexpr)
			end
			print("\tdscsel = "..string.format("%q", c)..";");
		end
		for kk,vv in ipairs(v.descriptions) do
			local n = "desc";
			if kk > 1 then
				n = n..tostring(kk)
			end
			print("\t"..n.." = "..string.format("%q", vv)..";");
		end
		if #v.parameters > 0 then
			local t = ""
			for kk,vv in ipairs(v.parameters) do
				if vv.show ~= 0 then
					t = t.."p"..tostring(vv.id)..":visible("..tostring(vv.show == 1).."); "
				end
				if vv.expr then
--					t = t..parse_expr(vv.eval);
					t = t.."p"..tostring(vv.id)..":equal("..parse_expr(vv.eval)..");";
				else
					local c = "units";
					if vv.percent then
						c = "percent";
					elseif vv.equal then
						c = "equal"
					end
					if vv.add ~= 0 or vv.equal then
						t = t.."p"..tostring(vv.id)..":"..c.."("..tostring(vv.add)..");";
					end
				end
			end
			if t ~= "" then
				t = "\tcode = "..string.format("%q", t)..";";
				print(t);
			end
		end
		if #v.pathes > 0 then
			print("\tpathes = {");
			for kk,vv in ipairs(v.pathes) do
				t = "\t\t{\n";
				if vv.pri ~= 1 then
					t = t.."\t\t\tpri = "..tostring(vv.pri)..",\n";
				end
				if vv.count ~= 0 then
					t = t.."\t\t\tcount = "..tostring(vv.count)..",\n";
				end
				if vv.day then
					t = t.."\t\t\tday = true,\n";
				end
				if vv.visible then
					t = t.."\t\t\talwaysShow = true,\n";
				end
				if vv.sort ~= 5 then
					t = t.."\t\t\tsort = "..tostring(vv.sort)..",\n";
				end
				t = t.."\t\t\tto = 'l"..tostring(vv.loc).."',\n";
				if vv.dsc then
					t = t.."\t\t\tdesc = "..string.format("%q", vv.dsc)..",\n";
				end
				if vv.title then
					t = t.."\t\t\ttitle = "..string.format("%q", vv.title)..",\n";
				end
				local parcond = ''
				if #vv.parameters > 0 then
					local code = "";
					for kkk,vvv in ipairs(vv.parameters) do
						local pname = "p"..tostring(vvv.id)
						if vvv.customDesc then
							code = code..pname..":customDesc("..string.format("%q",vvv.customDesc)..");";
						end
						if vvv.show ~= 0 then
							code = code..pname..":visible("..tostring(vvv.show == 1)..");";
						end
						if vvv.r1 > quest.parameters[vvv.id].min or
							vvv.r2 < quest.parameters[vvv.id].max then
							if parcond ~= '' then
								parcond = parcond.." and ";
							end
							parcond = parcond..pname..":range("..tostring(vvv.r1)..", "..tostring(vvv.r2)..")";
						end
						if #vvv.numbers > 0 then
							if parcond ~= '' then
								parcond = parcond.." and ";
							end
							if vvv.inclusive then
								parcond = parcond..pname..":inval(";
							else
								parcond = parcond.."not "..pname..":inval(";
							end
							local z,x
							for z,x in ipairs(vvv.numbers) do
								parcond = parcond..tostring(x)
								if z ~= #vvv.numbers then
									parcond = parcond..", "
								end
							end
							parcond = parcond..")";
						end

						if #vvv.mods > 0 then
							if parcond ~= '' then
								parcond = parcond.." and ";
							end
							if vvv.divide then
								parcond = parcond..pname..":mod0(";
							else
								parcond = parcond.."not "..pname..":mod0(";
							end
							local z,x
							for z,x in ipairs(vvv.mods) do
								parcond = parcond..tostring(x)
								if z ~= #vvv.mods then
									parcond = parcond..", "
								end
							end
							parcond = parcond..")";
						end

						if vvv.expr then
							code = code..pname..":equal("..parse_expr(vvv.eval)..");";
						else
							local c = "units";
							if vvv.percent then
								c = "percent";
							elseif vvv.equal then
								c = "equal"
							end
							if vvv.add ~= 0 or vvv.equal then
								code = code..pname..":"..c.."("..tostring(vvv.add)..");";
							end
						end
					end
					if code ~= "" then
						t = t.."\t\t\tcode = "..string.format("%q", code)..",\n";
					end
				end
				if vv.cond then
					if parcond ~= '' then
						parcond = parse_expr(vv.cond).." ~= 0 and "..parcond;
					else
						parcond = parse_expr(vv.cond).." ~= 0";
					end
				end
				if parcond ~= '' then
					t = t.."\t\t\tcond = "..string.format("%q", parcond)..",\n";
				end
				t = t.."\t\t},\n"
				print(t)
			end
			print("\t}");
		end
		print("}");
	end
	if file then file:close() end
end
--cd = iconv.open("UTF-8", "UNICODELITTLE");
function readu16(f)
	local l = read4(f)
	if l == 0 then return end
	local data = f:read(l * 2)
--	return cd:iconv(data):
	return u16toutf8(data, l):gsub("%^", "\\^"):gsub("\n","^"):gsub("\r",""):gsub("{([^}]+)}","$|%1|");
end
function read1(f)
	local data = f:read(1)
	return string.byte(data,1)
end

function read4(f)
	local data = f:read(4)
	local i = string.byte(data,1) + string.byte(data,2) * 0x100 + string.byte(data,3) * 0x10000 + string.byte(data,4) * 0x1000000
	if i > 0x7fffffff then
		return i - 0xffffffff - 1
	end
	return i
end

function convert(fname, out)
	math.randomseed(deterministicTimestamp)
	math.random(1); math.random(2); math.random(3); -- Lua bug?

	local f = io.open(fname, "rb");
	if not f then
		error "can't open file"
	end
	local sign = read4(f)
	if sign == 0x423a35d4 then -- from Erendir
		pnr = 96
	elseif sign == 0x423a35d3 then
		pnr = 48
	elseif sign == 0x423a35d2 then
		pnr = 24
	else
		error "wrong signature"
	end
	read4(f);
	quest.race = read1(f, 1);
	skip(f, 57 - 4 - 8 - 4 - 1);
	quest.pathcount = read4(f)
	quest.difficult = read4(f)
	for p = 1, pnr do
		local par = {}
		par.min = read4(f)
		par.max = read4(f)
		local mid = read4(f)
		par.type = read1(f)
		if par.type == 1 then 
			par.fail = true
		elseif par.type == 2 then
			par.success = true
		elseif par.type == 3 then
			par.dead = true
		end
		read4(f)
		par.ifzero = (read1(f) == 1)
	
		if par.type ~= 0 then
			if (read1(f) == 1) then
				par.critical = "min" 
			else
				par.critical = "max" 
			end
		else
			read1(f)
		end
		par.active = (read1(f) == 1)
		local ranges = read1(f)
		skip(f, 3)
		local money = read1(f)
		read4(f)
		par.name = readu16(f)
		par.ranges = {}
		for n=1, ranges do
			local from = read4(f)
			local to = read4(f)
			read4(f)
			local t = readu16(f)
			table.insert(par.ranges, {from = from, to = to, title = t })
		end
		read4(f)
		par.dsc = readu16(f)
		read4(f)
		par.start = readu16(f)
		if par.active then
			par.start = parse_start(par.start)
		end
		table.insert(quest.parameters, par)
	end
	read4(f)
	readu16(f)
	skip(f, 4)
	readu16(f)
	skip(f, 4)
	readu16(f)
	skip(f, 4)
	readu16(f)
	skip(f, 4)
	readu16(f)
	skip(f, 4);
	readu16(f)
	skip(f, 4);
	readu16(f)
	skip(f, 4);
	readu16(f)
	skip(f, 4);
	readu16(f)
	
	local locnr = read4(f)
	local pathnr = read4(f)
	read4(f)
	quest.happy = readu16(f)
	read4(f)
	quest.dsc = readu16(f)
	skip(f, 8)
	for i=1, locnr do
		local location = {}
		location.day = (read4(f) == 1)
		read4(f)
		read4(f)
		location.id = read4(f)
		location.start = (read1(f) == 1)
		location.success = (read1(f) == 1)
		location.failed = (read1(f) == 1)
		local dead = (read1(f) == 1)
		if dead then
			location.failed = true
		end
		location.empty = (read1(f) == 1)
	--	print(locid, start, succ, fail, dead, empty)
		location.parameters = {}
		for p=1, pnr do
			local par = {}
			skip(f, 12)
			par.id = p
			par.add=read4(f)
			par.show = read1(f)
			skip(f, 4)
			par.percent = (read1(f) == 1)
			par.equal = (read1(f) == 1)
			par.expr = (read1(f) == 1)
			read4(f)
			par.eval = readu16(f)
			skip(f, 14)
			par.dsc = readu16(f)
			if (par.show ~=0 or par.add ~= 0 or par.equal or ( par.expr and par.eval )) and quest.parameters[p].active then
				table.insert(location.parameters, par)
			end
	--		print(add, show, percent, equal, expr, eval)
		end
	--	skip(f, 3)
		location.descriptions = {}
		for di = 1, 10 do
			skip(f, 4)
			local d = readu16(f)
			if d then
				table.insert(location.descriptions, d)
			end
		end
		location.dscsel = (read1(f) == 1)
		read4(f)
		read4(f)
		local name = readu16(f)
		read4(f)
		readu16(f)
		read4(f)
		location.dscselexpr = readu16(f)
		location.pathes = {}
		quest.locations[location.id] = location
	end
	for i=1, pathnr do
		local path = {}
		path.pri = readd(f)
		path.day = (read4(f) == 1)
		path.id = read4(f)
		local fr = read4(f)
		path.loc = read4(f)
		read1(f)
		path.visible = (read1(f) == 1)
		path.count = read4(f)
		path.sort = read4(f)
		local kk
		path.parameters = {}
		for kk = 1, pnr do
			local par = {}
			local m = read4(f)
			par.id = kk;
			par.r1 = read4(f)
			par.r2 = read4(f)
			local rangeit = false
			if par.r1 > quest.parameters[kk].min or par.r2 < quest.parameters[kk].max then
				rangeit = true
			end
			par.add = read4(f)
			par.show = read4(f)
			read1(f)
			par.percent = (read1(f) == 1)
			par.equal = (read1(f) == 1)
			par.expr = (read1(f) == 1)
			read4(f)
			par.eval = readu16(f)
			
			local n = read4(f)
			par.inclusive = (read1(f) == 1)
			par.numbers = {}
			for nn=1,n do
				table.insert(par.numbers, read4(f))
			end
			n = read4(f)
			par.divide = (read1(f) == 1)
			par.mods = {}
			for nn=1,n do
				table.insert(par.mods, read4(f))
			end
			read4(f)
			local criticaldsc = readu16(f)
			if criticaldsc and (criticaldsc ~= quest.parameters[kk].dsc) then
				par.customDesc = criticaldsc
			end
			if (par.show ~= 0 or par.add ~= 0 or par.percent or par.equal or (par.expr and par.eval) or #par.numbers > 0 or 
				#par.mods > 0 or rangeit) and quest.parameters[kk].active then
				table.insert(path.parameters, par);
			end
		end
		read4(f)
		path.cond = readu16(f)
		read4(f)
		path.title = readu16(f)
		read4(f)
		path.dsc = readu16(f)
		table.insert(quest.locations[fr].pathes, path);
	end
	f:close()
	if out then
		dump(out)
	else
		dump(fname:gsub("[qQ][mM]$","lua"))
	end
end
if arg and arg[1] then
	convert(arg[1])
end
