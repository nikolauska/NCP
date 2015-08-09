-- Implements the SQLite-backed database storage

--- The columns definition for the homes table
-- A lookup map of LowerCaseColumnName => {ColumnName, ColumnType} is added in the initialization
local g_HomesColumns =
{
	{"ID",      "INTEGER PRIMARY KEY AUTOINCREMENT"},
	{"name",    "TEXT"},     -- The name given to home
	{"world",   "TEXT"},     -- Name of the world where the area belongs
	{"player",  "TEXT"},     -- a_Player UUID (name if UUID is empty)
	{"locx",    "INTEGER"},  -- Location X
	{"locy",    "INTEGER"},  -- Location Y
	{"locz",    "INTEGER"}  -- Location Z
}

local g_BackColumns =
{
	{"ID",         "INTEGER PRIMARY KEY AUTOINCREMENT"},
	{"world",      "TEXT"},     -- Name of the world where the area belongs
	{"player",     "TEXT"},     -- a_Player UUID (name if UUID is empty)
	{"death_time", "INTEGER"},  -- Location X
	{"locx",       "INTEGER"},  -- Location X
	{"locy",       "INTEGER"},  -- Location Y
	{"locz",      "INTEGER"}  -- Location Z
}



function SQLite_CreateStorage(a_Params)
	DB = g_SQL;
	local DBFile = a_Params or "homes.sqlite";

	-- Open the DB:
	local ErrCode, ErrMsg;
	DB.DB, ErrCode, ErrMsg = sqlite3.open(DBFile);
	if (DB.DB == nil) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot open database \"" .. DBFile .. "\": " .. ErrMsg);
		error(ErrMsg);  -- Abort the plugin
	end

	if (
		not(DB:CreateDBTable("home", g_HomesColumns)) or
		not(DB:CreateDBTable("back", g_BackColumns))
	) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot create DB table!");
		error("Cannot create DB table!");
	end
	-- Returns the initialized database access object
	return DB;
end


--- Executes an SQL query on the SQLite DB
function g_SQL:DBExec(a_SQL, a_Callback, a_CallbackParam)
	assert(a_SQL ~= nil);

	local ErrCode = self.DB:exec(a_SQL, a_Callback, a_CallbackParam);
	if (ErrCode ~= sqlite3.OK) then
		LOGWARNING(PLUGIN_PREFIX .. "Error " .. ErrCode .. " (" .. self.DB:errmsg() ..
			") while processing SQL command >>" .. a_SQL .. "<<"
		);
		return false;
	end
	return true;
end

--- Executes the SQL statement, substituting "?" in the SQL with the specified params
-- Calls a_Callback for each row
-- The callback receives a dictionary table containing the row values (stmt:nrows())
-- Returns false and error message on failure, or true on success
function g_SQL:ExecuteStatement(a_SQL, a_Params, a_Callback)
	-- Check params:
	assert(type(a_SQL) == "string")
	assert((a_Params == nil) or (type(a_Params) == "table"))
	assert((a_Callback == nil) or (type(a_Callback) == "function"))

	local Stmt, ErrCode, ErrMsg = self.DB:prepare(a_SQL)
	if (Stmt == nil) then
		LOGWARNING("Cannot prepare SQL \"" .. a_SQL .. "\": " .. (ErrCode or "<unknown>") .. " (" .. (ErrMsg or "<no message>") .. ")")
		LOGWARNING("  Params = {" .. table.concat(a_Params, ", ") .. "}")
		return nil, (ErrMsg or "<no message")
	end
	if (a_Params ~= nil) then
		Stmt:bind_values(unpack(a_Params))
	end
	if (a_Callback == nil) then
		Stmt:step()
	else
		for v in Stmt:nrows() do
			a_Callback(v)
		end
	end
	Stmt:finalize()
	return true;
end

--- Creates the table of the specified name and columns[]
-- If the table exists, any columns missing are added; existing data is kept
-- a_Columns is an array of {ColumnName, ColumnType}, it will receive a map of LowerCaseColumnName => {ColumnName, ColumnType}
function g_SQL:CreateDBTable(a_TableName, a_Columns)
	assert(a_TableName ~= nil)
	assert(a_Columns ~= nil)
	assert(a_Columns[1])
	assert(a_Columns[1][1])

	-- Try to create the table first
	local ColumnDefs = {}
	for _, col in ipairs(a_Columns) do
		table.insert(ColumnDefs, col[1] .. " " .. (col[2] or ""))
	end
	local sql = "CREATE TABLE IF NOT EXISTS '" .. a_TableName .. "' ("
	sql = sql .. table.concat(ColumnDefs, ", ");
	sql = sql .. ")";
	if (not(self:DBExec(sql))) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot create DB Table " .. a_TableName);
		return false;
	end
	-- SQLite doesn't inform us if it created the table or not, so we have to continue anyway

	-- Add the map of LowerCaseColumnName => {ColumnName, ColumnType} to a_Columns:
	for _, col in ipairs(a_Columns) do
		a_Columns[string.lower(col[1])] = col
	end

	-- Check each column whether it exists
	-- Remove all the existing columns from a_Columns:
	local RemoveExistingColumnFromDef = function(UserData, NumCols, Values, Names)
		-- Remove the received column from a_Columns. Search for column name in the Names[] / Values[] pairs
		for i = 1, NumCols do
			if (Names[i] == "name") then
				local ColumnName = Values[i]:lower();
				-- Search the a_Columns if they have that column:
				for idx, col in ipairs(a_Columns) do
					if (ColumnName == col[1]:lower()) then
						table.remove(a_Columns, idx);
						break;
					end
				end  -- for col - a_Columns[]
			end
		end  -- for i - Names[] / Values[]
		return 0;
	end
	if (not(self:DBExec("PRAGMA table_info(" .. a_TableName .. ")", RemoveExistingColumnFromDef))) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot query DB table structure");
		return false;
	end

	-- Create the missing columns
	-- a_Columns now contains only those columns that are missing in the DB
	if (a_Columns[1]) then
		LOGINFO(PLUGIN_PREFIX .. "Database table \"" .. a_TableName .. "\" is missing " .. #a_Columns .. " columns, fixing now.");
		for _, col in ipairs(a_Columns) do
			if (not(self:DBExec("ALTER TABLE '" .. a_TableName .. "' ADD COLUMN " .. col[1] .. " " .. (col[2] or "")))) then
				LOGWARNING(PLUGIN_PREFIX .. "Cannot add DB table \"" .. a_TableName .. "\" column \"" .. col[1] .. "\"");
				return false;
			end
		end
		LOGINFO(PLUGIN_PREFIX .. "Database table \"" .. a_TableName .. "\" columns fixed.");
	end

	return true;
end
