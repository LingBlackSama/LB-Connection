-- // FileName: LBConnection.lua
-- // Written by: LingBlack87661
-- // Description: Connections between client and server.

-- < Services > --
local Plr: Players = game:GetService("Players")
local RS2: RunService = game:GetService("RunService")
local Http: HttpService = game:GetService("HttpService")

-- < Variables > --
local SentRemote: RemoteEvent = script.SentRemote
local BindableSentRemote: RemoteEvent = script.BindableSentRemote
local BindableRecieveRemote: RemoteEvent = script.BindableRecieveRemote
local InvokeBindableSentRemote: RemoteEvent = script.InvokeBindableSentRemote
local InvokeBindableRecieveRemote: RemoteEvent = script.InvokeBindableRecieveRemote
local InvokeSentRemote: RemoteEvent = script.InvokeSentRemote
local InvokeRecieveRenmote: RemoteEvent = script.InvokeRecieveRenmote

local Server: boolean = RS2:IsServer()

local LBConnection: table = {};
local CallBackList: table = {};
local EventListenerList: table = {};

local function GetNearPlayer(chr: Charatcer, Radius: IntValue): table
    local ListOfPlayersInRange: table = {};
	local PlayerList: table = Plr:GetPlayers()
	local hrp: HumanoidRootPart = chr.HumanoidRootPart

	for _, plr in ipairs(PlayerList) do
		local Chr: Character = plr.Character or plr.CharacterAdded:Wait()
		local Hrp: HumanoidRootPart = Chr.HumanoidRootPart

		if chr and Chr and hrp and Hrp then
			if (Hrp.Position - hrp.Position).Magnitude <= Radius and Chr then
				ListOfPlayersInRange[#ListOfPlayersInRange + 1] = plr
			end
		end
	end
	return ListOfPlayersInRange
end

-- One way connection (Client <-> Server)
function LBConnection.Fire(plr: Player, ID: string|number, ...: any)
    if Server then
        SentRemote:FireClient(plr, ID, ...)
    else
        SentRemote:FireServer(ID, ...)
    end
end

-- One way connection to all clients
function LBConnection.FireAllClient(ID: string|number, ...: any)
    local PlayerList: table = Plr:GetPlayers()
    for _, plr in pairs(PlayerList) do
        SentRemote:FireClient(plr, ID, ...)
    end
end

-- One way connection to all clients in the radius
function LBConnection.FireDistance(plr: Player, ID: string|number, RenderDistance: IntValue, ...: any)
    local chr: Character = plr.Character or plr.CharacterAdded:Wait()
    RenderDistance = RenderDistance or 20
    local RenderPlayers: table = GetNearPlayer(chr, RenderDistance)

    for _, plr in pairs(RenderPlayers) do
        SentRemote:FireClient(plr, ID, ...)
    end
end

-- Connection between (Client -> Client) and (Server -> Server)
function LBConnection.FireBindable(plr: Player, ID: string|number, ...: any)
    if Server then
        BindableSentRemote:FireClient(plr, ID, ...)
    else
        BindableSentRemote:FireServer(ID, ...)
    end
end

-- Connection between (Client -> Client -> Client) and (Server -> Server -> Server)
function LBConnection.InvokeBindable(plr: Player, ID: string|number, TimeOut: IntValue, ...: any): any
    local Thread: thread = coroutine.running()
    local UUID: GUID = Http:GenerateGUID(false)
    local Resume: boolean = false

    EventListenerList[UUID] = function(PlayerWhoFired: Player, CallbackState: boolean, ...: any)
        if PlayerWhoFired ~= plr then return end
        Resume = true
        EventListenerList[UUID] = nil
        if CallbackState then
            task.spawn(Thread, true, ...)
        else
            task.spawn(Thread, false)
        end
    end

    task.delay(TimeOut, function()
        if Resume then return end
        EventListenerList[UUID] = nil
        task.spawn(Thread, false)
    end)

    if Server then
        InvokeBindableSentRemote:FireClient(plr, ID, UUID, ...)
    else
        InvokeBindableSentRemote:FireServer(ID, UUID, ...)
    end

    return coroutine.yield()
end

-- Conection between (Client -> Server -> Client) and (Server -> Client -> Server)
function LBConnection.Invoke(plr: Player, ID: string|number, TimeOut: IntValue, ...: any): any
    local Thread: thread = coroutine.running()
    local UUID: GUID = Http:GenerateGUID(false)
    local Resume: boolean = false

    EventListenerList[UUID] = function(PlayerWhoFired: Player, CallbackState: boolean, ...: any)
        if PlayerWhoFired ~= plr then return end
        Resume = true
        EventListenerList[UUID] = nil
        if CallbackState then
            task.spawn(Thread, true, ...)
        else
            task.spawn(Thread, false)
        end
    end

    task.delay(TimeOut, function()
        if Resume then return end
        EventListenerList[UUID] = nil
        task.spawn(Thread, false)
    end)

    if Server then
        InvokeSentRemote:FireClient(plr, ID, UUID, ...)
    else
        InvokeSentRemote:FireServer(ID, UUID, ...)
    end

    return coroutine.yield()
end

-- Set up the callback
function LBConnection.CallBack(ID: string, CallBack: F)
    CallBackList[ID] = CallBack
end

-- Get the callback
function LBConnection.GetCallBack(ID: string): F
    return CallBackList[ID]
end

-- < Connections > --
if Server then
    SentRemote.OnServerEvent:Connect(function(plr: Player, ID: string|number, ...: any)
        local CallBack: F = CallBackList[ID]
        if CallBack then
            CallBack(...)
        end
    end)

    BindableSentRemote.OnServerEvent:Connect(function(plr: Player, ID: string|number, ...: any)
        BindableRecieveRemote:FireClient(plr, ID, ...)
    end)

    BindableRecieveRemote.OnServerEvent:Connect(function(plr: Player, ID: string|number, ...: any)
        local CallBack: F = CallBackList[ID]
        if CallBack then
            CallBack(...)
        end
    end)

    InvokeBindableSentRemote.OnServerEvent:Connect(function(plr: Player, ID: string|number, UUID: string, ...: any)
        InvokeBindableRecieveRemote:FireClient(plr, plr, ID, UUID, ...)
    end)

    InvokeBindableRecieveRemote.OnServerEvent:Connect(function(plr: Player, ID: string|number, UUID: string, ...: any)
        local CallBack: F = CallBackList[ID]
        local EventListener: F = EventListenerList[UUID]
        if CallBack and EventListener then
            EventListener(plr, true, CallBack(...))
        else
            EventListener(plr, false)
        end
    end)

    InvokeSentRemote.OnServerEvent:Connect(function(plr: Player, ID: string|number, UUID: string, ...: any)
        local CallBack: F = CallBackList[ID]
		if CallBack then
			InvokeRecieveRenmote:FireClient(plr, plr, UUID, true, CallBack(...))
		else
			InvokeRecieveRenmote:FireClient(plr, plr, UUID, false)
		end
    end)

    InvokeRecieveRenmote.OnServerEvent:Connect(function(plr: Player, UUID: string, CallbackState: boolean, ...: any)
		local EventListener: F = EventListenerList[UUID]
		if not EventListener then return end
		EventListener(plr, CallbackState, ...)
	end)
else
    SentRemote.OnClientEvent:Connect(function(ID: string|number, ...: any)
        local CallBack: F = CallBackList[ID]
        if CallBack then
            CallBack(...)
        end
    end)

    BindableSentRemote.OnClientEvent:Connect(function(ID: string|number, ...: any)
        BindableRecieveRemote:FireServer(ID, ...)
    end)

    BindableRecieveRemote.OnClientEvent:Connect(function(ID: string|number, ...: any)
        local CallBack: F = CallBackList[ID]
        if CallBack then
            CallBack(...)
        end
    end)

    InvokeBindableSentRemote.OnClientEvent:Connect(function(ID: string|number, UUID: string, ...: any)
        InvokeBindableRecieveRemote:FireServer(ID, UUID, ...)
    end)

    InvokeBindableRecieveRemote.OnClientEvent:Connect(function(plr: Player, ID: string|number, UUID: string, ...: any)
        local CallBack: F = CallBackList[ID]
        local EventListener: F = EventListenerList[UUID]
        if CallBack and EventListener then
            EventListener(plr, true, CallBack(...))
        else
            EventListener(plr, false)
        end
    end)

    InvokeSentRemote.OnClientEvent:Connect(function(ID: string|number, UUID: string, ...: any)
        local CallBack: F = CallBackList[ID]
		if CallBack then
			InvokeRecieveRenmote:FireServer(UUID, true, CallBack(...))
		else
			InvokeRecieveRenmote:FireServer(UUID, false)
		end
    end)

    InvokeRecieveRenmote.OnClientEvent:Connect(function(plr: Player, UUID: string, CallbackState: boolean, ...: any)
		local EventListener: F = EventListenerList[UUID]
		if not EventListener then return end
		EventListener(plr, CallbackState, ...)
	end)
end

return LBConnection
