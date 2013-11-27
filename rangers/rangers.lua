if true then
-- DEBUG_MODE = true
instead_version "1.4.4"
require "xact"
require "para"
require "dash"
require "hideinv"
require "theme"
require "timer"
-- require "quotes"

music_player = obj {
	nam = 'player';
	system_type = true;
	var { pos = 1; };
	ini = function(s)
		local f
		if not s.playlist then
			s.playlist = {}
			for f in stead.readdir(get_gamepath().."/mus") do
				if f ~= '.' and f ~= '..' then
					table.insert(s.playlist, f)
				end
			end
		end
		if #s.playlist > 0 then
			s.pos = rnd(#s.playlist)
		end
		table.sort(s.playlist);
	end;
	life = function(s)
		if is_music() then
			return
		end
		if #s.playlist == 0 then
			timer:stop()
			return
		end
		set_music('mus/'..s.playlist[s.pos]);
		s.pos = s.pos + 1
		if s.pos > #s.playlist then
			s.pos = 1
		end
	end
}

game.timer = function(s)
	music_player:life();
end

function start_player()
	timer:set(1000)
	lifeon(music_player);
end


function load_picmap(fn)
	local l
	local f = io.open(fn, "r");
	local name, num
	if not f then return end
	game.picture_map = true
	for l in f:lines() do
		if not l:find("^[ \t]*$") then
			local inline = false
			if l:find(":") then
				name = l:gsub("^[ \t]*([^:]+)[ \t]*:.*$", "%1");
				inline = true
			end
			if name then
				if inline then
					num = l:gsub("^[ \t]*[^:]+[ \t]*:(.*)$", "%1");
				else
					num = l;
				end
				if num then
					num:gsub("[0-9]+", 
						function(s) 
							if isRoom(ref("l"..s)) then
								_G["l"..s].pic = _PICT_PATH.."/"..name..';mask.png@0,0';
							end
							return  
						end);
				end
			end
		end
	end
	f:close();
end

math.round = function(num, idp)
	if type(num) == 'string' then return num end
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

game.variables = { 'name' }

function randomdesc(n)
	local s = here()
	if not s._rnddesc or s._rndn > n then
		local rnddesc = { }
		local rnd2 = { }
		local i
		for i = 1, n do
			table.insert(rnddesc, i)
		end
		for i = 1, n do
			local m = rnd(#rnddesc)
			table.insert(rnd2, rnddesc[m])
			table.remove(rnddesc, m)
		end
		s._rnddesc = rnd2
		s._rndn = 1
	end
	local r = s._rnddesc[here()._rndn]
	return r
end
fixfilter = function(s)
	s = s:gsub("<fix>","\1"):gsub("</fix>", "\2");
	s = s:gsub("\1[^\2]+\2", function(s)
		s = s:gsub("%^","^_");
		return s:gsub("([ ]+)","<w:%1>");
	end);
	s = s:gsub("\1", "<l><b><i>");
	s = s:gsub("\2", "</i></b></l>");
	return s;
end
ofilter = function(s)
	if not s then return end
	s = s:gsub("<Ranger>",Ranger):gsub("<FromPlanet>",FromPlanet):gsub("<ToPlanet>",ToPlanet):gsub("<ToStar>",ToStar):gsub("<FromStar>",FromStar):gsub("<Money>",Money):gsub("<Date>",Date):gsub("<Day>", Day):gsub("<Player>", Player);
	s = s:gsub("<CurDate>", function(s)
		return os.date("%d-%m-%Y", CurTime)
	end):gsub("2011", "3011");
	s = s:gsub("<clr>","<b>");
	s = s:gsub("<clrEnd>", "</b>");
	s = s:gsub("<br>", "^"):gsub("<format[^>]*>",""):gsub("</format>","");
	s = s:gsub("<%%>", "статистика не доступна");
	s = s:gsub("%[p[0-9]+%]", function (s)
		local ss = s:gsub("[%[%]]","");
--		print(s,"->", ss);
		if _G[ss] then
			return tostring(_G[ss]:val())
		end
		return s
	end)
	s = s:gsub("%$%|[^%|]+%|", function (s)
--		print("expr1 = ", s);
		local ss = s:gsub("%$%|([^%|]+)%|","%1");
--		print("expr2 = ", ss);
		return tostring(math.round(expr(ss, true)))
	end)
	s = fixfilter(s);
	return s
end

local criticals = { table = {}, }

function process_criticals()
	local k,s
	for k,s in ipairs(criticals) do
		local dsc
		if s.customDescTime == time() then
			dsc = s.customDescMsg
		else
			dsc = s.desc
		end
		if dsc then
			dsc = dsc:gsub("<>",tostring(s._val))
		end
		if dsc then
			p (dsc)
		end
		if (s.failed or s.success) then
			if s.ranged then
				return
			end
			if dsc then
				theend._dsc = ofilter(dsc)
			end
			if s.success then
				gotohappy:enable()
			end
			criticals = { table = {}, }
			walk 'theend'
			return
		end
	end
	criticals = { table = {}, }
end
local ranged = {}
local pending = {}

function commit()
	local k,v
	for k,v in ipairs(pending) do
		v.p["_val"] = v.v;
		v.p:process()
	end
	pending = {}
end

function param(v)
	v._show = true
	v._val = v.start;
	v.name = v.nam
	v.val = function(s)
		return s._val;
	end

	v.range = function(s, a, b)
		local r = s._val >= a and s._val <= b
		if r then table.insert(ranged, s) end
		return r
	end

	v.inval = function(s, ...)
		local a = {...};
		local k,v
		for k,v in ipairs(a) do
			if v == s._val then return true end
		end
		return false
	end

	v.mod0 = function(s, ...)
		local a = {...};
		local k,v
		for k,v in ipairs(a) do
			if s._val % v == 0 then return true end
		end
		return false
	end

	v.visible = function(s, o)
		s._show = o
	end

	v.units = function(s, a)
		local v = math.round(s._val + a)
		table.insert(pending, { p = s, v = v });
	end

	v.customDesc = function(s, d)
		s.customDescMsg = d
		s.customDescTime = time()
	end

	v.equal = function(s, a)
		if a then
			local v = math.round(a)
			table.insert(pending, { p = s, v = v });
		end
	end

	v.process = function(s)
		local c = false
		if s.critical == 'max' and s._val >= s.max then
			c = true
		elseif s.critical == 'min' and s._val <= s.min then
			c = true
		end
		if c then
			s.ranged = false
		end
		if s.max and s._val > s.max then s._val = s.max end
		if s.min and s._val < s.min then s._val = s.min end
		if c and not criticals.table[s] then
			table.insert(criticals, s);
			criticals.table[s] = s
		end
	end

	v.percent = function(s, a)
		local v = math.round(s._val + s._val * a / 100)
		table.insert(pending, { p = s, v = v });
	end
	v.menu = function(s)
		if s.ranges then
			local k,v
			for k,v in ipairs(s.ranges) do
				if s._val >= v.from and s._val <= v.to then
					local t = v.title
					t = t:gsub("<>",tostring(s._val))
					return ofilter(t):gsub("|","\\|")
				end
			end
		else
			p(s._val)
		end		
	end
	v.nam = function(s)
		local show = false
		if not s._show then return true end
		if not s.showIfZero and s._val == 0 then return true end
		if not s.ranges then return true end
		local k,v
		for k,v in ipairs(s.ranges) do
			if s._val >= v.from and s._val <= v.to then
				show = true
				break
			end
		end
		if show then
--			p (s.name);
			return s:menu()
		else
			return true
		end
	end;
	v = stat(v)
	take(v)
	return v
end
display = obj {
	nam = 'display';
	dsc = function(s)
		if here()._pathes then
			p (here()._pathes)
		end
	end
}

local function scan_moots(pathes)
	local k,v
	local moots = {}
	for k,v in ipairs(pathes) do
		local kk,vv
		if not v.moot  then
			local m = {}
			table.insert(m, v)
			for kk=k + 1, #pathes do
				vv = pathes[kk]
				if not vv.moot and vv.title == v.title then
					v.moot = true
					vv.moot = true
					table.insert(m, vv)
				end
			end
			if #m > 1 then
				table.insert(moots, m)
			end
		end
	end
	for k,v in ipairs(moots) do
		local kk, vv
		local n = #v
		local norm = 0
		local maxpri = -1;
		for kk,vv in ipairs(v) do
			if not vv.pri then
				vv.pri = 1
			end
			vv.normpri = vv.pri; -- 1 / vv.pri
			if vv.normpri > maxpri then
				maxpri = vv.normpri
			end
		end
		for kk,vv in ipairs(v) do
--			vv.normpri = vv.pri / norm
			vv.moot_selected = false
			if vv.disabled or maxpri / vv.normpri >= 100 then
				vv.moot_disabled = true
			else
				norm = norm + vv.normpri
				vv.moot_disabled = false
			end
		end
		local r = math.random() * norm
		for kk,vv in ipairs(v) do
			if not vv.moot_disabled then
				r = r - vv.normpri
				if r <= 0 then
					vv.moot_selected = true
					break
				end
			end
		end
	end
end
function disabled_loc(l)
	local k,v
	l = ref(l)
	if not l.pathes then
		return false
	end
	for k,v in ipairs(l.pathes) do
		if not v._count or not v.count or v.count == 0 then
			return false
		end
		if v._count < v.count then
			return false
		end
	end
	return true
end
function loc(v)
	if not v.nam then
		v.nam = function(s)
			if DEBUG_MODE then
				return (deref(s))
			end
			if s.success or s.failed then
				return "Конец"
			end
			if game.name then
				return game.name
			end
			return '^'
		end
	end

	v.forcedsc = true

	if v.start then
		main.start = v
	end
	v.fill = function(s)
		local k,v
		objs(s):zap()
		objs(s):add(display);
		if s.pathes then
			for k,v in ipairs(s.pathes) do
				local x = xact(tostring(k), function(s) dopath(k) end)
				x.save = function() end
				objs(s):add(x)
			end
		end
		if s.success then
			gotohappy:enable()
			objs(s):add 'gotohappy'
		end
	end
	v.ini = function(s, load)
		if load and here() == s then
			s:fill()
--			print(s._pathes)
		end
	end
	if not v.exit then
	v.exit = function(s, to)
		s._fromdsc = nil
		if s._rndn then
			s._rndn = s._rndn + 1
		end
	end
	end
	if not v.enter then
	v.enter = function(s)
		if s.day then next_day() end

		if s.code then
			if s.codef then
				s.codef()
			else
				local f = stead.eval(s.code)
				if not f then
					error ("Wrong script: "..tostring(s.code), 2);
				end
				f()
				s.codef = f
			end
			commit()
		end

		if s.dscsel then
			if not s.dscself then
				local f = stead.eval("return "..s.dscsel)
				if not f then
					error ("Wrong script: "..tostring(s.dscsel), 2)
				end
				s.dscself = f
			end
			s.dscnum = s.dscself()
		else
			s.dscnum = nil
		end

		local k, v
		local text=''
		local ways = {}
		local moots = {}
		local pnr = 0
		if s.pathes then
			for k,v in ipairs(s.pathes) do
				v.id = k
				v.moot = false
				v.disabled = false
				if not v._count then v._count = 0 end
				if not v.count then v.count = 0 end
			end

			for k,v in ipairs(s.pathes) do
				local c = true
				if v.count ~= 0 and v._count >= v.count then
					c = false
				end
				if disabled_loc(v.to) then
					c = false
				end
				ranged = {}
				if v.cond and c then
					if v.condf then
						c = v.condf()
					else
						c = "if "..v.cond.." then return true else return false end"
						local cc = stead.eval(c)
						if not cc then error ("Wrong expression:'"..c.."'", 1) end
						c = cc()
--						print("cond ", v.cond, "ret = ", c);
						v.condf = cc
					end
				end
				if c then
					local kk,vv
					for kk,vv in ipairs(ranged) do
						vv.ranged = true
					end
					table.insert(ways, v)
				elseif v.alwaysShow then
					v.disabled = true
					table.insert(ways, v)
				end
				ranged = {}
			end
			process_criticals()
			if player_moved() then
				return
			end
			scan_moots(ways)
			local ways2 = {}
			for k,v in ipairs(ways) do
				if not v.moot or v.moot_selected then
					if not v.moot and v.pri and v.pri < 1 then
						if math.random() <= v.pri then
							table.insert(ways2, v)
						end
					else
						table.insert(ways2, v)
					end
				end
			end
			ways = ways2
			stead.table.sort(ways, function(a, b)
				local a = a.sort
				if not a then a = 5 end
				local b = b.sort
				if not b then b = 5 end
				return a < b
			end)
			pnr = 0
			for k,v in ipairs(ways) do
				if v.title then
					local prefix = "--"..txtnb" ";
					local prefixno = "--"..txtnb" ";
					if theme:name() == "." then
						prefix = img('theme/answer.png')..txtnb" ";
						prefixno = img('theme/answerno.png')..txtnb" ";
					end
					if not v.disabled then
						pnr = pnr + 1
						text = text..prefix.."{"..tostring(v.id).."|"..ofilter(v.title) .. "}^";
					else
						text = text..prefixno..ofilter(v.title) .. "^";
					end
				end
			end
		else
			process_criticals()
			if player_moved() then
				return
			end
		end
		s:fill()
		s._pathes = text
--		print(pnr, #ways)
		if pnr == 0 and #ways > 0 then
--			print("Empty run:", ways[1].to);
			if not s.empty or s._fromdsc then
				s:dsc()
			end
			dopath(ways[1])
			return
		end
	end
	end
	if not v.dsc then
	v.dsc = function(s)
		if s.empty and s._fromdsc then
			p (s._fromdsc)
			return
		end
		local n = visits(s)
		local k
		local d = 0
		if s.dscnum then
			n = s.dscnum
		end
		if s.dscmax then
			d = s.dscmax
		else
			if s.desc then d = 1 end
			for k=2,10 do
				if not s["desc"..tostring(k)] then
					break
				end
				d = d + 1
			end
			s.dscmax = d
		end
		if n >= d then 
			if s.dscnum then
				n = d
			else
				n = 1
			end
		end
		if n <= 1 then
			p(ofilter(s.desc))
		else
			p(ofilter(s["desc"..tostring(n)]))
		end
	end
	end
	return room(v)
end

function dopath(n)
	local pa = n
	if tonumber(n) then
		pa = here().pathes[tonumber(n)]
	end
--	print("path ", n, "here ", deref(here()), "to ", pa.to)
--	print("code = ", pa.code)
	if pa.day then next_day() end
	if pa.code then
		if pa.codef then
			pa.codef()
		else
			local f = stead.eval(pa.code)
			if not f then
				error ("Wrong script: "..tostring(pa.code), 2);
			end
			f()
			pa.codef = f
		end
		commit()
	end
	if pa.desc and not ref(pa.to).empty then -- higher priority than fail? TODO
		p(ofilter(pa.desc))
	end
	pa._count = pa._count + 1
	ref(pa.to)._fromdsc = ofilter(pa.desc)

	process_criticals()

	if not player_moved() then
--		print("dopath:", pa.to)
		walk(pa.to)
	end
end

gotohappy = obj {
		nam = 'дальше';
		dsc = function(s)
			if happyend.desc then
				p '{Дальше}';
			end
		end;
		act = function(s) walk(happyend) end;
}:disable()

theend = room {
	nam = 'Конец';
	hideinv = true;
	forcedsc = true;
	dsc = function(s)
		return s._dsc;
	end;
	obj = { 'gotohappy' };
}
happyend = room {
	nam = 'Конец';
	dsc = function(s) return ofilter(s.desc) end;
	hideinv = true;
	forcedsc = true;
}
main = room {
	ini = function(s, load)
		if not _PICT_PATH then
			_PICT_PATH='pics'
		end
		load_picmap(_PICT_PATH.."/map.txt");
		if not load then
			start_player()
		end
	end;
	nam = function(s)
		if game.name then
			return game.name
		end
		return '^'
	end;
	dsc = function(s)
		return ofilter(s.desc)
	end;
	hideinv = true;
	system_type = true;
	enter = function(s)
		if not main.dsc then walk (main.start) end
	end;
	obj = { obj {
		nam = 'дальше';
		dsc = '{Дальше}';
		act = function(s) walk(main.start) end;
	}};
}
end
--[[ ******************************************************************** ]]--
LEFT=0
RIGHT=1
RANGE=-3
FUNC=-2
PAR=-1
function op(pri, dir, na, mna, f, regex)
	return { pri = pri, dir = dir, nr = na, mnr = mna, f = f, reg = regex};
end
function is_range(s)
	if type(s) == 'string' then
		if s:find("^%[[%-0-9%.;]+]$") then
			return true
		end
	end
	return false
end

function op_range(s)
	local r = get_range(s)
	if r.empty then return s end
	return rnd_range(get_range(s))
end

function get_range_limits(s)
	if not is_range(s) then
		if tonumber(s) then
			s = math.round(tonumber(s))
			return s, s
		end
		return
	end
	s = s:gsub("^%[(%-?[0-9]+)[^0-9].*(%-?[0-9]+)%]$","%1 %2");
	k,v = s:find(" ");
	local r1 = tonumber(s:sub(1, k))
	local r2 = tonumber(s:sub(k + 1))
	return r1, r2
end

function rnd_range(s)
	local k,v
	local n = 0
	for k,v in ipairs(s) do
		n = n + v.r - v.l + 1
	end
	local nn = math.random(n)
	for k,v in ipairs(s) do
		n = v.r - v.l + 1
		if nn <= n then
			return v.l + nn - 1
		end 
		nn = nn -n
	end
end

function and_range(r1, r2)
	if r1[1].l > r2[1].l then
		r2[1], r1[1] = r1[1], r2[1]
	end
	local a = #r1
	local b = #r2
	if r1[a].r > r2[b].r then
		r2[b], r1[a] = r1[a], r2[b]
	end
	local k,v
	local r = "["
	for k,v in ipairs(r1) do
		if v.l == v.r then
			r = r .. tostring(v.l)..';';
		else
			r = r .. tostring(v.l)..'..'..tostring(v.r)..';';
		end
	end
	for k,v in ipairs(r2) do
		if v.l == v.r then
			r = r .. tostring(v.l)..';';
		else
			r = r .. tostring(v.l)..'..'..tostring(v.r)..';';
		end
	end
	r = r:gsub(";$","");
	r = r.."]"
	return r
end
function in_range(s, n)
	local k, v
	for k,v in ipairs(s) do
		if n >= v.l and n <= v.r then
			return 1
		end
	end
	return 0
end
function get_range(s)
	local ranges = {};
	if not is_range(s) then
		s = math.round(tonumber(s))
		ranges.empty = true
		table.insert(ranges, { l = s, r = s });
		return ranges
	end
	s = s:gsub("[^;%[%]]+",function(s)
		if tonumber(s) then
			table.insert(ranges, { l = tonumber(s), r = tonumber(s) });
			return s
		end
		local l = s:gsub("^[ \t]*(%-?[0-9]+)%.%.%-?[0-9]+[ \t]*$", "%1");
		local r = s:gsub("^[ \t]*%-?[0-9]+%.%.(%-?[0-9]+)[ \t]*$", "%1");
		table.insert(ranges, { l = tonumber(l), r = tonumber(r) });
		return s
	end);
	return ranges
end

op_to = function(a, b)
	local l1, l2 = get_range_limits(a)
	local r1, r2 = get_range_limits(b)
	if r1 < l1 then l1 = r1 end
	if l2 > r2 then r2 = l2 end
	return "["..tostring(l1)..".."..tostring(r2).."]"
end

op_in = function(a, b)
	local lr = get_range(a)
	local rr = get_range(b)
	if lr.empty and rr.empty then
		if a == b then
			return 1
		end
		return 0
	end
	if not lr.empty and not rr.empty then
		local v = rnd_range(lr)
		return in_range(rr, v)
	end
	if lr.empty then
		return in_range(rr, lr[1].l);
	else
		return in_range(lr, rr[1].l);
	end
end

op_or = function(a, b)
	if is_range(a) or is_range(b) then
		local r1 = get_range(a)
		local r2 = get_range(b)
		return and_range(r1, r2)
	end
	if a ~=0 or b ~=0 then
		return 1
	end
	return 0
end
op_and = function(a, b)
	if is_range(a) or is_range(b) then
		local r1 = get_range(a)
		local r2 = get_range(b)
		return and_range(r1, r2)
	end
	if a ~= 0 and b ~= 0 then
		return 1
	end
	return 0
end
op_div = function(a, b)
	a = op_range(a)
	b = op_range(b)
	if b == 0 then
		if a < 0 then
			return -2000000000
		end
		return 2000000000
	end
	return tonumber(a / b);
end

op_divf = function(a, b)
	a = op_range(a)
	b = op_range(b)
	if b == 0 then
		if a < 0 then
			return -2000000000
		end
		return 2000000000
	end
	return math.floor(tonumber(a / b));
end

op_mod = function(a, b)
	a = op_range(a)
	b = op_range(b)
	if b == 0 then
		if a < 0 then
			return -2000000000
		end
		return 2000000000
	end
	return tonumber(a % b);
end

op_mul = function(a, b)
	a = op_range(a)
	b = op_range(b)
	return tonumber(a * b);
end

op_plus = function(a, b)
	a = op_range(a)
	b = op_range(b)
	return tonumber(a + b);
end

op_minus = function(a, b)
	a = op_range(a)
	if not b then
		return tonumber(-a)
	end
	b = op_range(b)
--	print(a, "- ", b);
	return tonumber(a - b);
end

op_eq = function(a, b)
	a = op_range(a)
	b = op_range(b)
	if a == b then
		return 1
	end
	return 0;
end

op_lt = function(a, b)
	a = op_range(a)
	b = op_range(b)
	if a < b then
		return 1
	end
	return 0;
end

op_le = function(a, b)
	a = op_range(a)
	b = op_range(b)
	if a <= b then
		return 1
	end
	return 0;
end

op_gt = function(a, b)
	a = op_range(a)
	b = op_range(b)
	if a > b then
		return 1
	end
	return 0;
end

op_ge = function(a, b)
	a = op_range(a)
	b = op_range(b)
	if a >= b then
		return 1
	end
	return 0;
end

op_ne = function(a, b)
	a = op_range(a)
	b = op_range(b)
	if a ~= b then
		return 1
	end
	return 0;
end

op_not = function(a)
	a = op_range(a)
	if a ~= 0 then
		return 0
	end
	return 1;
end

operators = {
	["[]"] = op(RANGE, 0, 0, 0, nil, "%[[^%]]+%]"),
	["or"] = op(1, 0, 2, 2, op_or),-- "||"),--"or[ \t]"),
	["and"] = op(2, 0, 2, 2, op_and),-- "&&"),--"and[ \t]"),
	["<>"] = op(3, 0, 2, 2, op_ne, "<[ \t]*>"),
	["="] = op(3, 0, 2, 2, op_eq, "=[ \t]*"),
	[">="] = op(3, 0, 2, 2, op_ge, ">[ \t]*="),
	[">"] = op(3, 0, 2, 2, op_gt, ">"),
	["<="] = op(3, 0, 2, 2, op_le, "<[ \t]*="),
	["<"] = op(3, 0, 2, 2, op_lt, "<"),
	["in"] = op(4, 0, 2, 2, op_in),
	["to"] = op(5, 0, 2, 2, op_to),
	["+"] = op(6, 0, 2, 1, op_plus),
	["-"] = op(7, 0, 2, 1, op_minus),
	["*"] = op(8, 0, 2, 2, op_mul),
	["/"] = op(9, 0, 2, 2, op_div),
	["div"] = op(9, 0, 2, 2, op_divf),
	["mod"] = op(9, 0, 2, 2, op_mod),

-- unar -
-- unar +
	["not"] = op(10, 0, 1, 1, op_not), --, "!"), --"not[ \t]"),
	["("] = op(PAR, 0),
	[")"] = op(PAR, 0),
}

function is_op(s)
	if operators[s] and operators[s].pri > 0 then
		return true;
	end
	return false
end

function is_token(s)
	if operators[s] then
		return true;
	end
	return false
end

function stack()
	local v = {}
	v.push = function(s, v)
		table.insert(s, v);
	end
	v.pop = function(s, v)
		return table.remove(s, table.maxn(s));
	end
	v.top = function(s)
		return s[table.maxn(s)]
	end
	return v;
end

function find_op(s)
	local k,i,n,o,oper
	local resi
	local resk
--	print (s);
	for k,o in pairs(operators) do
		if o.reg then
			i,n = s:find(o.reg, 1);
		else
			i,n = s:find(k, 1, true);
		end
		if not resi then resi = i; resk = n; oper = k; end
		if i and ((i < resi) or (i == resi and k:len() > oper:len())) then
			resi = i
			resk = n
			oper = k
--			print ("selecting "..oper.." at "..i);
		end
	end
	return resi,resk,oper
end

function get_token(s)
	local i,k,oper
	if not s then
		return
	end
	s = s:gsub("^[ \t]+","");
	if s:find("^[ \t]*$") then
		return nil,nil
	end
	local i,k,oper = find_op(s);
	if not i then
		return s:gsub("[ \t]+$", ""), nil;
	end
	if i == 1 then
		if oper == "[]" then
			return s:sub(1, k), s:sub(k+1)
		end
		return oper, s:sub(k+1)
	end
	return s:sub(1, i - 1):gsub("[ \t]+$",""), s:sub(i);
end

function expr2rpn(s)
	local t,lastt
	opstack = stack {};
	output = stack {};

	while true do
		t,s = get_token(s);
		local isn, num = is_number(t)
		if isn then
			t = num
		end
		if t == '-' and (is_op(lastt) or lastt == nil) then -- hack for unar -
			output:push('-1');
			t = '*'
		end
		if t ~= '(' and t ~= ')' then
			lastt = t;
		end
		if not t then -- no token
			while opstack:top() do
				local t = opstack:pop();
				if t == "(" or t == ")" then
					return nil
				end
				output:push(t);
			end
			return output;
		end
		if t == '(' then
			opstack:push(t);
		elseif t == ')' then
			while opstack:top() and opstack:top() ~= '(' do
--				print ("push ",opstack:top());
				output:push(opstack:pop());
				if opstack:top() and operators[opstack:top()].pri == FUNC then
					output:push(opstack:pop());
				end 
			end
			if opstack:top() ~= '(' then
				return nil
			end
			opstack:pop();
		elseif operators[t] == nil then
--			print ("pushx ",t);
			output:push(t);
		elseif operators[t].pri == FUNC then
			opstack:push(t);
		else
			local o1 = operators[t];
			while is_op(opstack:top()) do
				local o2 = operators[opstack:top()];
--				print (opstack:top());
				if (o1.dir == LEFT and o1.pri <= o2.pri) 
				or (o1.dir == RIGHT and o1.pri < o2.pri) then
--					print ("pusho ",opstack:top());
					output:push(opstack:pop());
				else
					break
				end
			end
			opstack:push(t);
		end
	end
end
function is_number(s)
	if not s then
		return false
	end
	if tonumber(s) then
		return true, s
	end
	s = s:gsub(",",".")
	if tonumber(s) then
		return true, s
	end
	return false
end
function rpnexpr(t)
	local top = 1
	while t ~= nil and top <= table.maxn(t) do
		if is_op(t[top]) then
			local o = table.remove(t, top);
			local oper = operators[o];
			local n = oper.nr;
			local f = oper.f;
			top = top - 1;
--			print("got ",o, "top ", top);
			if top < n then
				if oper.mnr and top >= oper.mnr then
					n = top;
				else
				-- no enouth args
					--error "no enouth args";
					return nil
				end
			end
			local a = {}
			local i = top - n + 1;
			while n ~= 0 do
				if not t[i] then
					error ("Error in expression in line: "..urq.ip);
				end
				local isn, num = is_number(t[i])
				if isn then
					t[i] = tonumber(num)
				end
				table.insert(a, t[i]);
				table.remove(t, i);
				n = n - 1;
			end
			local r = f(unpack(a));
			if r == nil then
				return nil -- wrong oper
			end
			table.insert(t, i, r);
			top = i + 1;
		--	print ("table: ", table.maxn(t));
		else
			top = top + 1;
		end
	end
	if t == nil or table.maxn(t) < 1 then
		return nil -- no result
	end
	if table.maxn(t) > 1 then
		return nil -- multi?
	end
	return t[1];
end
function expr(s, liberal)
--	print("in", s);
	s = s:gsub("([^0-9][0-9]+)h([0-9]+[^0-9])", "%1..%2") -- 1h2 -> 1..2
	s = s:gsub("%[p[0-9]+%]", function(s)
		s = s:gsub("[%[%]]","")
		if not _G[s] then
			return 0
		end
		return tostring(_G[s]:val())
	end) 
--	print("in2", s);

	local t = expr2rpn(s);
	local r = rpnexpr(t);
--	print("out", r);
	if is_range(r) then
		return op_range(r)
	end
	if r == nil then
		if DEBUG_MODE or not liberal then
			error ("Wrong expression:" .. s);
		else
			print ("Wrong expression:", s);
		end
		return (s);
	end
	local rr = tonumber(r)
	if not rr then
		if DEBUG_MODE or not liberal then
			error ("Wrong expression result:" .. tostring(r));
		else
			print ("Wrong expression result:", r);
		end
		return (r)
	end
	return rr
end

function next_day()
	CurTime = CurTime + 60 * 60 * 24;
end
--[[
t = expr2rpn ("(0=5) and (2>=1)");
for k in ipairs(t) do
	print(t[k]);
end
print (rpnexpr(t))
--]]
-- vim:ts=4
