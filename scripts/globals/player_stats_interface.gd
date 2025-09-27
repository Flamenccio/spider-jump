## Allows scripts to request stat changes. These changes may be ignored or altered
## by the player stats script.
extends Node

const STATS_HEALTH = 'lives'
const STATS_STAMINA = 'stamina'
const STATS_SCORE = 'score'

## Changes a stat by some `change`.
## Accepts `stat`, a string identifier, and `change`, a variant to change the stat by.
signal change_stat(stat: String, change: Variant)

## Sets a stat to `value`.
## Accepts `stat`, a string identifier, and `value`, a variant to change the stat to.
signal set_stat(stat: String, value: Variant)
