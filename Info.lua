-- Info.lua

-- Implements the g_PluginInfo standard plugin description

g_PluginInfo =
{
	Name = "NCP",
	Version = "0.1",
	Description = [[Nikolauska Command Pack]],
	Commands =
	{
		["/delhome"] =
		{
			Permission = "es.home",
			HelpString = "Delete a home.",
			Handler = HandleDeleteHomeCommand,
			ParameterCombinations =
					{
						{
							Params = "HomeName",
							Help = "Deletes specifies home",
						}
					}
		},
		["/home"] =
		{
			Permission = "es.home",
			HelpString = "Teleport to your home.",
			Handler = HandleHomeCommand,
			ParameterCombinations =
					{
						{
							Params = "HomeName",
							Help = "teleports you to the specified home",
						}
					}
		},
		["/sethome"] =
		{
			Permission = "es.home",
			HelpString = "Set your home.",
			Handler = HandleSetHomeCommand,
			ParameterCombinations =
					{
						{
							Params = "HomeName",
							Help = "teleports you to the specified home",
						}
					}
		},
	},


	Permissions =
	{
		["es.home"] =
		{
			Description = "Allows players to use basic home commands.",
			RecommendedGroups = "mods, players",
		},
		["es.home.admin"] =
		{
			Description = "Allows admin mre advanced home commands.",
			RecommendedGroups = "admins",
		}
	}
}
