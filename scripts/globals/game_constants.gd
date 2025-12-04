extends Node

## How many pixels the player must travel upward to gain 1 point
const PIXELS_PER_POINT = 8

## Default gravity accceleration
const DEFAULT_GRAVITY = 450.0

const DEFAULT_MAX_VERTICAL_SPEED = 250.0

var game_spawner: GlobalSpawner
var difficulty := 0
var current_gravity := DEFAULT_GRAVITY
var current_powerup := ItemIds.NO_POWERUP
var player: Node2D
var main_camera: Camera2D
var recovery_point: VisibleOnScreenNotifier2D
var current_max_vertical_speed := DEFAULT_MAX_VERTICAL_SPEED
