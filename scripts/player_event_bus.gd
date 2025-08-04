## Events that the player classes invokes and outsiders subscribe to.
extends Node

## Called when the player starts a powerup.
## Passes `powerup`, a string identifier.
signal powerup_started(powerup: String)

## Called when any powerup ends
signal powerup_ended()

## Called when a player stat is updated.
## Passes `stat`, a string identifier, and `value`, the value of the stat.
signal player_stat_updated(stat: String, value: Variant)

## Called when the player touches an item.
## Passes `item`, a string identifier.
signal player_consumed_item(item: String)
