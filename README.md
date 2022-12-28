# LB-Connection
LB Connection is a module that provides a safe alternative to `RemoteFunction`, `BindableEvent`, and `BindableFunction` in the Roblox Studio. LB Connection is coded based on the Roblox Studio environment.

# Installation
### Method 1 - Quick Installation
1. In Roblox Studio, select the folder where you keep your third party modules/utilities.
2. Run the codes below in the command bar: 
```lua
local Http = game:GetService("HttpService")
local HttpEnabled = Http.HttpEnabled
Http.HttpEnabled = true
local rt = {"SentRemote", "InvokeSentRemote", "InvokeRecieveRemote"}
local m = Instance.new("ModuleScript")
m.Parent = game:GetService("Selection"):Get()[1] or game:GetService("ServerScriptService")
m.Name = "LBConnection"
m.Source = Http:GetAsync("https://raw.githubusercontent.com/LingBlackSama/LB-Connection/main/LBConnection.lua")
game:GetService("Selection"):Set({m})
for i = 1, 3 do
	local r = Instance.new("RemoteEvent")
	r.Name = rt[i]
	r.Parent = m
end
Http.HttpEnabled = HttpEnabled
```

### Method 2 - Download from Roblox Marketplace
https://www.roblox.com/library/11948403956/LB-Connection-Version-1-0

### Method 3 - Download from Releases
https://github.com/LingBlackSama/LB-Connection/releases

  
# API
## LBConnection.Fire
```lua
function LBConnection.Fire(
  Player: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  ...: any, -- Data to pass
)
```
It works as same as `RemoteEvent:FireServer()/RemoteEvent:FireClient()` but the callback use the `LBConnection.CallBack`

Advantage:
- No need to create a new `RemoteEvent` for firing
- More convenient

## LBConnection.FireDistance
```lua
function LBConnection.FireDistance(
  Player: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  RenderDistance: IntValue, -- the radius of the range. Starting from the player you passed as the first parameter. Default is 20
  ...: any, -- Data to pass
)
```
It pretty much works as same as `RemoteEvent:FireClient()`, but it's a little bit different. It has a radius that can search all the players in the range. The callback also use the `LBConnection.CallBack`

Advantage:
- No need to create a new `RemoteEvent` for firing
- It has a range to fire
- More convenient

## LBConnection.FireAllClient
```lua
function LBConnection.FireAllClient(
  ID: string|number, -- The ID to identity the callback
  ...: any, -- Data to pass
)
```
It works as same as `RemoteEvent:FireAllClients()` but the callback use the `LBConnection.CallBack`

Advantage:
- No need to create a new `RemoteEvent` for firing
- More convenient

## LBConnection.FireBindable
```lua
function LBConnection.FireBindable(
  Player: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  ...: any, -- Data to pass
)
```
It works as same as `BindableEvent` but the callback use the `LBConnection.CallBack`

Advantage:
- No need to create a new `BindableEvent` for firing
- It runs faster than `BindableEvent`
- It doesn't cause memory leak
- Unlike `BindableEvent`, it's not that expensive at all

## LBConnection.InvokeBindable
```lua
function LBConnection.InvokeBindable(
  plr: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  TimeOut: IntValue, -- Yield until TimeOut is reached.
  ...: any, -- Data to pass
) => CallbackState: boolean, Data: any
```
It works as same as `BindableFunction` but the callback use the `LBConnection.CallBack`. `TimeOut` will yield until the `TimeOut` is reached (given in seconds). If it recieved the data, it will return the `CallbackState` as a true and the data. Else, the `CallbackState` will just return false.

Advantage:
- No need to create a new `BindableFunction` for invoking
- It runs faster than `BindableFunction`
- It doesn't cause memory leak
- Unlike `BindableFunction`, it's not that expensive at all

## LBConnection.Invoke
```lua
function LBConnection.Invoke(
  plr: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  TimeOut: IntValue, -- Yield until TimeOut is reached.
  ...: any, -- Data to pass
) => CallbackState: boolean, Data: any
```
It works as same as `RemoteFunction` but the callback use the `LBConnection.CallBack`. `TimeOut` will yield until the `TimeOut` is reached (given in seconds). If it recieved the data, it will return the `CallbackState` as a true and the data. Else, the `CallbackState` will just return false.

Advantage:
- No need to create a new `RemoteFunction` for invoking
- It runs faster than `RemoteFunction`

## LBConnection.CallBack
```lua
function LBConnection.CallBack(
  ID: string|number, -- The ID to identity the callback
  CallBack: Function, -- The callback function
)
```
Set the callback to recieve the data with the `ID`

Advantage:
- Simple and clean
- More convenient

## LBConnection.GetCallBack
```lua
function LBConnection.GetCallBack(
  ID: string|number, The ID to identity the callback
) => CallBack: Function -- The callback function
```
Return the callback corresponding with `ID`

Advantage:
- managable callback
