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
	if quest.giver_race == 1 then
		print [[Ranger="Урк Ужасный"]]
		print [[Player="малок"]]
		print [[FromPlanet="Квагга"]]
		print [[FromStar="Глобза"]]
	elseif quest.giver_race == 2 then
		print [[Ranger="Зумакка"]]
		print [[Player="пеленг"]]
		print [[FromPlanet="Хулгакка"]]
		print [[FromStar="Пиллазон"]]
	elseif quest.giver_race == 8 then
		print [[Ranger="Фьюб"]]
		print [[Player="фэянин"]]
		print [[FromPlanet="Химоза"]]
		print [[FromStar="Тиа"]]
	elseif quest.giver_race == 10 then
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
	print ([[ToStar="]]..quest.to_star..[["]])
	print ([[ToPlanet="]]..quest.to_planet..[["]])
	print ([[Money="]]..tostring(quest.money)..[["]])
	print ([[Day="]]..tostring(quest.day)..[["]])
	local tm
	tm = deterministicTimestamp
	local tt = os.date("*t", tm)
	tt.year = 2011
	tm = os.time(tt)
	print ("global { CurTime = "..tostring(quest.cur_time).." };");
	print ([[Date="]]..quest.date..[["]])
	if quest.description then
		print ("main.desc="..string.format("%q", quest.description))
	end
	if quest.congrat_message then
		print ("happyend.desc = "..string.format("%q", quest.congrat_message));
	end
	for k,v in ipairs(quest.parameters) do
		if v.is_active then
			print("p"..tostring(k).." = param {");
			print("\tnam = "..string.format("%q", tostring(v.name))..";");
			print("\tmin = "..tostring(v.range_start)..";");
			print("\tmax = "..tostring(v.range_stop)..";");
			print("\tstart = "..tostring(v.start_value)..";");
			if v.fail or v.death  then
				print("\tfailed = true;");
			end
			if v.success then
				print("\tsuccess = true;");
			end
			if v.show_at_zero then
				print("\tshowIfZero = true;");
			end
			if v.critical_boundary then
				print("\tcritical = '"..v.critical_boundary.."';");
				if not v.critical_message then -- BUG???
					v.critical_message = '';
				end
				print("\tdesc = "..string.format("%q", v.critical_message)..";");
			end
			if #v.grades > 0 then
				print("\tranges = {");
				local kk,vv
				for kk,vv in ipairs(v.grades) do
					if vv.label then
						print("\t\t{ from = "..tostring(vv.range_start).."; to = "..tostring(vv.range_stop).."; title = "..string.format("%q", vv.label).." };");
					end
				end
				print("\t};");
			end
			print("}");
--			print(v.range_start, v.range_stop, v.name, v.description);
		end
	end
	for k,v in pairs(quest.locations) do
		print("l"..k.." = loc {");
		local kk,vv
		if v.is_initial then
			print("\tstart = true;");
		end
		if v.is_success then
			print("\tsuccess = true;");
		end
		if v.is_fail then
			print("\tfailed = true;");
		end
		if v.is_empty then
			print("\tempty = true;");
		end
		if v.passes_days then
			print("\tday = true;");
		end
		if v.text_selection_method and #v.descriptions > 0 then
			local c
			if not v.text_selection_formula then
				c = "randomdesc("..tostring(#v.descriptions)..")";
			else
				c = parse_expr(v.text_selection_formula)
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
		if #v.actions > 0 then
			local t = ""
			for kk,vv in ipairs(v.actions) do
				if vv.show_ ~= 0 then
					t = t.."p"..tostring(vv.idx)..":visible("..tostring(vv.show_ == 1).."); "
				end
				if vv.expr_present then
--					t = t..parse_expr(vv.expr);
					t = t.."p"..tostring(vv.idx)..":equal("..parse_expr(vv.expr)..");";
				else
					local c = "units";
					if vv.percent_present then
						c = "percent";
					elseif vv.delta_present then
						c = "equal"
					end
					if vv.delta ~= 0 or vv.delta_present then
						t = t.."p"..tostring(vv.idx)..":"..c.."("..tostring(vv.delta)..");";
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
				if vv.priority ~= 1 then
					t = t.."\t\t\tpri = "..tostring(vv.priority)..",\n";
				end
				if vv.limit ~= 0 then
					t = t.."\t\t\tcount = "..tostring(vv.limit)..",\n";
				end
				if vv.passes_days then
					t = t.."\t\t\tday = true,\n";
				end
				if vv.always_show then
					t = t.."\t\t\talwaysShow = true,\n";
				end
				if vv.show_order ~= 5 then
					t = t.."\t\t\tsort = "..tostring(vv.show_order)..",\n";
				end
				t = t.."\t\t\tto = 'l"..tostring(vv.destination_id).."',\n";
				if vv.description then
					t = t.."\t\t\tdesc = "..string.format("%q", vv.description)..",\n";
				end
				if vv.title then
					t = t.."\t\t\ttitle = "..string.format("%q", vv.title)..",\n";
				end
				local parcond = ''
				if #vv.actions > 0 then
					local code = "";
					for kkk,vvv in ipairs(vv.actions) do
						local pname = "p"..tostring(vvv.idx)
						if vvv.threshold_message then
							code = code..pname..":customDesc("..string.format("%q",vvv.threshold_message)..");";
						end
						if vvv.show_ ~= 0 then
							code = code..pname..":visible("..tostring(vvv.show_ == 1)..");";
						end
						if vvv.range_start > quest.parameters[vvv.idx].range_start or
							vvv.range_stop < quest.parameters[vvv.idx].range_stop then
							if parcond ~= '' then
								parcond = parcond.." and ";
							end
							parcond = parcond..pname..":range("..tostring(vvv.range_start)..", "..tostring(vvv.range_stop)..")";
						end
						if #vvv.includes_values > 0 then
							if parcond ~= '' then
								parcond = parcond.." and ";
							end
							if vvv.includes_accept then
								parcond = parcond..pname..":inval(";
							else
								parcond = parcond.."not "..pname..":inval(";
							end
							local z,x
							for z,x in ipairs(vvv.includes_values) do
								parcond = parcond..tostring(x)
								if z ~= #vvv.includes_values then
									parcond = parcond..", "
								end
							end
							parcond = parcond..")";
						end

						if #vvv.mods_values > 0 then
							if parcond ~= '' then
								parcond = parcond.." and ";
							end
							if vvv.mods_type then
								parcond = parcond..pname..":mod0(";
							else
								parcond = parcond.."not "..pname..":mod0(";
							end
							local z,x
							for z,x in ipairs(vvv.mods_values) do
								parcond = parcond..tostring(x)
								if z ~= #vvv.mods_values then
									parcond = parcond..", "
								end
							end
							parcond = parcond..")";
						end

						if vvv.expr_present then
							code = code..pname..":equal("..parse_expr(vvv.expr)..");";
						else
							local c = "units";
							if vvv.percent_present then
								c = "percent";
							elseif vvv.delta_present then
								c = "equal"
							end
							if vvv.delta ~= 0 or vvv.delta_present then
								code = code..pname..":"..c.."("..tostring(vvv.delta)..");";
							end
						end
					end
					if code ~= "" then
						t = t.."\t\t\tcode = "..string.format("%q", code)..",\n";
					end
				end
				if vv.condition_expr then
					if parcond ~= '' then
						parcond = parse_expr(vv.condition_expr).." ~= 0 and "..parcond;
					else
						parcond = parse_expr(vv.condition_expr).." ~= 0";
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
	local signature = read4(f)
	if signature == 0x423a35d4 then -- from Erendir
		parameter_count = 96
	elseif signature == 0x423a35d3 then
		parameter_count = 48
	elseif signature == 0x423a35d2 then
		parameter_count = 24
	else
		error "wrong signature"
	end
	read4(f);
	quest.giver_race = read1(f, 1);
	skip(f, 57 - 4 - 8 - 4 - 1);
	quest.transition_limit = read4(f)
	quest.difficulty = read4(f)
	for p = 1, parameter_count do
		local par = {}
		par.range_start = read4(f)
		par.range_stop = read4(f)
		local mid = read4(f)
		par.type = read1(f)
		if par.type == 1 then 
			par.fail = true
		elseif par.type == 2 then
			par.success = true
		elseif par.type == 3 then
			par.death = true
		end
		read4(f)
		par.show_at_zero = (read1(f) == 1)

		if par.type ~= 0 then
			if (read1(f) == 1) then
				par.critical_boundary = "min" 
			else
				par.critical_boundary = "max" 
			end
		else
			read1(f)
		end
		par.is_active = (read1(f) == 1)
		local ranges = read1(f)
		skip(f, 3)
		local money = read1(f)
		read4(f)
		par.name = readu16(f)
		par.grades = {}
		for n=1, ranges do
			local range_start = read4(f)
			local range_stop = read4(f)
			read4(f)
			local label = readu16(f)
			table.insert(par.grades, {range_start = range_start, range_stop = range_stop, label = label })
		end
		read4(f)
		par.critical_message = readu16(f)
		read4(f)
		par.start_value = readu16(f)
		if par.is_active then
			par.start_value = parse_start(par.start_value)
		end
		table.insert(quest.parameters, par)
	end

	read4(f)
	quest.to_star = readu16(f)
	skip(f, 4)
	quest.parsec = readu16(f)
	skip(f, 4)
	quest.artefact = readu16(f)
	skip(f, 4)
	quest.to_planet= readu16(f)
	skip(f, 4)
	quest.date = readu16(f)
	skip(f, 4);
	quest.money = readu16(f)
	skip(f, 4);
	quest.from_planet = readu16(f)
	skip(f, 4);
	quest.from_star = readu16(f)
	skip(f, 4);
	quest.ranger = readu16(f)

	local xx = math.random(#systems)
	quest.to_star = systems[xx][1]
	quest.to_planet = systems[xx][2]
	quest.money = math.random(20)*250
	quest.day = math.random(7) + 5
	
	local tm
	tm = deterministicTimestamp
	local tt = os.date("*t", tm)
	tt.year = 2011
	tm = os.time(tt)
	quest.cur_time = tm
	quest.date = os.date ("%d-%m-%Y", tm):gsub("2011", "3011")

	local loc_count = read4(f)
	local transition_count = read4(f)
	read4(f)
	quest.congrat_message = readu16(f)
	read4(f)
	quest.description = readu16(f)
	skip(f, 8)
	for i=1, loc_count do
		local location = {}
		location.passes_days = (read4(f) == 1)
		read4(f)
		read4(f)
		location.id = read4(f)
		location.is_initial = (read1(f) == 1)
		location.is_success = (read1(f) == 1)
		location.is_fail = (read1(f) == 1)
		local is_death = (read1(f) == 1)
		if location.is_death then
			location.is_fail = true
		end
		location.is_empty = (read1(f) == 1)
	--	print(locid, start, succ, fail, dead, empty)
		location.actions = {}
		for p=1, parameter_count do
			local par = {}
			skip(f, 12)
			par.idx = p
			par.delta=read4(f)
			par.show_ = read1(f)
			skip(f, 4)
			par.percent_present = (read1(f) == 1)
			par.delta_present = (read1(f) == 1)
			par.expr_present = (read1(f) == 1)
			read4(f)
			par.expr = readu16(f)
			skip(f, 14)
			par.threshold_message = readu16(f)
			if (par.show_ ~=0 or par.delta ~= 0 or par.delta_present or ( par.expr_present and par.expr )) and quest.parameters[p].is_active then
				table.insert(location.actions, par)
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
		location.text_selection_method = (read1(f) == 1)
		read4(f)
		read4(f)
		local name = readu16(f)
		read4(f)
		readu16(f)
		read4(f)
		location.text_selection_formula = readu16(f)
		location.pathes = {}
		quest.locations[location.id] = location
	end
	for i=1, transition_count do
		local path = {}
		path.priority = readd(f)
		path.passes_days = (read4(f) == 1)
		path.id = read4(f)
		local source_id = read4(f)
		path.destination_id = read4(f)
		read1(f)
		path.always_show = (read1(f) == 1)
		path.limit = read4(f)
		path.show_order = read4(f)
		local kk
		path.actions = {}
		for kk = 1, parameter_count do
			local par = {}
			local m = read4(f)
			par.idx = kk;
			par.range_start = read4(f)
			par.range_stop = read4(f)
			local rangeit = false
			if par.range_start > quest.parameters[kk].range_start or par.range_stop < quest.parameters[kk].range_stop then
				rangeit = true
			end
			par.delta = read4(f)
			par.show_ = read4(f)
			read1(f)
			par.percent_present = (read1(f) == 1)
			par.delta_present = (read1(f) == 1)
			par.expr_present = (read1(f) == 1)
			read4(f)
			par.expr = readu16(f)
			
			local n = read4(f)
			par.includes_accept = (read1(f) == 1)
			par.includes_values = {}
			for nn=1,n do
				table.insert(par.includes_values, read4(f))
			end
			n = read4(f)
			par.mods_type = (read1(f) == 1)
			par.mods_values = {}
			for nn=1,n do
				table.insert(par.mods_values, read4(f))
			end
			read4(f)
			local threshold_message = readu16(f)
			if threshold_message and (threshold_message ~= quest.parameters[kk].dsc) then
				par.threshold_message = threshold_message
			end
			if (par.show_ ~= 0 or par.delta ~= 0 or par.percent_present or par.delta_present or (par.expr_present and par.expr) or #par.includes_values > 0 or 
				#par.mods_values > 0 or rangeit) and quest.parameters[kk].is_active then
				table.insert(path.actions, par);
			end
		end
		read4(f)
		path.condition_expr = readu16(f)
		read4(f)
		path.title = readu16(f)
		read4(f)
		path.description = readu16(f)
		table.insert(quest.locations[source_id].pathes, path);
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
