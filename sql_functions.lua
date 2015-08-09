
function g_SQL:getName(a_Player)
    local a_PlayerName = a_Player:GetUUID();
    if(a_PlayerName == "") then
        return a_Player:GetName();
    end
    return a_PlayerName
end

function g_SQL:getHome(a_HomeName, a_Player, a_Teleport)
	local hasHome = false;
	local playerWorld = a_Player:GetWorld():GetName();
    self:ExecuteStatement(
    "SELECT * FROM home WHERE name = ? AND player = ?",
    {
      a_HomeName,
      self:getName(a_Player)
  	},
	function(home)
		hasHome = true;

		if a_Teleport then
			if playerWorld == home.world then
				a_Player:TeleportToCoords(home.locx, home.locy, home.locz);
            else
                a_Player:MoveToWorld(home.world);
                a_Player:TeleportToCoords(home.locx, home.locy, home.locz);
			end
		end
	end)

	if a_Teleport and not(hasHome) then
		a_Player:SendMessageInfo("Home '" .. a_HomeName .. "' not found!");
	end

	return hasHome;
end

function g_SQL:getHomes(a_Player)
	msg = "";
    self:ExecuteStatement("SELECT * FROM home WHERE player = ?", {self:getName(a_Player)},
	function(home)
		msg = msg .. " " .. home.name .. ",";
	end);

	return msg;
end

function g_SQL:setHome(a_HomeName, a_Player)
    return self:ExecuteStatement(
    "INSERT INTO home (name, world, player, locx, locy, locz) VALUES (?, ?, ?, ?, ?, ?)",
    {
      a_HomeName,
      a_Player:GetWorld():GetName(),
	  self:getName(a_Player),
      a_Player:GetPosX(),
      a_Player:GetPosY(),
      a_Player:GetPosZ()
    });
end

function g_SQL:updateHome(a_HomeName, a_Player)
    return self:ExecuteStatement(
    "UPDATE home SET world = ?, locx = ?, locy = ?, locz = ? WHERE name = ? AND player = ?",
    {
      a_Player:GetWorld():GetName(),
      a_Player:GetPosX(),
      a_Player:GetPosY(),
      a_Player:GetPosZ(),
      a_HomeName,
      self:getName(a_Player)
    })
end

function g_SQL:deleteHome(a_HomeName, a_Player)
    return self:ExecuteStatement(
    "DELETE FROM home WHERE name = ? AND player = ?",
    {
      a_HomeName,
      self:getName(a_Player)
    })
end
