# LB-Connection
LB Connection is a module that offers a secure alternative to using `RemoteEvent`, `RemoteFunction`, `BindableEvent`, and `BindableFunction` in Roblox Studio. It is specifically designed and coded to function within the Roblox Studio environment.

# Installation
### Method 1 - Quick Installation
1. In Roblox Studio, select the folder where you store your third-party modules or utilities.
2. Run the following codes in the command bar:
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
type LBConnection.Fire = (Player, string|number, any) -> ()
function LBConnection.Fire(
  Player: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  ...: any, -- Data to pass
)
```
This function operates in a similar manner to `RemoteEvent:FireServer`/`RemoteEvent:FireClient`, but it does not create an additional `RemoteEvent`. Instead, the callback uses `LBConnection.CallBack`, creating a one-way connection between the client and server.

## LBConnection.FireDistance
```lua
type LBConnection.FireDistance = (Player, string|number, number, any) -> ()
function LBConnection.FireDistance(
  Player: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  RenderDistance: number, -- the radius of the range. Starting from the player you passed as the first parameter. Default is 20
  ...: any, -- Data to pass
)
```
This function operates in a similar manner to `LBConnection.Fire`, but with a slight variation. It has the capability to search for all players within a specific radius range.

## LBConnection.FireAll
```lua
type LBConnection.FireAll = (string|number, any) -> ()
function LBConnection.FireAll(
  ID: string|number, -- The ID to identity the callback
  ...: any, -- Data to pass
)
```
This function operates in a similar manner to `RemoteEvent:FireAllClients`, but it does not create an additional `RemoteEvent`. The callback uses `LBConnection.CallBack`, and it can be called from either the server or client.

## LBConnection.FireAllExcept
```lua
type LBConnection.FireAllExcept = (string|number, any) -> ()
function LBConnection.FireAll(
  ID: string|number, -- The ID to identity the callback
  ExceptionArray: {Player}, -- an array with exceptional players in it
  ...: any, -- Data to pass
)
```
This function operates in a similar manner to `LBConnection.FireAll`, but it includes a filter list to exclude certain players from being fired.

## LBConnection.FireBindable
```lua
type LBConnection.FireBindable = (string|number, any) -> any
function LBConnection.FireBindable(
  ID: string|number, -- The ID to identity the callback
  ...: any, -- Data to pass
): ...: any
```
This function operates in a similar manner to `BindableEvent` and `BindableFunction`, but the callback uses `LBConnection.CallBack`. Additionally, it does not create an additional `BindableEvent` or `BindableFunction`, which makes the function run faster, prevents memory leaks, and is not resource-intensive.

## LBConnection.Invoke
```lua
type LBConnection.Invoke = (Player, string|number, number, any) -> (boolean, any)
function LBConnection.Invoke(
  plr: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  TimeOut: number, -- Yield until TimeOut is reached (given in seconds).
  ...: any, -- Data to pass
): CallbackState: boolean, Data: any
```
This function operates in a similar manner to `RemoteFunction`, but it does not create an additional `RemoteFunction` and uses `LBConnection.CallBack` as a callback. It runs faster than `RemoteFunction`. The `TimeOut` parameter will pause execution until the specified time in seconds has elapsed. If data is received during this time, the `CallbackState` will return as true along with the data. If no data is received, the `CallbackState` will return as false.

## LBConnection.CallBack
```lua
type LBConnection.CallBack = (string|number, function) -> ()
function LBConnection.CallBack(
  ID: string|number, -- The ID to identity the callback
  CallBack: function, -- The callback function
)
```
To receive the data with the specified `ID`, set the callback to `CallBack`

## LBConnection.GetCallBack
```lua
type LBConnection.GetCallBack = () -> (function)
function LBConnection.GetCallBack(
  ID: string|number, The ID to identity the callback
): CallBack: function -- The callback function
```
The callback corresponding with the specified `ID` will be returned.
