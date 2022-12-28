--!strict
-- // FileName: LBConnection.lua
-- // Written by: LingBlack87661
-- // Description: Connections between client and server.

-- // Services
local Plr = game:GetService("Players");
local RS2 = game:GetService("RunService");
local Http = game:GetService("HttpService");

-- // Variables
local SentRemote: RemoteEvent = script.SentRemote;
local InvokeSentRemote: RemoteEvent = script.InvokeSentRemote;
local InvokeRecieveRemote: RemoteEvent = script.InvokeRecieveRemote;

local Server: boolean = RS2:IsServer();

local LBConnection: any = {
    WaitForCallBack = false,
    WaitForCallBackDuration = 1,
};
local CallBackList: any = {};
local EventListenerList: any = {};

-- // Strings
local LBConnectionStr: string = "LB Connection: "
local WaitingForStr: string = "Waiting for ";
local CallBackStr: string = " CallBack";

local function OneWay(Remote: RemoteEvent, plr: any, ID: string|number, ExtraData: {})
    if Server then
        Remote:FireClient(plr, ID, unpack(ExtraData));
    else
        Remote:FireServer(ID, unpack(ExtraData));
    end
end

local function OneWayArray(Remote: RemoteEvent, Array: {}, ID: string|number, ExtraData: {})
    if Server then
        for _: number, plr: Player in ipairs(Array) do
            Remote:FireClient(plr, ID, unpack(ExtraData));
        end
    else
        for _: number in ipairs(Array) do
            Remote:FireServer(ID, unpack(ExtraData));
        end
    end
end

local function Invoke(Remote: RemoteEvent, plr: Player, ID: string|number, TimeOut: number, ExtraData: any)
    local Thread: thread = coroutine.running();
    local UUID: string = Http:GenerateGUID(false);
    local Resume: boolean = false;
    ExtraData = {UUID, unpack(ExtraData)};

    EventListenerList[UUID] = function(PlayerWhoFired: Player, CallbackState: boolean, ...: any)
        if PlayerWhoFired ~= plr then return end;
        Resume = true;
        EventListenerList[UUID] = nil;
        if CallbackState then
            task.spawn(Thread, true, ...);
        else
            task.spawn(Thread, false);
        end
    end

    task.delay(TimeOut, function()
        if Resume then return end;
        EventListenerList[UUID] = nil;
        task.spawn(Thread, false);
    end)

    OneWay(Remote, plr, ID, ExtraData);

    return coroutine.yield();
end

local function ClientCallBackFunc(ID: string|number, ...: any): any
    local CallBack: any = LBConnection:GetCallBack(ID);
    if CallBack then
        return CallBack(...);
    end
    return
end

local function ServerCallBackFunc(plr: Player, ID: string|number, ...: any)
    local CallBack: any = LBConnection:GetCallBack(ID);
    if CallBack then
        CallBack(...);
    end
end

local function InvokeRecieve(plr: Player, UUID: string, CallbackState: boolean, ...: any)
    local EventListener: any = EventListenerList[UUID];
    if not EventListener then return end;
    EventListener(plr, CallbackState, ...);
end

local function GetNearPlayer(chr: any, Radius: number): {Player}
    local ListOfPlayersInRange: any = {};
	local PlayerList: any = Plr:GetPlayers();
	local hrp: any = chr.HumanoidRootPart;

	for _: number, plr: any in ipairs(PlayerList) do
		local Chr: any = plr.Character or plr.CharacterAdded:Wait();
		local Hrp: any = Chr.HumanoidRootPart;

		if chr and Chr and hrp and Hrp then
			if (Hrp.Position - hrp.Position).Magnitude <= Radius and Chr then
				ListOfPlayersInRange[#ListOfPlayersInRange + 1] = plr;
			end
		end
	end
	return ListOfPlayersInRange;
end

-- // One way connection (Client <-> Server)
function LBConnection.Fire(plr: Player, ID: string|number, ...: any)
    OneWay(SentRemote, plr, ID, {...});
end

-- // Connection between (All Clients -> Server) and (Server -> All Clients)
function LBConnection.FireAll(ID: string|number, ...: any)
    local PlayerList: {Player} = Plr:GetPlayers();
    OneWayArray(SentRemote, PlayerList, ID, {...});
end

-- // Connection between (All Clients -> Server) and (Server -> All Clients)
function LBConnection.FireAllExcept(ID: string|number, ExceptionArray: {Player}, ...: any)
    local PlayerList: {Player} = Plr:GetPlayers();
    for _: number, Exceptionalplr: Player in ipairs(ExceptionArray) do
		if not table.find(PlayerList, Exceptionalplr) then return end
		table.remove(PlayerList, table.find(PlayerList, Exceptionalplr))
	end
    OneWayArray(SentRemote, PlayerList, ID, {...});
end

-- // One way connection in the radius [(Client(s) -> Server) or (Server -> Client(s))]
function LBConnection.FireDistance(plr: Player, ID: string|number, RenderDistance: number, ...: any)
    local chr: any = plr.Character or plr.CharacterAdded:Wait();
    RenderDistance = RenderDistance or 20;
    local RenderPlayers: {Player} = GetNearPlayer(chr, RenderDistance);
    OneWayArray(SentRemote, RenderPlayers, ID, {...});
end

-- // Connection between (Client -> Client) and (Server -> Server)
function LBConnection.FireBindable(ID: string|number, ...: any)
    return ClientCallBackFunc(ID, ...);
end

-- // Conection between (Client -> Server -> Client) and (Server -> Client -> Server)
function LBConnection.Invoke(plr: Player, ID: string|number, TimeOut: number, ...: any): any
    return Invoke(InvokeSentRemote, plr, ID, TimeOut, {...});
end

-- // Set up the callback
function LBConnection.CallBack(ID: string|number, CallBack: any)
    CallBackList[ID] = CallBack;
end

-- // Get the callback
function LBConnection:GetCallBack(ID: string|number): any
    if not self.WaitForCallBack then return CallBackList[ID] end
    if not CallBackList[ID] then
        repeat task.wait(self.WaitForCallBackDuration)
            warn(LBConnectionStr..WaitingForStr..tostring(ID)..CallBackStr)
        until CallBackList[ID]
    end
    return CallBackList[ID]
end

-- // Connections
if Server then
    SentRemote.OnServerEvent:Connect(ServerCallBackFunc);

    InvokeSentRemote.OnServerEvent:Connect(function(plr: Player, ID: string|number, UUID: string, ...: any)
        local CallBack: any = LBConnection:GetCallBack(ID);
		if CallBack then
			InvokeRecieveRemote:FireClient(plr, plr, UUID, true, CallBack(...));
		else
			InvokeRecieveRemote:FireClient(plr, plr, UUID, false);
		end
    end)

    InvokeRecieveRemote.OnServerEvent:Connect(InvokeRecieve);
else
    SentRemote.OnClientEvent:Connect(ClientCallBackFunc);

    InvokeSentRemote.OnClientEvent:Connect(function(ID: string|number, UUID: string, ...: any)
        local CallBack: any = LBConnection:GetCallBack(ID);
		if CallBack then
			InvokeRecieveRemote:FireServer(UUID, true, CallBack(...));
		else
			InvokeRecieveRemote:FireServer(UUID, false);
		end
    end)

    InvokeRecieveRemote.OnClientEvent:Connect(InvokeRecieve);
end

return LBConnection;
