g_DB = nil;
g_SQL = {};

--Initialize the plugin
function Initialize(Plugin)

	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")

	RegisterPluginInfoCommands();
	--RegisterPluginInfoConsoleCommands();

	g_DB = SQLite_CreateStorage(Plugin:GetLocalFolder().."/data.sqlite");

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
	--Finish!
end
