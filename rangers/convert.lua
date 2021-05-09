--#!/usr/bin/lua

deterministicTimestamp = 1359108621


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
			print("\tmin = "..tostring(v.range.start)..";");
			print("\tmax = "..tostring(v.range.stop)..";");
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
			if v.type.value ~= 0 and v.critical_boundary then
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
						print("\t\t{ from = "..tostring(vv.range.start).."; to = "..tostring(vv.range.stop).."; title = "..string.format("%q", vv.label).." };");
					end
				end
				print("\t};");
			end
			print("}");
--			print(v.range.start, v.range.stop, v.name, v.description);
		end
	end
	for k,v in pairs(quest.locations) do
		print("l"..k.." = loc {");
		local kk,vv
		if v.type.is_initial then
			print("\tstart = true;");
		end
		if v.type.is_success then
			print("\tsuccess = true;");
		end
		if v.type.is_fail then
			print("\tfailed = true;");
		end
		if v.type.is_empty then
			print("\tempty = true;");
		end
		if v.passes_days > 0 then
			print("\tday = " .. v.passes_days .. ";");
		end
		if v.text_selection_method.value ~= 0 and #v.descriptions > 0 then
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
			if vv.msg then
				if kk > 1 then
					n = n..tostring(kk)
				end
				print("\t"..n.." = "..string.format("%q", vv.msg)..";");
			end
		end
		if #v.actions > 0 then
			local t = ""
			for kk,vv in ipairs(v.actions) do
				if vv.show_.value ~= 0 then
					t = t.."p"..tostring(vv.luaIdx)..":visible("..tostring(vv.show_.value == 1).."); "
				end
				if vv.expr_present then
--					t = t..parse_expr(vv.expr);
					t = t.."p"..tostring(vv.luaIdx)..":equal("..parse_expr(vv.expr)..");";
				else
					local c = "units";
					if vv.percent_present then
						c = "percent";
					elseif vv.delta_present then
						c = "equal"
					end
					if vv.delta ~= 0 or vv.delta_present then
						t = t.."p"..tostring(vv.luaIdx)..":"..c.."("..tostring(vv.delta)..");";
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
				if vv.passes_days > 0 then
					t = t.."\t\t\tday = " .. vv.passes_days .. ",\n";
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
						local pname = "p"..tostring(vvv.luaIdx)
						if vvv.threshold_message then
							code = code..pname..":customDesc("..string.format("%q",vvv.threshold_message)..");";
						end
						if vvv.show_.value ~= 0 then
							code = code..pname..":visible("..tostring(vvv.show_.value == 1)..");";
						end
						if vvv.range.start > vvv.param.range.start or
							vvv.range.stop < vvv.param.range.stop then
							if parcond ~= '' then
								parcond = parcond.." and ";
							end
							parcond = parcond..pname..":range("..tostring(vvv.range.start)..", "..tostring(vvv.range.stop)..")";
						end
						if #vvv.includes.values > 0 then
							if parcond ~= '' then
								parcond = parcond.." and ";
							end
							if vvv.includes.accept then
								parcond = parcond..pname..":inval(";
							else
								parcond = parcond.."not "..pname..":inval(";
							end
							local z,x
							for z,x in ipairs(vvv.includes.values) do
								parcond = parcond..tostring(x)
								if z ~= #vvv.includes.values then
									parcond = parcond..", "
								end
							end
							parcond = parcond..")";
						end

						if #vvv.mods.values > 0 then
							if parcond ~= '' then
								parcond = parcond.." and ";
							end
							if vvv.mods.type then
								parcond = parcond..pname..":mod0(";
							else
								parcond = parcond.."not "..pname..":mod0(";
							end
							local z,x
							for z,x in ipairs(vvv.mods.values) do
								parcond = parcond..tostring(x)
								if z ~= #vvv.mods.values then
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

-- Now parser is implemented via a Kaitai Struct spec, it can be obtained here: https://github.com/KOLANICH/kaitai_struct_formats/blob/space_rangers/game/space_rangers_qm.ksy
-- You would need a MIT-licensed (copyright 2017-2020 Kaitai Project) lua runtime, it can be obtained here: https://github.com/kaitai-io/kaitai_struct_lua_runtime
-- The runtime may need a patch to support UTF-16. The one here already has one, the UTF16-to UTF-8 decoder was taken from this file.

space_rangers_qm = require("space_rangers_qm")
postprocess = require("space_rangers_qm_postprocess")

function convert(fname, out)
	math.randomseed(deterministicTimestamp)
	math.random(1); math.random(2); math.random(3); -- Lua bug?

	function tryParse()
		quest = space_rangers_qm:from_file(fname)
	end
	if not pcall(tryParse) then
		error "can't open file"
	end

	locations_by_id = {}
	postprocess(quest)

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

	for i, par in pairs(quest.parameters) do
		if par.type.value == 1 then 
			par.fail = true
		elseif par.type.value == 2 then
			par.success = true
		elseif par.type.value == 3 then
			par.death = true
		end

		par.critical_boundary = par.critical_boundary.label
		if par.is_active then
			par.start_value = parse_start(par.start_value)
		end
	end

	for i, location in pairs(quest.locations) do
		if location.type.is_death then
			location.type.is_fail = true
		end
	--	print(locid, start, succ, fail, dead, empty)
		local needed_actions = {}
		for p, par in pairs(location.actions) do
			par.luaIdx = par.idx + 1
			if (par.show_.value ~=0 or par.delta ~= 0 or par.delta_present or ( par.expr_present and par.expr )) and quest.parameters[p].is_active then
				table.insert(needed_actions, par)
			end
	--		print(add, show, percent, equal, expr, eval)
		end
		location.actions = needed_actions
		location.pathes = {}
		locations_by_id[location.id] = location
	end
	quest.locations = locations_by_id
	for i, path in pairs(quest.transitions) do
		local kk
		local needed_actions = {}
		for kk, par in pairs(path.actions) do
			par.luaIdx = par.idx + 1
			local rangeit = false
			if par.range.start > quest.parameters[kk].range.start or par.range.stop < quest.parameters[kk].range.stop then
				rangeit = true
			end
			if threshold_message and (threshold_message ~= quest.parameters[kk].critical_message) then
				par.threshold_message = par.threshold_message
			end
			if (par.show_.value ~= 0 or par.delta ~= 0 or par.percent_present or par.delta_present or (par.expr_present and par.expr) or #par.includes.values > 0 or 
				#par.mods.values > 0 or rangeit) and quest.parameters[kk].is_active then
				table.insert(needed_actions, par);
			end
		end
		path.actions = needed_actions
		table.insert(quest.locations[path.source_id].pathes, path);
	end
	if out then
		dump(out)
	else
		dump(fname:gsub("[qQ][mM]$","lua"))
	end
end
if arg and arg[1] then
	convert(arg[1])
end
