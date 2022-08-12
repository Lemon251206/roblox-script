--LocalServer
local replicated = game:GetService("ReplicatedStorage");
local workspace = game:GetService("Workspace");
local placeId = tonumber(game.PlaceId);

--LocalWorkspace
local units = workspace:WaitForChild("_UNITS");

--LocalPlayer
local player = game:GetService("Players").LocalPlayer;

--GlobalField
_G.WAVE = 0;

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
    ['blackbeard'] = '{e48173e6-8e76-4c64-bd25-da6e95d9f940}';
}

local units_location = {
    ["speedwagon"] = {
        {-2916.28125, 91.8062057, -718.249084},
        {-2918.28125, 91.8062057, -718.249084},
        {-2920.28125, 91.8062057, -718.249084};
    },
    ["dio"] = {
        {-2958.14355, 91.8062057, -703.298401},
        {-2955.81665, 91.8062057, -720.750732},
        {-2943.29541, 91.8062057, -703.704773};
    },
    ['jotaro'] = {},
    ["goku_black"] = {
        {-2947.66504, 94.4185944, -716.393005},
        {-2949.66504, 94.4185944, -716.393005},
        {-2951.66504, 94.4185944, -716.393005},
        {-2948.66504, 94.4185944, -718.393005},
        {-2950.66504, 94.4185944, -718.393005};
    },
    ["noro"] = {
        {-2955.81665, 91.8062057, -718.750732},
        {-2955.81665, 91.8062057, -722.750732},
        {-2957.81665, 91.8062057, -719.750732},
        {-2957.81665, 91.8062057, -721.750732},
        {-2959.81665, 91.8062057, -720.750732};
    },
    ['blackbeard'] = {
        {-2958.14355, 91.8062057, -705.298401},
        {-2943.29541, 91.8062057, -705.704773}
    }
}

local units_model = {
    ["speedwagon"] = {},
    ['dio'] = {};
    ["jotaro"] = {},
    ["goku_black"] = {},
    ["mihawk"] = {},
    ["noro"] = {},
    ['blackbeard'] = {};
}

local wave_function = {};

function join_lobby(lobby_id) -- lobby_id is String
    client_to_server.request_join_lobby:InvokeServer(lobby_id);
    message('join lobby [' .. lobby_id .. ']');
end;

function leave_lobby(lobby_id) -- lobby_id is String
    client_to_server.request_leave_lobby:InvokeServer(lobby_id);
    message('leave lobby [' .. lobby_id .. ']');
end;

function lock_level(lobby_id, map_id, difficult) -- lobby_id, map_id, difficult is String
    client_to_server.request_lock_level:InvokeServer(lobby_id, map_id, false, difficult);
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

function upgrade_unit(unit_name, array) -- unit_model is Model
    client_to_server.upgrade_unit_ingame:InvokeServer(units_model[unit_name][array]);
    message('upgrade unit [' .. unit_name .. ']');
    wait(0.075);
end;

function upgrades_unit(unit_name, array, count) 
    for i = 1, count, 1 do
        upgrade_unit(unit_name, array);
    end
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
    return player._stats.resource.Value;
end;

function getGems() 
    return player:WaitForChild("_stats").gem_amount.Value;
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
    for i,v in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
        v:Disable()
    end;
end;

function time()
    return tostring(os.date('%X', os.time()));
end;

function message(message)
    print('['..time()..']: '..message)
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
                '**Displayname:** ||'..player.Name..'||',
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
            wait(5);
            webhook('https://discord.com/api/webhooks/994515134380781668/dH6PDbmHltUeVnKJUVxoRJ2S2n0imhSMhO0ON1RGKtNrzycqdcRzo2OeeLKHuPRaoD79');
            wait(1);
            --back_to_lobby();
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
    wave_function['1'] = (function()
        spawn_unit("speedwagon", 1);
    end);
    wave_function['2'] = (function()
        spawn_unit("dio", 1);
        spawn_unit("speedwagon", 2);
        spawn_unit("speedwagon", 3);
    end);
    wave_function['3'] = (function()
        upgrade_unit("speedwagon", 1);
        upgrade_unit("speedwagon", 2);
        upgrade_unit("speedwagon", 3);
    end);
    wave_function['4'] = (function()
        upgrade_unit("dio", 1);
        upgrade_unit("speedwagon", 1);
        upgrade_unit("speedwagon", 2);
    end);
    wave_function['5'] = (function()
        upgrade_unit("speedwagon", 3);
        upgrade_unit("speedwagon", 1);
    end);
    wave_function['6'] = (function()
        upgrade_unit("dio", 1);
        upgrade_unit("speedwagon", 2);
        upgrade_unit("speedwagon", 3);
    end);
    wave_function['7'] = (function()
        upgrade_unit('speedwagon', 1);
        upgrade_unit('speedwagon', 2);
        upgrade_unit('speedwagon', 3);
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
    wave_function['25'] = (function()
        spawn_unit('goku_black', 1);
        spawn_unit('goku_black', 2);
        upgrades_unit('goku_black', 1, 7);
        upgrades_unit('goku_black', 2, 7);
    end);
    wave_function['26'] = (function()
        spawn_unit('goku_black', 3);
        upgrades_unit('goku_black', 3, 7);
    end);
    wave_function['28'] = (function()
        spawn_unit('goku_black', 4);
        upgrades_unit('goku_black', 4, 7);
    end);
    wave_function['32'] = (function()
        spawn_unit('goku_black', 5);
        upgrades_unit('goku_black', 5, 7);
    end);
    wave_function['38'] = (function()
        spawn_unit('blackbeard', 1);
        spawn_unit('blackbeard', 2);
        upgrades_unit('blackbeard', 1, 7);
        upgrades_unit('blackbeard', 2, 7);
    end);
end

local join = coroutine.create(function()
    message('lobby activated');
    wait(25);
    message('character loaded')
    join_lobby("_lobbytemplategreen13");
    wait(1);
    lock_level("_lobbytemplategreen13", "namek_infinite", "Hard");
    wait(0.1);
    start_game("_lobbytemplategreen13");
end)

local game = coroutine.create(function()
    message('game activated');
    load_function();
    wait_wave();
end)

spawn(function()
    if not isLoaded() then
        waitLoaded();
    end
    if placeId == place["lobby"] then
        coroutine.resume(join);
    elseif placeId == place["game"] then
        _G.Gems = getGems();
        _G.Timing = os.time();
        coroutine.resume(game);
    end
    anti_afk();
end)

units.ChildAdded:Connect(function(unit)
    for k, v in pairs (units_model) do
        if unit.Name == k then
            table.insert(units_model[k], unit);
        end;
    end;
end)

player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.InProgress then
        syn.queue_on_teleport([[
        repeat wait() until game:IsLoaded()
            wait(5);
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Lemon251206/roblox-script/main/anime-adventures.lua'))();
        ]])
    end
end)
