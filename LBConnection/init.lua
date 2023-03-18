--!strict
-- // FileName: LBConnection.lua
-- // Written by: LingBlack87661
-- // Description: Connections between client and server.

-- // Services
local Plr = game:GetService("Players");
local RS2 = game:GetService("RunService");

-- // Variables
type Request = {Remote: RemoteEvent, Data: {any}};
type CallBack = (any) -> any;
type RemoteEventInfo = {RateLimit: number?, RateLimitTime: number?};
type RemoteFunctionInfo = {TimeOut: number?, RateLimit: number?, RateLimitTime: number?};
type BindableInfo = RemoteFunctionInfo;
type CallBackList = {[string|number]: any};

type LBRemote = {
	_Name: string,
	_Remote: nil|RemoteEvent,
	Fire: (any) -> (),
	FireTo: ({Player}, any) -> (),
	FireAll: (any) -> (),
	FireAllExcept: ({Player}, any) -> (),
	FireDistance: (Player, number, any) -> (),
	CallBack: (CallBack) -> CallBack,
	Once: (CallBack) -> CallBack,
	GetCallBack: () -> CallBack,
	Set: ({[string]: any}) -> (),
};

type LBRemoteFunction = {
	_Name: string,
	_TimeOut: number,
	_Sent: nil|RemoteEvent,
	_Receive: nil|RemoteEvent,
	Invoke: (Player, any) -> (boolean, any?),
	InvokeCallBack: ((any) -> any) -> (((any) -> any)),
	GetInvokeCallBack: () -> ((any) -> any),
	Set: ({[string]: any}) -> (),
};

type LBBindable = {
	_Name: string,
	_TimeOut: number,
	_Receive: nil|(any) -> (boolean, any?),
	Fire: (any) -> (),
	Invoke: (any) -> (boolean, any?),
	CallBack: ((any) -> any) -> ((any) -> any),
	InvokeCallBack: ((any) -> any) -> ((any) -> any),
	GetCallBack: () -> ((any) -> any),
	GetInvokeCallBack: () -> ((any) -> any),
	Set: ({[string]: any}) -> (),
};

local RemotesFolder: any = script.Remotes;
local RemoteConnection: RemoteEvent = script.RemoteConnection;

local RNG: Random = Random.new();

-- // Booleans
local IsServer: boolean = RS2:IsServer();

local LBConnection: any = {
	LBRemotes = {}::{[string]: LBRemote};
	LBRemoteFunctions = {}::{[string]: LBRemoteFunction};
	LBBindables = {}::{[string]: LBBindable};
};
local RequestsList: {Request} = {};
local FireAllRequestsList: {Request} = {};
local RemoteEventsCallBackList: CallBackList = {};
local RemoteFunctionsCallBackList: CallBackList = {};
local BindableEventsCallBackList: CallBackList = {};
local BindableFunctionsCallBackList: CallBackList = {};

local function CreateInstance(InstanceName: string, Parent: any, Information: {[string]: any}): any
	local NewInstance: any = Instance.new(InstanceName);
	if (Information) then
		for Property: string, Value: any in next, Information do
			NewInstance[Property] = Value;
		end
	end
	NewInstance.Parent = Parent;
	return NewInstance;
end

local function CreateRemoteEvent(Name: string, Parent: any): RemoteEvent
	return CreateInstance("RemoteEvent", Parent, {Name = Name});
end

local function CreateRemoteFunction(Name: string): Folder
	local Folder: Folder = CreateInstance("Folder", RemotesFolder, {Name = Name});
	CreateRemoteEvent("Sent", Folder);
	CreateRemoteEvent("Receive", Folder);
	return Folder;
end

local function CreateObject(Name: string, Info: {RateLimit: number?, RateLimitTime: number?})
	return {
		_Name = Name,
		_Rate = 0,
		_RateLimitStart = false,
		_RateLimitReach = false,
		RateLimit = Info.RateLimit or 60,
		RateLimitTime = Info.RateLimitTime or 1,
	};
end

local function YieldTilObject(Name: string, List: {})
	local Count: number = 0;
	while (not List[Name]) do
		if Count ~= 500 then
			Count += 1;
			warn(string.format("LB Connection: Waiting for %s to load...", Name));
			task.wait();
		else
			warn("Timeout: "..Name)
			break;
		end
	end
end

local function GenerateNumbers(): number
	return RNG:NextInteger(0, 65535);
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


local function _Fire(Remote: RemoteEvent, ...: any)
	table.insert(RequestsList, {
		Remote = Remote,
		Data = {...},
	});
end

local function _FireAll(Remote: RemoteEvent, ...: any)
	table.insert(FireAllRequestsList, {
		Remote = Remote,
		Data = {...},
	});
end

local function _RateLimit(self: any): boolean
	if (self._RateLimitReach) then return false end;
	if (not self._RateLimitStart) then
		self._RateLimitStart = true;
		task.delay(self.RateLimitTime, function()
			self._Rate = 0;
			self._RateLimitReach = false;
			self._RateLimitStart = false;
		end)
	end

	if (self._Rate == self.RateLimit) then
		self._RateLimitReach = true;
		return false;
	else
		self._Rate += 1;
	end
	return true
end

local function _Set(self: any, SetInfo: {[string]: any})
	for k: string, v: any in pairs(SetInfo) do
		self[k] = v;
	end
end

local function _GetCallBack(Name: string, CallBackType: {}): any
	return CallBackType[Name];
end

local function ReceiveListener(plr: Player, ID: string, CallBackState: boolean, ...: any)
	local EventListener: (Player, boolean, any) -> any = RemoteFunctionsCallBackList[ID];
	if (not EventListener) then return end;
	EventListener(plr, CallBackState, unpack({...}));
end

local function RemoteEventListener(Name: string, Remote: RemoteEvent, ListenerFunc: CallBack)
	if (IsServer) then
		RemoteEventsCallBackList[Name] = Remote.OnServerEvent:Connect(ListenerFunc);
	else
		RemoteEventsCallBackList[Name] = Remote.OnClientEvent:Connect(ListenerFunc);
	end
	return RemoteEventsCallBackList[Name];
end

local function SentListener(self: any, ID: string,  ...: any)
	YieldTilObject(self._Name, RemoteFunctionsCallBackList);
	local CallBack: any = self.GetInvokeCallBack();
	local Data: any = {...};
	if (CallBack) then
		if (IsServer) then
			local plr: Player = Data[1];
			table.remove(Data, 1);
			_Fire(self._Receive, plr, plr, ID, true, CallBack(...));
		else
			_Fire(self._Receive, ID, true, CallBack(...));
		end
	else
		if (IsServer) then
			local plr: Player = Data[1];
			table.remove(Data, 1);
			_Fire(self._Receive, plr, plr, ID, false);
		else
			_Fire(self._Receive, ID, false);
		end
	end
end

local function ServerPostSimulationListener()
	for _: number, Request: Request in ipairs(RequestsList) do
		Request.Remote:FireClient(unpack(Request.Data));
	end

	for _: number, Request: Request in ipairs(FireAllRequestsList) do
        Request.Remote:FireAllClients(unpack(Request.Data));
    end

	table.clear(RequestsList);
	table.clear(FireAllRequestsList);
end

local function ClientPostSimulationListener()
	for _: number, Request: Request in ipairs(RequestsList) do
		Request.Remote:FireServer(unpack(Request.Data));
	end

	table.clear(RequestsList);
end

function LBConnection.RemoteEvent(Name: string, Info: RemoteEventInfo): LBRemote
	if (LBConnection.LBRemotes[Name]) then return LBConnection.LBRemotes[Name] end;
	if not Info then Info = {} end;
	local self: any = CreateObject(Name, Info);

	if (RemotesFolder:FindFirstChild(Name) ~= nil) then
		self._Remote = RemotesFolder[Name];
	else
		if IsServer then
			self._Remote = CreateRemoteEvent(Name, RemotesFolder);
		else
			RemoteConnection:FireServer(true, Name);
			self._Remote = if (RemotesFolder:FindFirstChild(Name) == nil) then RemotesFolder:WaitForChild(Name) else RemotesFolder[Name];
		end
	end

	self.Fire = function(...: any)
		if not _RateLimit(self) then return end;
		_Fire(self._Remote, ...);
	end

	self.FireTo = function(PlayerArray: {Player}, ...: any)
		if not IsServer or not _RateLimit(self) then return end;
		for _: number, Player: Player in ipairs(PlayerArray) do
			_Fire(self._Remote, Player, ...);
		end
	end

	self.FireAll = function(...: any)
		if not IsServer or not _RateLimit(self) then return end;
		_FireAll(self._Remote, ...);
	end

	self.FireAllExcept = function(ExceptionArray: {Player}, ...: any)
		if not IsServer or not _RateLimit(self) then return end;
		local PlayerList: {Player} = Plr:GetPlayers();
		for _: number, Exceptionalplr: Player in ipairs(ExceptionArray) do
			if not table.find(PlayerList, Exceptionalplr) then return end;
			table.remove(PlayerList, table.find(PlayerList, Exceptionalplr));
		end
		for _: number, Player: Player in ipairs(PlayerList) do
			_Fire(self._Remote, Player, ...);
		end
	end

	self.FireDistance = function(plr: Player, RenderDistance: number, ...: any)
		if not IsServer or not _RateLimit(self) then return end;
		local chr: any = plr.Character or plr.CharacterAdded:Wait();
    	RenderDistance = RenderDistance or 20;
    	local RenderPlayers: {Player} = GetNearPlayer(chr, RenderDistance);
		for _: number, RenderPlayer: Player in ipairs(RenderPlayers) do
			_Fire(self._Remote, RenderPlayer, ...);
		end
	end

	self.CallBack = function(CallBack: CallBack): CallBack
		return RemoteEventListener(self._Name, self._Remote, CallBack);
	end

	self.Once = function(CallBack: CallBack): CallBack
		local ListenerFunction: (any) -> () = function(...: any)
			if RemoteEventsCallBackList[self._Name] == nil then return end;
			task.spawn(CallBack, ...);
			RemoteEventsCallBackList[self._Name]:Disconnect();
			RemoteEventsCallBackList[self._Name] = nil;
		end
		return RemoteEventListener(self._Name, self._Remote, ListenerFunction);
	end

	self.GetCallBack = function(): CallBack
		return _GetCallBack(self._Name, RemoteEventsCallBackList);
	end

	self.Set = function(SetInfo: {[string]: any})
		_Set(self, SetInfo);
	end

	LBConnection.LBRemotes[Name] = self;
	return LBConnection.LBRemotes[Name];
end

function LBConnection.RemoteFunction(Name: string, Info: RemoteFunctionInfo): LBRemoteFunction
	if (LBConnection.LBRemoteFunctions[Name]) then return LBConnection.LBRemoteFunctions[Name] end;
	if not Info then Info = {} end;
	local self: any = CreateObject(Name, Info);
	self.TimeOut = Info.TimeOut or 3;

	if (RemotesFolder:FindFirstChild(Name) ~= nil) then
		self._Sent = RemotesFolder[Name].Sent;
		self._Receive = RemotesFolder[Name].Receive;
	else
		if (IsServer) then
			CreateRemoteFunction(Name);
		else
			_Fire(RemoteConnection, false, Name);
		end
		local Folder: any = if (RemotesFolder:FindFirstChild(Name) == nil) then RemotesFolder:WaitForChild(Name) else RemotesFolder[Name];
		self._Sent = Folder.Sent;
		self._Receive = Folder.Receive;
	end

	self.Invoke = function(plr: Player, ...: any): (boolean, any?)
		if not _RateLimit(self) then return false end;
		local Thread: thread = coroutine.running();
		local ID: number|string = GenerateNumbers();
		local Resume: boolean = false;

		RemoteFunctionsCallBackList[ID] = function(PlayerWhoFired: Player, CallbackState: boolean, ...: any)
			if (PlayerWhoFired ~= plr) then return end;
			Resume = true;
			RemoteFunctionsCallBackList[ID] = nil;
			if (CallbackState) then
				task.spawn(Thread, true, ...);
			else
				task.spawn(Thread, false);
			end
		end

		task.delay(self.TimeOut, function()
			if (Resume) then return end;
			RemoteFunctionsCallBackList[ID] = nil;
			task.spawn(Thread, false);
		end)

		task.spawn(function(...: any)
			if (IsServer) then
				_Fire(self._Sent, plr, ID, ...);
			else
				_Fire(self._Sent, ID, ...);
			end
		end, ...)

		return coroutine.yield();
	end

	self.InvokeCallBack = function(CallBack: CallBack): CallBack
		RemoteFunctionsCallBackList[self._Name] = CallBack;
		return RemoteFunctionsCallBackList[self._Name];
	end

	self.GetInvokeCallBack = function(): CallBack
		return _GetCallBack(self._Name, RemoteFunctionsCallBackList);
	end

	self.Set = function(SetInfo: {[string]: any})
		_Set(self, SetInfo);
	end

	if (IsServer) then
		self._Sent.OnServerEvent:Connect(function(plr: Player, ID: string, ...: any)
			SentListener(self, ID, plr, ...);
		end)

		self._Receive.OnServerEvent:Connect(ReceiveListener);
	else
		self._Sent.OnClientEvent:Connect(function(ID: string, ...: any)
			SentListener(self, ID, ...);
		end)

		self._Receive.OnClientEvent:Connect(ReceiveListener);
	end

	LBConnection.LBRemoteFunctions[Name] = self;
	return self;
end

function LBConnection.Bindable(Name: string, Info: BindableInfo): LBBindable
	if (LBConnection.LBBindables[Name]) then return LBConnection.LBBindables[Name] end;
	if not Info then Info = {} end;
	local self: any = CreateObject(Name, Info);
	self.TimeOut = Info.TimeOut or 3;
	self.Receive = nil;

	self.Fire = function(...: any)
		if not _RateLimit(self) then return end;
		YieldTilObject(self._Name, BindableEventsCallBackList);
		task.spawn(BindableEventsCallBackList[self._Name], ...);
	end

	self.Invoke = function(...: any): (boolean, any?)
		if not _RateLimit(self) then return false end;
		YieldTilObject(self._Name, BindableFunctionsCallBackList);
		local Thread: thread = coroutine.running();
		local Resume: boolean = false;

		self._Receive = function(...: any)
			Resume = true;
        	self._Receive = nil;
			task.spawn(Thread, true, ...);
		end

		task.delay(self.TimeOut, function()
			if (Resume) then return end;
			self._Receive = nil;
			task.spawn(Thread, false);
		end)

		task.spawn(BindableFunctionsCallBackList[self._Name], ...);
		return coroutine.yield();
	end

	self.CallBack = function(CallBack: CallBack): CallBack
		BindableEventsCallBackList[self._Name] = CallBack;
		return BindableEventsCallBackList[self._Name];
	end

	self.InvokeCallBack = function(CallBack: CallBack): CallBack
		BindableFunctionsCallBackList[self._Name] = function(...: any)
			self._Receive(CallBack(...));
			return;
		end
		return BindableFunctionsCallBackList[self._Name];
	end

	self.GetCallBack = function(): CallBack
		return _GetCallBack(self._Name, BindableEventsCallBackList);
	end

	self.GetInvokeCallBack = function(): CallBack
		return _GetCallBack(self._Name, BindableFunctionsCallBackList);
	end

	self.Set = function(SetInfo: {[string]: any})
		_Set(self, SetInfo);
	end

	LBConnection.LBBindables[Name] = self;
	return self;
end

function LBConnection.GetRemoteEvent(Name: string): LBRemote
	YieldTilObject(Name, LBConnection.LBRemotes);
	return LBConnection.LBRemotes[Name];
end

function LBConnection.GetRemoteFunction(Name: string): LBRemoteFunction
	YieldTilObject(Name, LBConnection.LBRemoteFunctions);
	return LBConnection.LBRemoteFunctions[Name];
end

function LBConnection.GetBindable(Name: string): LBBindable
	YieldTilObject(Name, LBConnection.LBBindables);
	return LBConnection.LBBindables[Name];
end

-- // Connections
if (IsServer) then
	RemoteConnection.OnServerEvent:Connect(function(_: Player, OneWay: boolean, Name: string)
		if (OneWay) then
			CreateRemoteEvent(Name, RemotesFolder);
		else
			CreateRemoteFunction(Name);
		end
	end)

	RS2.PostSimulation:Connect(ServerPostSimulationListener)
else
	RS2.PostSimulation:Connect(ClientPostSimulationListener)
end

return LBConnection;
