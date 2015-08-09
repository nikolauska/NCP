function HandleHomeCommand(a_Split, a_Player)
	if(#a_Split < 2) then
		local msg = g_DB:getHomes(a_Player);

		if(msg == "") then
			a_Player:SendMessageInfo("You have not set any homes!");
			return true;
		end

		msg = "Your homes:" .. msg;

		-- Remove last comma
		msg = msg:sub(1, -2)

		a_Player:SendMessageInfo(msg);
		return true;
	end

	g_DB:getHome(a_Split[2], a_Player, true);

	return true;
end

function HandleSetHomeCommand(a_Split, a_Player)
	if(#a_Split < 2) then
		a_Player:SendMessageInfo("Home name not defined!");
		a_Player:SendMessageInfo("Use /sethome <homename>");
		return true;
	end

	local hasHome = g_DB:getHome(a_Split[2], a_Player, false);

	if(not(hasHome)) then
		g_DB:setHome(a_Split[2], a_Player);
		a_Player:SendMessageInfo("Home '" .. a_Split[2] .. "' saved!");
		return true;
	end

	g_DB:updateHome(a_Split[2], a_Player);
	a_Player:SendMessageInfo("Home '" .. a_Split[2] .. "' updated!");
	return true;
end

function HandleDeleteHomeCommand(a_Split, a_Player)
	if(#a_Split < 2) then
		a_Player:SendMessageInfo("Home name not defined!");
		a_Player:SendMessageInfo("Use /delhome <homename>");
		return true;
	end

	local hasHome = g_DB:getHome(a_Split[2], a_Player, false);

	if(not(hasHome)) then
		a_Player:SendMessageInfo("Home '" .. a_Split[2] .. "' not found!");
		return true;
	end

	g_DB:deleteHome(a_Split[2], a_Player);
	a_Player:SendMessageInfo("Home '" .. a_Split[2] .. "' deleted!");
	return true;
end
