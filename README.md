# LB-Connection
LB Connection is a `modulescript` that offers an alternative to use `RemoteEvent`, `RemoteFunction`, `BindableEvent`, and `BindableFunction` in Roblox Studio. It is specifically designed and coded to function within the Roblox Studio environment.

# Installation
### Method 1 - Quick Installation
1. In Roblox Studio, select the folder where you store your third-party modules or utilities.
2. Run the following codes in the command bar:
```lua
local Http = game:GetService("HttpService")
local HttpEnabled = Http.HttpEnabled
Http.HttpEnabled = true
local m = Instance.new("ModuleScript")
m.Parent = game:GetService("Selection"):Get()[1] or game:GetService("ReplicatedStorage")
m.Name = "LBConnection"
m.Source = Http:GetAsync("https://raw.githubusercontent.com/LingBlackSama/LB-Connection/main/LBConnection.lua")
game:GetService("Selection"):Set({m})
local r = Instance.new("RemoteEvent")
r.Name = "RemoteConnection"
r.Parent = m
local f = Instance.new("Folder")
f.Name = "Remotes"
f.Parent = m
Http.HttpEnabled = HttpEnabled
```

### Method 2 - Download from Roblox Marketplace (Not updated yet)
~~https://www.roblox.com/library/11948403956/LB-Connection-Version-1-0~~

### Method 3 - Download from Releases
https://github.com/LingBlackSama/LB-Connection/releases

  
# API
## LBConnection.RemoteEvent
```lua
type LBConnection.RemoteEvent = (string, {RateLimit: number?, RateLimitTime: number?}) -> any
function LBConnection.RemoteEvent(
  Name: string, -- Name of the RemoteEvent
  Info: {RateLimit: number?, RateLimitTime: number?}, -- Optional: Information table
): {
  _Name: string,
  _Remote: nil|RemoteEvent,
  Fire: (any) -> (),
  FireTo: ({Player}, any) -> (),
  FireAll: (any) -> (),
  FireAllExcept: ({Player}, any) -> (),
  FireDistance: (Player, number, any) -> (),
  CallBack: ((any) -> any) -> ((any) -> any),
  Once: ((any) -> any) -> ((any) -> any),
  GetCallBack: () -> ((any) -> any),
}
```
The function `LBConnection.RemoteEvent` creates a `RemoteEvent` object within the LB Connection. The `RateLimit` parameter specifies the rate limit for the `RemoteEvent`, with a default value of 60 rates. The `RateLimitTime` parameter indicates the duration of the rate limit, with a default value of 1 second. When this function is called on the client, and there is no `RemoteEvent` with the specified `Name` in the folder, Remotes, it may yield until the `RemoteEvent` is created on the server. To avoid this, placing the `RemoteEvent` in the Remotes folder before the game loads are recommended. The `Info` parameter is optional and does not need to be defined if you will not send the package with it.

## LBConnection.RemoteEvent.Fire
```lua
type LBConnection.RemoteEvent.Fire = (any) -> ()
function LBConnection.RemoteEvent.Fire(
  ...: any
)
```
The function operates in a similar manner to the `RemoteEvent:FireServer` and `RemoteEvent:FireClient` methods, but it converts the byte string that is passed to it into a binary string. Additionally, the callback uses the `LBConnection.RemoteEvent.CallBack` or `LBConnection.RemoteEvent.Once` method, thereby establishing a one-way communication link between the client and server. If the function is called on the server, it is necessary to pass the `Player` as the first argument.

## LBConnection.RemoteEvent.FireAll [Server only]
```lua
type LBConnection.RemoteEvent.FireAll = (any) -> ()
function LBConnection.RemoteEvent.FireAll(
 ...: any
)
```
This function operates in a similar manner to `RemoteEvent:FireAllClients`. The callback uses callback uses the `LBConnection.RemoteEvent.CallBack` or `LBConnection.RemoteEvent.Once` method.

## LBConnection.RemoteEvent.FireTo [Server only]
```lua
type LBConnection.RemoteEvent.FireTo = ({Player}, any) -> ()
function LBConnection.RemoteEvent.FireTo(
  PlayerArray: {Player},
  ...: any,
)
```
This function operates in a similar manner to `LBConnection.RemoteEvent.FireAll`, but it includes a filter list to exclude certain players from being fired.

## LBConnection.RemoteEvent.FireAllExcept [Server only]
```lua
type LBConnection.RemoteEvent.FireAllExcept = ({Player}, any) -> ()
function LBConnection.RemoteEvent.FireAllExcept(
  PlayerArray: {Player},
  ...: any,
)
```
This function operates in a similar manner to `LBConnection.RemoteEvent.FireAll`, but it includes a filter list to exclude certain players from being fired.


## LBConnection.RemoteEvent.FireDistance [Server only]
```lua
type LBConnection.RemoteEvent.FireDistance = (Player, number, any) -> ()
function LBConnection.RemoteEvent.FireDistance(
  plr: Player,
  RenderDistance: number,
  ...: any,
)
```
This function operates in a similar manner to `LBConnection.RemoteEvent.Fire`, but with a slight variation. It has the capability to search for all players within a specific radius range.

## LBConnection.RemoteEvent.CallBack
```lua
type LBConnection.RemoteEvent.CallBack = ((any) -> any) -> ((any) -> any)
function LBConnection.RemoteEvent.CallBack(
  CallBack: (any) -> any
): ((any) -> any)
```
The function sets the RemoteEvent callback to `CallBack` function

## LBConnection.RemoteEvent.Once
```lua
type LBConnection.RemoteEvent.Once = ((any) -> any) -> ((any) -> any)
function LBConnection.RemoteEvent.Once(
  CallBack: (any) -> any
): ((any) -> any)
```
This function operates in a manner similar to `LBConnection.RemoteEvent.CallBack`, however, it will only be called once.

## LBConnection.RemoteEvent.GetCallBack
```lua
type LBConnection.RemoteEvent.GetCallBack = () -> ((any) -> any)
function LBConnection.RemoteEvent.GetCallBack(): ((any) -> any)
```
The function returns the callback that was set with `LBConnection.RemoteEvent.CallBack`.

## LBConnection.RemoteFunction
```lua
type LBConnection.RemoteFunction = (string, {TimeOut: number?, RateLimit: number?, RateLimitTime: number?}) -> any
function LBConnection.RemoteFunction(
  Name: string, -- Name of the RemoteFunction
  Info: {TimeOut: number?, RateLimit: number?, RateLimitTime: number?}, -- Optional: Information table
): {
  _Name: string,
  _TimeOut: number,
  _Sent: nil|RemoteEvent,
  _Receive: nil|RemoteEvent,
  Invoke: (Player, any) -> (boolean, any?),
  InvokeCallBack: ((any) -> any) -> (((any) -> any)),
  GetInvokeCallBack: () -> ((any) -> any),
}
```
The function `LBConnection.RemoteFunction` creates a LB RemoteFunction object within the LB Connection. It utilizes two `RemoteEvent` to simulate the behavior of a `RemoteFunction`. The `RateLimit` parameter specifies the rate in the rate limit for the LB RemoteFunction, while the `RateLimitTime` parameter indicates the duration of the rate limit. The `TimeOut` parameter defines the timeout duration for the LB RemoteFunction. The `TimeOut` parameter does not need to be defined if you will not send the package with it.

## LBConnection.RemoteFunction.Invoke
```lua
type LBConnection.RemoteFunction.Invoke = ((any) -> any): ((any) -> any)) -> (boolean, any?)
function LBConnection.RemoteFunction.Invoke(
  plr: Player,
  ...: any,
): (boolean, any?)
```

## LBConnection.RemoteFunction.InvokeCallBack
```lua
type LBConnection.RemoteFunction.InvokeCallBack = ((any) -> any): ((any) -> any)) -> ()
function LBConnection.RemoteFunction.InvokeCallBack(
  CallBack: (any) -> any): ((any) -> any)),
)
```

## LBConnection.RemoteFunction.GetInvokeCallBack
```lua
type LBConnection.RemoteFunction.GetInvokeCallBack = () -> ((any) -> any)
function LBConnection.RemoteFunction.GetInvokeCallBack(): ((any) -> any)
```

## LBConnection.Bindable
```lua
type LBConnection.RemoteFunction = (string, {TimeOut: number?, RateLimit: number?, RateLimitTime: number?}) -> any
function LBConnection.RemoteFunction(
  Name: string, -- Name of the RemoteFunction
  Info: {TimeOut: number?, RateLimit: number?, RateLimitTime: number?}, -- Optional: Information table
): {
  _Name: string,
  _TimeOut: number,
  _Receive: nil|(any) -> (boolean, any?),
  Fire: (any) -> (),
  Invoke: (any) -> (boolean, any?),
  CallBack: ((any) -> any) -> ((any) -> any),
  InvokeCallBack: ((any) -> any) -> ((any) -> any),
  GetCallBack: () -> ((any) -> any),
  GetInvokeCallBack: () -> ((any) -> any),
}
```

## LBConnection.Bindable.Fire
```lua
type LBConnection.Bindable.Fire = (any) -> ()
function LBConnection.Bindable.Fire(
  ...: any,
)
```

## LBConnection.Bindable.Invoke
```lua
type LBConnection.Bindable.Invoke = (any) -> (boolean, any?)
function LBConnection.Bindable.Invoke(
  ...: any,
): (boolean, any?)
```

## LBConnection.Bindable.CallBack
```lua
type LBConnection.Bindable.CallBack = ((any) -> any) -> ((any) -> any)
function LBConnection.Bindable.CallBack(
  CallBack: (any) -> any,
): ((any) -> any)
```

## LBConnection.Bindable.InvokeCallBack
```lua
type LBConnection.Bindable.InvokeCallBack = ((any) -> any) -> ((any) -> any)
function LBConnection.Bindable.InvokeCallBack(
  CallBack: (any) -> any,
): ((any) -> any)
```

## LBConnection.Bindable.GetCallBack
```lua
type LBConnection.Bindable.GetCallBack = () -> ((any) -> any)
function LBConnection.Bindable.GetCallBack(): ((any) -> any)
```

## LBConnection.Bindable.GetInvokeCallBack
```lua
type LBConnection.Bindable.GetInvokeCallBack = ((any) -> any) -> ((any) -> any)
function LBConnection.Bindable.GetInvokeCallBack(
  CallBack: (any) -> any,
): ((any) -> any)
```

## LBConnection.GetRemoteEvent
```lua
type LBConnection.GetRemoteEvent = (string): any
function LBConnection.GetRemoteEvent(
  Name: string,
): any
```

## LBConnection.GetRemoteFunction
```lua
type LBConnection.GetRemoteFunction = (string): any
function LBConnection.GetRemoteFunction(
  Name: string,
): any
```

## LBConnection.GetBindable
```lua
type LBConnection.GetBindable = (string): any
function LBConnection.GetBindable(
  Name: string,
): any
```

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
