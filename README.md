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
It works as same as `RemoteEvent` but the callback is the `LBConnection.CallBack`

Advantage:
- No need to create a new `RemoteEvent` for firing the `RemoteEvent`
- More convenient

## LBConnection.FireDistance
```lua
function LBConnection.FireDistance(

)
```
