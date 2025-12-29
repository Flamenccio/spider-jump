## Events that the player classes invokes and outsiders subscribe to.
extends Node

## Called when the player starts a powerup.
## Passes `powerup`, a string identifier.
@warning_ignore("unused_signal")
signal powerup_started(powerup: String)

## Called when a powerup ends.
## Passes `powerup`, a string identifier.
@warning_ignore("unused_signal")
signal powerup_ended(poweurp: String)

## Called when an item is collected.
## Passes `item`, a string identifier.
@warning_ignore("unused_signal")
signal item_collected(item: String)

## Called when a player stat is updated.
## Passes `stat`, a string identifier, and `value`, the value of the stat.
@warning_ignore("unused_signal")
signal player_stat_updated(stat: String, value: Variant)

## Called when the player touches an item.
## Passes `item`, a string identifier.
@warning_ignore("unused_signal")
signal player_consumed_item(item: String)

## Called when the powerup timer ticks.
## Passes `time_left`, the time in seconds remaining, and `duration`, 
## the time in seconds it started with.
@warning_ignore("unused_signal")
signal powerup_timer_updated(time_left: float, duration: float)

## Called when the player starts the powerup flash animation.
@warning_ignore("unused_signal")
signal powerup_flash_start()

## Called when the powerup flash animation ends.
@warning_ignore("unused_signal")
signal powerup_flash_end()

## Called when the player collides into another body.
## Passes [code]collision[/code], [code]KinematicCollision2D[/code] info
## about the collision
@warning_ignore("unused_signal")
signal player_collision_enter(collision: KinematicCollision2D)

## Called when the player falls to the bottom of the screen.
## Passes [code]where[/code], a [code]Vector[/code] global position
## where the player fell.
@warning_ignore("unused_signal")
signal player_fell(where: Vector2)

## Called when the player jumps.
## Passes [code]where[/code], a [code]Vector2[/code] global position
## where the player jumped.
@warning_ignore("unused_signal")
signal player_jumped(where: Vector2)

## Called when the player lands.
## Passes [code]where[/code], a [code]Vector2[/code] global position
## where the player landed.
@warning_ignore("unused_signal")
signal player_landed(where: Vector2)


## Called when the player is aiming.
## Passes [code]direction[/code], a normalized [code]Vector2[/code] representing a direction
## and [code]is_valid[/code], a boolean value where [b]true[/b] when the player can
## jump in the direction or [b]false[/b] otherwise.
@warning_ignore("unused_signal")
signal player_aim(direction: Vector2, is_valid: bool)

