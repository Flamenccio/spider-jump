extends Node

## How many pixels the player must travel upward to gain 1 point
const PIXELS_PER_POINT = 8

## Default gravity accceleration
const DEFAULT_GRAVITY = 225.0

var difficulty := 0
var current_gravity := DEFAULT_GRAVITY
var current_powerup := ItemIds.NO_POWERUP
