--version: 0.2

--LocalServer
local replicated = game:GetService("ReplicatedStorage");
local workspace = game:GetService("Workspace");

local Players = game:GetService('Players');
local TeleportService = game:GetService('TeleportService');

--LocalWorkspace
local units = workspace:WaitForChild("_UNITS");

local lobbys = {
    '_lobbytemplategreen1',
    '_lobbytemplategreen2',
    '_lobbytemplategreen3',
    '_lobbytemplategreen4',
    '_lobbytemplategreen5',
    '_lobbytemplategreen6',
    '_lobbytemplategreen7',
    '_lobbytemplategreen8',
    '_lobbytemplategreen9',
    '_lobbytemplategreen10',
    '_lobbytemplategreen11',
    '_lobbytemplategreen12',
    '_lobbytemplategreen13';
};

local Maps = {
    'namek',
    'aot',
    'demonslayer',
    'naruto',
    'marineford',
    'tokyoghoul';
}

local MapTypes = {
    ['infinite'] = '_infinite',
    ['story'] = '_level_';
}

--GlobalField
_G.WAVE = 0;
_G.AutoRejoin = true;

--LocalEvent
local client_to_server = replicated.endpoints.client_to_server;

local place = {
    ["lobby"] = 8304191830,
    ["game"] = 8349889591;
}

local units_uuid = {
    ["speedwagon"] = "{11e83561-3a82-453b-a6e5-5390e472f0ed}",
    ['dio'] = '{085f7d1f-4d7a-4bd6-9a2d-296f81dde752}',
    ["jotaro"] = "{88939969-b711-4f61-80cc-dbbcc2b60e5e}",
    ["goku_black"] = "{9776ad79-29c7-4174-a0f0-e6109d19d06f}",
    ["todoroki"] = "{459570dd-e139-4ecd-a6bf-8dcbc853ec1e}",
    ["noro"] = "{3b080042-cc8c-4e46-92b7-817308429618}",
    ['blackbeard'] = '{e48173e6-8e76-4c64-bd25-da6e95d9f940}',
    ['erwin'] = '{e163720c-626c-4160-8018-9cf4843d8579}';
}

local units_location = {
    ["speedwagon"] = {},
    ["dio"] = {
        {-2958.14355, 91.8062057, -703.298401},
        {-2955.81665, 91.8062057, -720.750732},
        {-2943.29541, 91.8062057, -703.704773};
    },
    ['jotaro'] = {},
    ["goku_black"] = {},
    ["noro"] = {
        {-2955.81665, 91.8062057, -718.750732},
        {-2955.81665, 91.8062057, -722.750732},
        {-2957.81665, 91.8062057, -719.750732},
        {-2957.81665, 91.8062057, -721.750732},
        {-2959.81665, 91.8062057, -720.750732};
    },
    ['blackbeard'] = {},
    ['erwin'] = {};
}

local unit_models = {
    ['dio'] = {},
    ['erwin'] = {};
};

local wave_function = {};

function getPlayer()
    return Players.LocalPlayer;
end;

function getPlaceId()
    return game.PlaceId;
end;

function getMaps(id, types, level)
    if (types == 'infinite') then
        return tostring(Maps[id]..MapTypes[types]);
    end;
    if (level == nil) then 
        level = 1;
    elseif (level < 1) then
        level = 1;
    elseif (level > 6) then
        level = 6;
    end;
    return tostring(Maps[id]..MapTypes[types]..level);
end;

function join_lobby(id) -- id is Integer
    client_to_server.request_join_lobby:InvokeServer(lobbys[id]);
    if (getPlayer():WaitForChild('AlreadyInLobby').Value) then
        message('join lobby [' .. lobbys[id] .. ']');
    end;
    return lobbys[id];
end;

function join_lobby_random()
    local id = math.random(0, #lobbys);
    join_lobby(id);
    if (getLobbyOwner(id) ~= nil) then
        return join_lobby_random();
    end;
    return lobbys[id];
end;

function leave_lobby(id) -- lobby_id is String
    client_to_server.request_leave_lobby:InvokeServer(lobbys[id]);
    if not (isInLobby()) then
        message('leave lobby [' .. lobbys[id] .. ']');
    end;
end;

function lock_level(lobby_id, map_id, difficult) -- lobby_id, map_id, difficult is String
    client_to_server.request_lock_level:InvokeServer(lobby_id, map_id, true, difficult);
    message('select map [' .. map_id .. ']');
end;

function start_game(lobby_id) -- lobby_id is String value
    client_to_server.request_start_game:InvokeServer(lobby_id);
    message('start game');
end

function back_to_lobby()
    client_to_server.teleport_back_to_lobby:InvokeServer();
    message('teleport back to lobby');
    
end;

function spawn_unit(unit_name, number) -- lobby_id is String, location is CFrame
    client_to_server.spawn_unit:InvokeServer(units_uuid[unit_name], getLocationByArray(units_location[unit_name][number]));
    message('spawn unit [' .. unit_name .. ']');
    wait(0.075);
end;

function sell_units(unit_name, array)
    for i = 1, #array, 1 do
        client_to_server.sell_unit_ingame:InvokeServer(unit_models[unit_name][i]);
        message('sell units [' .. unit_name .. ']');
    end;
end;

function upgrade_unit(unit_name, array) -- unit_model is Model
    client_to_server.upgrade_unit_ingame:InvokeServer(unit_models[unit_name][array]);
    message('upgrade unit [' .. unit_name .. ']');
    wait(0.075);
end;

function upgrades_unit(unit_name, array, count)
    for i = 1, count, 1 do
        upgrade_unit(unit_name, array);
    end
end;

function isInLobby()
    return getPlayer():WaitForChild('AlreadyInLobby').Value;
end;

function getLobbyOwner(id)
    return tostring(workspace['_LOBBIES'].Story:FindFirstChild(lobbys[id]).Owner.Value);
end;

function getLocation(x, y, z)
    return CFrame.new(x, y, z, 1, 0, -0, -0, 1, -0, 0, 0, 1);
end;

function getLocationByArray(array)
    return CFrame.new(array[1], array[2], array[3], 1, 0, -0, -0, 1, -0, 0, 0, 1);
end;

function getWaves()
    return workspace:WaitForChild("_wave_num").Value;
end;

function getMoney()
    return getPlayer()._stats.resource.Value;
end;

function getGems() 
    return getPlayer():WaitForChild("_stats").gem_amount.Value;
end;

function getGemsReceived()
    return (tonumber(getGems()) - tonumber(_G.Gems));
end;

function Format(Int)
	return string.format("%02i", Int)
end;

function convertToHMS(seconds)
	local Minutes = (seconds - seconds%60)/60
	seconds = seconds - Minutes*60
	return Format(Minutes)..":"..Format(seconds)
end;

function getTotalTime()
    return convertToHMS(os.time() - _G.Timing);
end;

function isFinished()
    return workspace:WaitForChild("_DATA"):WaitForChild("GameFinished").Value;
end;

function isLoaded()
    return game:IsLoaded();
end;

function waitLoaded()
    return game.Loaded:Wait();
end;

function anti_afk()
    for i,v in pairs(getconnections(getPlayer().Idled)) do
        v:Disable()
    end;
end;

function time()
    return tostring(os.date('%X', os.time()));
end;

function message(message)
    print('['..time()..']: '..message)
end;

function onWaitCharacter()
    repeat wait() until getPlayer():HasAppearanceLoaded();
end;

function getMessage(array)
    local message = "";
    for i = 1,#array,1 do
        message = message..'\n'..array[i];
    end
    return message;
end;

function getEmbeds()
    embeded = {
    	--["content"] = "@everyone", -- pings user on discord
    	["embeds"] = {{
    		["title"] = "Anime Adventures [lemon]",
    		["description"] = getMessage({
                '**Displayname:** ||'..getPlayer().Name..'||',
                '**Gems received:** '..getGemsReceived(),
                '**Gems:** '..getGems(),
                '**Waves:**'..getWaves(),
                '',
                '**Total time:**'..getTotalTime();
            });
    		["color"] = 14400313;
    	}}
    }
    return embeded;
end

function webhook(url)
	syn.request({
		Url = url,
		Method = "POST",
		Headers = { ["Content-Type"] =  "application/json" },
		Body = game:GetService('HttpService'):JSONEncode(getEmbeds());
	})
end;

function wait_wave()
    while(wait(0.1)) do
        if isFinished() then
            wait(10);
            webhook('https://discord.com/api/webhooks/994515134380781668/dH6PDbmHltUeVnKJUVxoRJ2S2n0imhSMhO0ON1RGKtNrzycqdcRzo2OeeLKHuPRaoD79');
            wait(2.5);
            back_to_lobby();
            break;
        end
        if getWaves() == (_G.WAVE + 1) then
            local wave_action = wave_function[tostring(getWaves())];
            if (wave_action ~= nil) then
                spawn(wave_action);
            end;
            _G.WAVE = getWaves();
        end;
    end;
end;

function load_function() 
    wave_function['2'] = (function()
        spawn_unit("dio", 1);
    end);
    wave_function['4'] = (function()
        upgrade_unit("dio", 1);
    end);
    wave_function['6'] = (function()
        upgrade_unit("dio", 1);
    end);
    wave_function['8'] = (function()
        spawn_unit("dio", 2);
        upgrade_unit('dio', 1);
        upgrades_unit('dio', 2, 3);
    end);
    wave_function['10'] = (function()
        spawn_unit('noro', 1);
        upgrades_unit('noro', 1, 6);
    end);
    wave_function['12'] = (function()
        spawn_unit('noro', 2);
        upgrades_unit('noro', 2, 6);
    end);
    wave_function['13'] = (function()
        spawn_unit('noro', 3);
        upgrades_unit('noro', 3, 6);
    end);
    wave_function['15'] = (function()
        spawn_unit('noro', 4);
        upgrades_unit('noro', 4, 6);
    end);
    wave_function['16'] = (function()
        upgrades_unit('dio', 2, 3);
    end);
    wave_function['18'] = (function()
        spawn_unit('dio', 3);
        upgrades_unit('dio', 3, 3)
        spawn_unit('noro', 5);
        upgrades_unit('noro', 5, 6);
    end);
    wave_function['20'] = (function()
        for k, v in pairs (unit_models) do
            sell_units(k, v);
        end;
    end);
end

local join = coroutine.create(function()
    onWaitCharacter();
    message('Lobby: Character is loaded.');
    wait(1);
    local lobby = join_lobby_random();
    wait(1);
    lock_level(lobby, getMaps(1, 'infinite'), 'Hard');
    wait(0.1);
    start_game(lobby);
end)

local game = coroutine.create(function()
    onWaitCharacter();
    message('Game: Character is loaded.');
    load_function();
    wait_wave();
end)

spawn(function()
    if not isLoaded() then
        waitLoaded();
    end
    anti_afk();
    if getPlaceId() == place["lobby"] then
        coroutine.resume(join);
    elseif getPlaceId() == place["game"] then
        _G.Gems = getGems();
        _G.Timing = os.time();
        coroutine.resume(game);
    end
end);

units.ChildAdded:Connect(function(unit)
    local owner = tostring(unit:WaitForChild('_stats').player.Value);
    local name = tostring(unit.Name);
    if (unit.Name ~= 'aot_generic') then
        if (getPlayer().Name == owner) then
            if (unit_models[name] ~= nil) then
                table.insert(unit_models[name], unit);
            else
                unit_models[name] = {};
                table.insert(unit_models[name], unit);
            end;
        end;
    end;
end);

getPlayer().OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.InProgress then
        syn.queue_on_teleport([[
        repeat wait() until game:IsLoaded()
            wait(5);
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Lemon251206/roblox-script/main/anime-adventures.lua'))();
        ]])
    elseif state == Enum.TeleportState.Failed then
        wait(5);
        TeleportService:Teleport(getPlaceId());
    end
end);

Players.PlayerRemoving:Connect(function(player)
    if (_G.AutoRejoin) then
        if (player == getPlayer()) then
            TeleportService:Teleport(getPlaceId());
        end;
    end;
end);
