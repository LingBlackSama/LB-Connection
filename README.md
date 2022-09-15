# LB-Connection
  LB Connection is a module that provides a safe alternative to `RemoteFunction`, `BindableEvent`, and `BindableFunction` in the Roblox Studio. LB Connection is coded based on the Roblox Studio environment.
  
# API
## LBConnection.Fire
```lua
LBConnection.Fire(
  Player: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  ...: any, -- Data to pass
)
```
It works as same as `RemoteEvent:FireServer()/RemoteEvent:FireClient()` but the callback use the `LBConnection.CallBack`

Advantage:
- No need to create a new `RemoteEvent` for firing the `RemoteEvent`
- More convenient

## LBConnection.FireDistance
```lua
function LBConnection.FireDistance(
  Player: Player, -- Basically the player
  ID: string|number, -- The ID to identity the callback
  RenderDistance: IntValue, -- the radius of the range. Starting from the player you passed as the first parameter. Default is 20
)
```
It pretty much works as same as `RemoteEvent:FireClient()`, but it's a little bit different. It has a radius that can search all the players in the range. The callback also use the `LBConnection.CallBack`
Advantage:
- No need to create a new `RemoteEvent` for firing the `RemoteEvent`
- It has a range to fire

