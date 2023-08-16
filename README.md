# LB-Connection
LB Connection is a `modulescript` that offers an alternative to use `RemoteEvent`, `RemoteFunction`, `BindableEvent`, and `BindableFunction` in Roblox Studio. It is specifically designed and coded to function within the Roblox Studio environment.

# Advantages
## Queuing package to the next frame
The module operates by iterating over the queue and transmitting its contents. In the absence of any queued packages, no data is sent. This approach centralizes data traffic and reduces the risk of traffic overload.

## Prevent memory leak
This module addresses the memory leaks caused by the invocation of InvokeClient with Roblox RemoteFunction without returning any value or the use of Roblox BindableFunction, which yields until the function halts or returns a value. To prevent these memory leaks, the module includes a TimeOut parameter in its RemoteFunction and BindableFunction implementations, which can be used to specify a maximum duration for the function call and prevent the hang-up or memory leak from occurring.

## Rate Limit
The LBConnection module includes a rate-limiting mechanism for the RemoteEvent, RemoteFunction, BindableEvent, and BindableFunction objects, ensuring the platform’s stability and security. The RateLimit and RateLimitTime parameters allow developers to control the rate at which remote events are triggered and processed, providing a flexible and customizable experience for game development. By specifying these parameters, developers can prevent excessive usage or abuse of remote events, ensuring a smooth and enjoyable player experience.

## Extremely light obfuscation
The RemoteFunction in this module employs a secure identification method by passing a random binary string packed with an unsigned integer to the client and requiring the client to return it to the server. This approach helps to prevent potential exploitation by ensuring that only the correct data is returned to the server. (It should be noted that the binary string obfuscation used in this module is extremely light and can still be viewed by exploiters, potentially allowing them to manipulate the data sent from the server.)

## Faster execution
The implementation of RemoteFunction in the module utilizes two RemoteEvent objects to simulate the behavior of RemoteFunction. Furthermore, implementing BindableEvent and BindableFunction in the module does not utilize any BindableEvent and BindableFunction objects, resulting in faster performance and increased maintainability.

# Tips
It is recommended to pre-add the `RemoteEvent` or a `Folder` containing two `RemoteEvent`, "Sent" and "Recieve", to the Remotes folder using the Roblox Studio explorer. This can help to improve the speed at which `LBConnection.RemoteEvent` and `LBConnection.RemoteFunction` can access the `RemoteEvent` or `RemoteFunction`.

When firing the `LBConnection.RemoteEvent`, it is only necessary to declare the second parameter once on the side from which it is fired. For instance, if the event is being fired from the server, the 'Info' parameter should only be declared on the server side. It is unnecessary to declare it on the client side if you are setting the callback only.

To access an object that has been declared, it is recommended to use `LBConnection.GetRemoteEvent` , `LBConnection.GetRemoteFunction` , or `LBConnection.GetBindable` .

# Q & A
#### Q: Why are you removing the feature of packing byte string to binary format on v2.1.0-beta? 
##### A: My friend did a solo test in Roblox Studio, where networking isn’t a bottleneck, and there was no upper limit. The main problem was generating new data. Strings are already optimized for us, so further optimization might result in diminishing returns or worse network usage. The networking optimizations for strings are already in place, so we don’t need to optimize them further.

#### Q: How can I modify the remote folder location?
##### A: To modify the location of the remote folder, simply edit the value of the RemotesFolder variable within the module.

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
m.Source = Http:GetAsync("https://raw.githubusercontent.com/LingBlackSama/LB-Connection/main/LBConnection/init.lua")
game:GetService("Selection"):Set({m})
local r = Instance.new("RemoteEvent")
r.Name = "RemoteConnection"
r.Parent = m
local f = Instance.new("Folder")
f.Name = "Remotes"
f.Parent = m
Http.HttpEnabled = HttpEnabled
```

### Method 2 - Download from Roblox Marketplace
[https://www.roblox.com/library/11948403956/LB-Connection-v2-2-0-beta](https://www.roblox.com/library/11948403956/LB-Connection-v2-2-0-beta)

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

## LBConnection.RemoteEvent:Fire
```lua
type LBConnection.RemoteEvent:Fire = (any) -> ()
function LBConnection.RemoteEvent:Fire(
  ...: any
)
```
The function operates in a similar manner to the `RemoteEvent:FireServer` and `RemoteEvent:FireClient` methods, but it converts the byte string that is passed to it into a binary string. Additionally, the callback uses the `LBConnection.RemoteEvent:CallBack` or `LBConnection.RemoteEvent:Once` method, thereby establishing a one-way communication link between the client and server. If the function is called on the server, it is necessary to pass the `Player` as the first argument.

## LBConnection.RemoteEvent:FireAll [Server only]
```lua
type LBConnection.RemoteEvent:FireAll = (any) -> ()
function LBConnection.RemoteEvent:FireAll(
 ...: any
)
```
This function operates in a similar manner to `RemoteEvent:FireAllClients`. The callback uses callback uses the `LBConnection.RemoteEvent:CallBack` or `LBConnection.RemoteEvent:Once` method.

## LBConnection.RemoteEvent:FireTo [Server only]
```lua
type LBConnection.RemoteEvent:FireTo = ({Player}, any) -> ()
function LBConnection.RemoteEvent:FireTo(
  PlayerArray: {Player},
  ...: any,
)
```
This function operates in a similar manner to `LBConnection.RemoteEvent:FireAll`, but it includes a filter list to exclude certain players from being fired.

## LBConnection.RemoteEvent:FireAllExcept [Server only]
```lua
type LBConnection.RemoteEvent:FireAllExcept = ({Player}, any) -> ()
function LBConnection.RemoteEvent:FireAllExcept(
  PlayerArray: {Player},
  ...: any,
)
```
This function operates in a similar manner to `LBConnection.RemoteEvent:FireAll`, but it includes a filter list to exclude certain players from being fired.


## LBConnection.RemoteEvent:FireDistance [Server only]
```lua
type LBConnection.RemoteEvent:FireDistance = (Player, number, any) -> ()
function LBConnection.RemoteEvent:FireDistance(
  plr: Player,
  RenderDistance: number,
  ...: any,
)
```
This function operates in a similar manner to `LBConnection.RemoteEvent:Fire`, but with a slight variation. It has the capability to search for all players within a specific radius range.

## LBConnection.RemoteEvent:CallBack
```lua
type LBConnection.RemoteEvent:CallBack = ((any) -> any) -> ((any) -> any)
function LBConnection.RemoteEvent:CallBack(
  CallBack: (any) -> any
): ((any) -> any)
```
The function sets the RemoteEvent callback to `CallBack` function

## LBConnection.RemoteEvent:Once
```lua
type LBConnection.RemoteEvent:Once = ((any) -> any) -> ((any) -> any)
function LBConnection.RemoteEvent:Once(
  CallBack: (any) -> any
): ((any) -> any)
```
This function operates in a manner similar to `LBConnection.RemoteEvent:CallBack`, however, it will only be called once.

## LBConnection.RemoteEvent:GetCallBack
```lua
type LBConnection.RemoteEvent:GetCallBack = () -> ((any) -> any)
function LBConnection.RemoteEvent:GetCallBack(): ((any) -> any)
```
The function returns the callback that was set with `LBConnection.RemoteEvent:CallBack`.

## LBConnection.RemoteEvent:Set
```lua
type LBConnection.RemoteEvent:Set = ({[string]: any}) -> ()
function LBConnection.RemoteEvent:Set(
  SetInfo: {[string]: any}
)
```
This function is as same as the second parameter of `LBConnection.RemoteEvent`.

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

## LBConnection.RemoteFunction:Invoke
```lua
type LBConnection.RemoteFunction:Invoke = ((any) -> any): ((any) -> any)) -> (boolean, any?)
function LBConnection.RemoteFunction:Invoke(
  plr: Player,
  ...: any,
): (boolean, any?)
```
This function operates in a similar manner to `RemoteFunction`, but it does not create an additional `RemoteFunction` and uses `LBConnection.RemoteFunction:InvokeCallBack` as a callback. It runs faster than `RemoteFunction`. The `TimeOut` parameter will pause execution until the specified time in seconds has elapsed. If data is received during this time, the function will return as true along with the data. If no data is received, the function will return as false.


## LBConnection.RemoteFunction:InvokeCallBack
```lua
type LBConnection.RemoteFunction:InvokeCallBack = ((any) -> any): ((any) -> any)) -> ()
function LBConnection.RemoteFunction:InvokeCallBack(
  CallBack: (any) -> any): ((any) -> any)),
)
```
The function sets the RemoteFunction invoke callBack to `CallBack` function

## LBConnection.RemoteFunction:GetInvokeCallBack
```lua
type LBConnection.RemoteFunction:GetInvokeCallBack = () -> ((any) -> any)
function LBConnection.RemoteFunction:GetInvokeCallBack(): ((any) -> any)
```
The function returns the callback that was set with `LBConnection.RemoteFunction:InvokeCallBack`.

## LBConnection.RemoteFunction:Set
```lua
type LBConnection.RemoteFunction.Set = ({[string]: any}) -> ()
function LBConnection.RemoteFunction.Set(
  SetInfo: {[string]: any}
)
```
This function is as same as the second parameter of `LBConnection.RemoteFunction`.

## LBConnection.BindableEvent
```lua
type LBConnection.BindableEvent = (string, {RateLimit: number?, RateLimitTime: number?}) -> any
function LBConnection.BindableEvent(
  Name: string, -- Name of the RemoteFunction
  Info: {RateLimit: number?, RateLimitTime: number?}, -- Optional: Information table
): {
  _Name: string,
  Fire: (any) -> (),
  CallBack: (CallBack) -> ((any) -> any),
  GetCallBack: () -> ((any) -> any),
  Set: () -> (),
}
```
The function `LBConnection.BindableEvent` creates an LB BindableEvent object within the LB Connection. It does not create an additional BindableEvent. The `RateLimit` parameter specifies the rate in the rate limit for the LB BindableEvent, while the `RateLimitTime` parameter indicates the duration of the rate limit.

## LBConnection.BindableEvent:Fire
```lua
type LBConnection.BindableEvent:Fire = (any) -> ()
function LBConnection.BindableEvent:Fire(
  ...: any,
)
```
This function operates in a similar manner to `BindableEvent`, but the callback uses `LBConnection.BindableEvent:CallBack`. Additionally, it does not create an additional `BindableEvent`, which makes the function run faster, prevents memory leaks, and is not resource-intensive.

## LBConnection.BindableEvent:CallBack
```lua
type LBConnection.BindableEvent:CallBack = ((any) -> any) -> ((any) -> any)
function LBConnection.BindableEvent:CallBack(
  CallBack: (any) -> any,
): ((any) -> any)
```
The function sets the BindableEvent callBack to `CallBack` function.

## LBConnection.BindableEvent:GetCallBack
```lua
type LBConnection.BindableEvent:GetCallBack = () -> ((any) -> any)
function LBConnection.BindableEvent:GetCallBack(): ((any) -> any)
```
The function returns the callback that was set with `LBConnection.BindableEvent:CallBack`.

## LBConnection.BindableEvent:Set
```lua
type LBConnection.BindableEvent:Set = ({[string]: any}) -> ()
function LBConnection.BindableEvent:Set(
  SetInfo: {[string]: any}
)
```
This function is as same as the second parameter of `LBConnection.BindableEvent`.

## LBConnection.BindableFunction
```lua
type LBConnection.BindableFunction = (string, {TimeOut: number?, RateLimit: number?, RateLimitTime: number?}) -> any
function LBConnection.BindableFunction(
  Name: string, -- Name of the RemoteFunction
  Info: {TimeOut: number?, RateLimit: number?, RateLimitTime: number?}, -- Optional: Information table
): {
  _Name: string,
  _TimeOut: number,
  _Receive: nil|(any) -> (boolean, any?),
  Invoke: (any) -> (boolean, any?),
  InvokeCallBack: ((any) -> any) -> ((any) -> any),
  GetInvokeCallBack: () -> ((any) -> any),
  Set: () -> (),
}
```
The function `LBConnection.BindableFunction` creates an LB BindableEvent object within the LB Connection. It does not create an additional BindableFunction. The `RateLimit` parameter specifies the rate in the rate limit for the LB BindableFunction, while the `RateLimitTime` parameter indicates the duration of the rate limit. The `TimeOut` parameter defines the timeout duration for the LB Bindable. The `TimeOut` parameter does not need to be defined if you will not send the package with it.

## LBConnection.BindableFunction:Invoke
```lua
type LBConnection.BindableFunction:Invoke = (any) -> (boolean, any?)
function LBConnection.BindableFunction:Invoke(
  ...: any,
): (boolean, any?)
```
This function operates in a similar manner to `BindableFunction`, but it does not create an additional `BindableFunction` and uses `LBConnection.BindableFunction:InvokeCallBack` as a callback. It runs faster than `BindableFunction`. The `TimeOut` parameter will pause execution until the specified time in seconds has elapsed. If data is received during this time, the function will return as true along with the data. If no data is received, the function will return as false.

## LBConnection.BindableFunction:InvokeCallBack
```lua
type LBConnection.BindableFunction:InvokeCallBack = ((any) -> any) -> ((any) -> any)
function LBConnection.BindableFunction:InvokeCallBack(
  CallBack: (any) -> any,
): ((any) -> any)
```
The function sets the BindableFunction invoke callBack to `CallBack` function

## LBConnection.BindableFunction:GetInvokeCallBack
```lua
type LBConnection.BindableFunction:GetInvokeCallBack = ((any) -> any) -> ((any) -> any)
function LBConnection.BindableFunction:GetInvokeCallBack(
  CallBack: (any) -> any,
): ((any) -> any)
```
The function returns the callback that was set with `LBConnection.BindableFunction:InvokeCallBack`.

## LBConnection.BindableFunction:Set
```lua
type LBConnection.BindableFunction:Set = ({[string]: any}) -> ()
function LBConnection.BindableFunction:Set(
  SetInfo: {[string]: any}
)
```
This function is as same as the second parameter of `LBConnection.BindableFunction`.

## LBConnection.GetRemoteEvent
```lua
type LBConnection.GetRemoteEvent = (string): any
function LBConnection.GetRemoteEvent(
  Name: string,
): any
```
Return the LB RemoteEvent

## LBConnection.GetRemoteFunction
```lua
type LBConnection.GetRemoteFunction = (string): any
function LBConnection.GetRemoteFunction(
  Name: string,
): any
```
Return the LB RemoteFunction

## LBConnection.GetBindableEvent
```lua
type LBConnection.GetBindableEvent = (string): any
function LBConnection.GetBindableEvent(
  Name: string,
): any
```
Return the LB BindableEvent


## LBConnection.GetBindableFunction
```lua
type LBConnection.GetBindableFunction = (string): any
function LBConnection.GetBindableFunction(
  Name: string,
): any
```
Return the LB BindableFunction
