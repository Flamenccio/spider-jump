## Events that the player classes invokes and outsiders subscribe to.
extends Node

## Called when the player starts a powerup.
## Passes `powerup`, a string identifier.
signal powerup_started(powerup: String)

## Called when a powerup ends.
## Passes `powerup`, a string identifier.
signal powerup_ended(poweurp: String)

## Called when an item is collected.
## Passes `item`, a string identifier.
signal item_collected(item: String)

## Called when a player stat is updated.
## Passes `stat`, a string identifier, and `value`, the value of the stat.
signal player_stat_updated(stat: String, value: Variant)

## Called when the player touches an item.
## Passes `item`, a string identifier.
signal player_consumed_item(item: String)

## Called when the powerup timer ticks.
## Passes `time_left`, the time in seconds remaining, and `duration`, 
## the time in seconds it started with.
signal powerup_timer_updated(time_left: float, duration: float)

## Called when the player starts the powerup flash animation.
signal powerup_flash_start()

# Called when the powerup flash animation ends.
signal powerup_flash_end()

