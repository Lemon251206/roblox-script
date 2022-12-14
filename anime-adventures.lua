--version: 0.12

--LocalServer
local replicated = game:GetService("ReplicatedStorage");
local workspace = game:GetService("Workspace");
local NetworkClient = game:GetService('NetworkClient');
local VirtualUser = game:GetService('VirtualUser');

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

local erwins = {};

--GlobalField
_G.WAVE = 0;
_G.AutoRejoin = true;
_G.AutoErwin = true;
_G.Anti_AFK = true;
_G.execute = false;

--LocalEvent
local client_to_server = replicated.endpoints.client_to_server;

local places = {
    ["lobby"] = 8304191830,
    ["game"] = 8349889591;
}

local jobId = {
    ['lobby'] = '94a95497-3924-24f2-b678-593745363268',
    ['game'] = '';
};

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
    ['blackbeard'] = {},
    ['erwin'] = {
        {-2953.46826, 95.7148895, -721.355835},
        {-2953.46826, 95.7148895, -719.355835},
        {-2953.46826, 95.7148895, -723.355835}
    };
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
    local id = math.random(1, #lobbys);
    if (getLobbyOwner(id) ~= 'nil') then
        wait(0.5);
        return join_lobby_random();
    end;
    join_lobby(id);
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
    message('select map [map:' .. map_id .. ', lobby: '.. lobby_id ..']');
end;

function start_game(lobby_id) -- lobby_id is String value
    client_to_server.request_start_game:InvokeServer(lobby_id);
    message('start game [lobby: '.. lobby_id ..']' );
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

function vote_start()
    client_to_server.vote_start:InvokeServer();
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
    return getPlayer():WaitForChild('_stats').infinite_claimed_gems.Value;
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

function time()
    return tostring(os.date('%X', os.time()));
end;

function message(message)
    print('['..time()..']: '..message)
end;

function auto_erwin()
    if (#erwins >= 2) then
        if (erwins[1]['model']:FindFirstChild('_stats').upgrade.Value >= 3) and (erwins[2]['model']:FindFirstChild('_stats').upgrade.Value >= 3) then
            if ((erwins[1]['cooldown']+100) < os.time()) and ((erwins[1]['cooldown']+100) < os.time()) then
                use_active_attack(erwins[1]['model']);
                erwins[1]['cooldown'] = (os.time() + 42);
                erwins[2]['cooldown'] = (os.time() + 21);
                print('auto-erwin_start');
                return;
            end;
            if (erwins[1]['cooldown'] <= os.time()) then
                use_active_attack(erwins[1]['model']);
                erwins[1]['cooldown'] = (os.time() + 42);
                erwins[2]['cooldown'] = (os.time() + 21);
                print('auto-erwin_1');
            elseif (erwins[2]['cooldown'] <= os.time()) then
                use_active_attack(erwins[2]['model']);
                erwins[2]['cooldown'] = (os.time() + 42);
                erwins[1]['cooldown'] = (os.time() + 21);
                print('auto-erwin_2');
            end;
        end;
    end;
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

function teleport(id)
    TeleportService:Teleport(places[id], player);
end;

function rejoin()
    player:Kick('LemonProject: rejoin');
end;

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
            wait(1);
            webhook('https://discord.com/api/webhooks/1016379765848019054/vBl-YeRN7iGg6PeH64J5UWciVtL2fVi3YGYAqzIlPB0pKZT6MvFlEmmwEFecz0_34uBv');
            teleport('lobby');
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
    wave_function['2'] = function()
        spawn_unit('erwin', 1);
        spawn_unit('erwin', 2);
        spawn_unit('erwin', 3);
    end;
    wave_function['5'] = function()
        upgrade_unit('erwin', 1);
        upgrade_unit('erwin', 2);
        upgrade_unit('erwin', 3);
    end;
    wave_function['8'] = function()
        upgrades_unit('erwin', 1, 2);
        upgrades_unit('erwin', 2, 2);
        upgrades_unit('erwin', 3, 2);
    end;
    wave_function['15'] = function()
        upgrade_unit('erwin', 1);
        upgrade_unit('erwin', 2);
        upgrade_unit('erwin', 3);
    end;
    wave_function['18'] = function()
        upgrade_unit('erwin', 1);
        upgrade_unit('erwin', 2);
        upgrade_unit('erwin', 3);
    end;
    wave_function['21'] = function()
        wait(1);
        webhook('https://discord.com/api/webhooks/1016379765848019054/vBl-YeRN7iGg6PeH64J5UWciVtL2fVi3YGYAqzIlPB0pKZT6MvFlEmmwEFecz0_34uBv');
        teleport('lobby');
    end;
end

local join = coroutine.create(function()
    onWaitCharacter();
    message('Lobby: Character is loaded.');
    wait(1);
    local lobby = join_lobby_random();
    wait(0.5);
    lock_level(lobby, getMaps(1, 'infinite'), 'Hard');
    wait(0.1);
    start_game(lobby);
end)

local game = coroutine.create(function()
    onWaitCharacter();
    message('Game: Character is loaded.');
    load_function();
    wait_wave();
    print(_G.execute);
end)

spawn(function()
    if not isLoaded() then
        waitLoaded();
    end
    anti_afk();
    if getPlaceId() == places["lobby"] then
        coroutine.resume(join);
    elseif getPlaceId() == places["game"] then
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
        TeleportService:Teleport(places['lobby'], player);
    end;
end);

NetworkClient.ChildRemoved:Connect(function()
    TeleportService:Teleport(places['lobby'], player);
end);

function anti_afk()
    for i,v in pairs(getconnections(getPlayer().Idled)) do
        v:Disable()
    end;
end;

getPlayer().Idled:connect(function()
    if (_G.Anti_AFK) then
        VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end;
end);
