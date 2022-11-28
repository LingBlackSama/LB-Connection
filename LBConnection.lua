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
local InvokeRecieveRemote: RemoteEvent = script.InvokeRecieveRemote

local Server: boolean = RS2:IsServer()

local LBConnection: table = {};
local CallBackList: table = {};
local EventListenerList: table = {};

local function OneWay(Remote: RemoteEvent, plr: Player, ID: string|number, ExtraData: table)
    if Server then
        Remote:FireClient(plr, ID, unpack(ExtraData))
    else
        Remote:FireServer(ID, unpack(ExtraData))
    end
end

local function OneWayArray(Remote: RemoteEvent, Array: table, plr: Player, ID: string|number, ExtraData: table)
    if Server then
        for _, plr: Player in ipairs(Array) do
            Remote:FireClient(plr, ID, unpack(ExtraData))
        end
    else
        for _ in ipairs(Array) do
            Remote:FireServer(ID, unpack(ExtraData))
        end
    end
end

local function Invoke(Remote: RemoteEvent, plr: Player, ID: string|number, TimeOut: IntValue, ExtraData: table)
    local Thread: thread = coroutine.running()
    local UUID: GUID = Http:GenerateGUID(false)
    local Resume: boolean = false
    ExtraData = {UUID, unpack(ExtraData)}

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

    OneWay(Remote, plr, ID, ExtraData)

    return coroutine.yield()
end

local function ClientCallBackFunc(ID: string|number, ...: any)
    local CallBack: F = CallBackList[ID]
    if CallBack then
        CallBack(...)
    end
end

local function ServerCallBackFunc(plr: Player, ID: string|number, ...: any)
    local CallBack: F = CallBackList[ID]
    if CallBack then
        CallBack(...)
    end
end

local function InvokeRecieve(plr: Player, UUID: string, CallbackState: boolean, ...: any)
    local EventListener: F = EventListenerList[UUID]
    if not EventListener then return end
    EventListener(plr, CallbackState, ...)
end

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
    OneWay(SentRemote, plr, ID, {...})
end

-- Connection between (All Clients -> Server) and (Sever -> All Clients)
function LBConnection.FireAll(plr: Player, ID: string|number, ...: any)
    local PlayerList: table = Plr:GetPlayers()
    OneWayArray(SentRemote, PlayerList, plr, ID, {...})
end

-- One way connection in the radius [(Client(s) -> Server) or (Server -> Client(s))]
function LBConnection.FireDistance(plr: Player, ID: string|number, RenderDistance: IntValue, ...: any)
    local chr: Character = plr.Character or plr.CharacterAdded:Wait()
    RenderDistance = RenderDistance or 20
    local RenderPlayers: table = GetNearPlayer(chr, RenderDistance)
    OneWayArray(SentRemote, RenderPlayers, plr, ID, {...})
end

-- Connection between (Client -> Client) and (Server -> Server)
function LBConnection.FireBindable(plr: Player, ID: string|number, ...: any)
    OneWay(BindableSentRemote, plr, ID, {...})
end

-- Conection between (Client -> Server -> Client) and (Server -> Client -> Server)
function LBConnection.Invoke(plr: Player, ID: string|number, TimeOut: IntValue, ...: any): any
    return Invoke(InvokeSentRemote, plr, ID, TimeOut, {...})
end

-- Connection between (Client -> Client -> Client) and (Server -> Server -> Server)
function LBConnection.InvokeBindable(plr: Player, ID: string|number, TimeOut: IntValue, ...: any): any
    return Invoke(InvokeBindableSentRemote, plr, ID, TimeOut, {...})
end

-- Set up the callback
function LBConnection.CallBack(ID: string|number, CallBack: F)
    CallBackList[ID] = CallBack
end

-- Get the callback
function LBConnection.GetCallBack(ID: string|number): F
    return CallBackList[ID]
end

-- < Connections > --
if Server then
    SentRemote.OnServerEvent:Connect(ServerCallBackFunc)

    BindableSentRemote.OnServerEvent:Connect(function(plr: Player, ID: string|number, ...: any)
        BindableRecieveRemote:FireClient(plr, ID, ...)
    end)

    BindableRecieveRemote.OnServerEvent:Connect(ServerCallBackFunc)

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
			InvokeRecieveRemote:FireClient(plr, plr, UUID, true, CallBack(...))
		else
			InvokeRecieveRemote:FireClient(plr, plr, UUID, false)
		end
    end)

    InvokeRecieveRemote.OnServerEvent:Connect(InvokeRecieve)
else
    SentRemote.OnClientEvent:Connect(ClientCallBackFunc)

    BindableSentRemote.OnClientEvent:Connect(function(ID: string|number, ...: any)
        BindableRecieveRemote:FireServer(ID, ...)
    end)

    BindableRecieveRemote.OnClientEvent:Connect(ClientCallBackFunc)

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
			InvokeRecieveRemote:FireServer(UUID, true, CallBack(...))
		else
			InvokeRecieveRemote:FireServer(UUID, false)
		end
    end)

    InvokeRecieveRemote.OnClientEvent:Connect(InvokeRecieve)
end

return LBConnection
