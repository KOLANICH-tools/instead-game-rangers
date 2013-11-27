-- $Name:Космические рейнджеры$
-- $Version:1.8$

instead_version "1.4.4"
require "xact"
require "theme"
require "para"

if stead.version < "1.5.3" then
	walk = _G["goto"]
	walkin = goin
	walkout = goout
	walkback = goback
end

dofile "convert.lua"

function dogame(n)
	local f = here().games[n];
	if not f.ready and f.qm then
		convert(get_gamepath().."/games/"..f.qm, get_gamepath().."/games/"..f.name..".lua");
		f.ready = true
	end
	game.name = f.name
	local p = game.games_by_name[game.name:lower()].pics
	if p then
		_PICT_PATH='pics/'..p;
	end
	gamefile("games/"..f.name..".lua", true);
	game._piclive = 0
	game._picnr = 1
end

reload = xact("reload", function(s)
	here():scan()
	here():fill()
	game.pictures = {}
	scan_pictures();
	return true
end)

help = xact("help", function(s)
	walk 'helpr'
end)


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

game._picture = ''

function scan_pictures()
	local f,k
	game.pictures = {}

	if game.name then
		game.games_by_name = {}
		game.games_by_name[game.name:lower()] = {}
	end

	for f in stead.readdir(get_gamepath().."/pics") do
		if f ~= '.' and f ~= '..' then
			local low = f:lower()
			if game.games_by_name[low] then
				game.games_by_name[low].pics = f;
			elseif f:find("%.[a-zA-Z0-9]+$") then
				table.insert(game.pictures, f)
			end
		end
	end
	table.sort(game.pictures)
end

local function scan_game_pictures(name, path)
	local f,k,v
	if game.games_by_name[name:lower()].pictures then
		return
	end
	game.games_by_name[name:lower()].pictures = {};
	v = game.games_by_name[name:lower()].pictures;
	for f in stead.readdir(get_gamepath().."/pics/"..path) do
		if f ~= '.' and f ~= '..' then
			table.insert(v, f)
		end
	end
	table.sort(v)
end

game.pic = function(s)
	if theme:name() ~= '.' then
		return
	end

	if not game.pictures then
		scan_pictures();
	end

	if not player_moved() and game._picture then
		return game._picture..';mask.png@0,0'
	end

	if game._piclive and game._piclive > 0 and game._picture then
		game._piclive = game._piclive - 1 
		return game._picture..';mask.png@0,0'
	end

	local pics
	local pictures

	if game.name then
		pics = game.games_by_name[game.name:lower()].pics
	end

	local pic_path = 'pics/'
	if pics and not game.picture_map then
		scan_game_pictures(game.name, pics);
		pictures = game.games_by_name[game.name:lower()].pictures
		pic_path = pic_path..pics..'/';
	else
		pictures = game.pictures
		game._picnr = rnd(#pictures)
	end

	if #pictures == 0 then
		return
	end

	game._piclive = 5
	game._picture = pic_path..pictures[game._picnr];
	game._picnr = game._picnr + 1
	if game._picnr > #pictures then
		game._picnr = 1
	end
	return game._picture..';mask.png@0,0'
end

main = room {
	nam = 'Космические рейнджеры';
	forcedsc = true;
	var {
		games = {};
	};
	scan = function(s)
		local f
		s.games = {};
		local gm = {}
		for f in stead.readdir(get_gamepath().."/games") do
			if f:lower():find("%.lua$") or f:lower():find("%.qm$") then
				local ff = f:gsub("%.[^%.]+$","");
				local el				
				if not gm[ff:lower()] then
					el = { name = ff, ready = false }
				else
					el = gm[ff:lower()]
				end
				if f:find("%.lua$") then
					el.ready = true
				else
					el.qm = f;
				end
				if not gm[ff:lower()] then
					gm[ff:lower()] = el
					table.insert(s.games, el)
				end
			end
		end
		game.games_by_name = gm;
		table.sort(s.games, function(a, b)
			return a.name < b.name
		end)
	end;
	ini = function(s, load)
		if load then 
			s:scan()
			s:fill()
		end
	end;
	fill = function(s)
		local t = "<c>"..txtb("Выбор игры")..'^^';
		local k,v
		objs(s):zap();
		for k,v in ipairs(s.games) do
			local x = xact(tostring(k), function(s) dogame(k) end )
			x.save = function(s) return end
			if v.ready then
				t = t.."<u>{"..tostring(k).."|<w:"..tostring(v.name)..">}</u>^";
			else
				t = t.."{"..tostring(k).."|<w:"..tostring(v.name)..">}^";
			end
			put(x)
		end
		if #s.games == 0 then
			t = t.."В каталоге games нет .qm файлов^";
		end
		t = t.."^{help|Справка}";
		s._dsc = t.."^{reload|Перечитать}</c>";
		put(reload)
		put(help)
	end;
	enter = function(s)
		s:scan()
		s:fill()
	end;
	dsc = function(s)
		return s._dsc;
	end;
}
helpr = room {
	nam = 'Помощь';
	forcedsc = true;
	dsc = function(s)
		pn(txtb "1. Установка")
		pn()
		p [[Для установки игр, положите <b>.qm</b> файл в каталог <b>games</b>, который находится в директории <b>rangers</b>. То-есть игра должна находится в каталоге: <b>rangers/games</b>.
		У вас должны быть права на запись в этот каталог.^
		Затем, запустите в INSTEAD игру "Космические рейнджеры". Выйдете в меню и выберете пункт меню "Начать заново". 
		В списке на первом игровом экране появится название новой игры. Щелкните по названию, при этом произойдет конвертация в .lua и запуск игры.^
		Если в результате конвертации выдана ошибка "Wrong signature", откройте .qm файл в редакторе TGE и запишите его снова. Это поднимет версию игры до
		поддерживаемой.^
		Вы можете также использовать кнопку "Перечитать", при удалении/добавлении игр в формате .qm.]];
		pn()
		pn()
		pn(txtb "2. Графика")
		pn()
		p [[Вы можете добавлять в каталог <b>rangers/pics</b> графические файлы. Размер картинок должен быть 343x392. При этом, графика будет показана в игре.^
			Если вы хотите привязать картинки к конкретной игре, создайте каталог с именем игры в каталоге "pics" и поместите файлы туда. Например: "pics/prison".]];
		pn()
		pn()
		pn(txtb "3. Музыка")
		pn()
		p [[Вы можете добавлять музыкальные файлы в каталог "rangers/mus" и эти файлы будут проигрываться во время игры.]];
		pn()
		pn()
		pn(txtb "4. Где брать игры?")
		pn()
		p [[Вы можете скачать все квесты из первых КР вместе с редактором TGE с официального сайта: http://www.rangers.ru/files/tge2.exe.]];
		pn()
		pn()
		pn(txtr(txtem "http://instead.syscall.ru"))
		pn()
		p (txtc"{back|Назад}")
	end;
	obj = { xact('back', code [[ walk 'main' ]] ) };
}
