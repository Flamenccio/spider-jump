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

## Dictionary of player info at recovery point.[br]
## Keys:[br]
## - [code]position[/code]: position of recovery point[br]
## - [code]rotation[/code]: rotation of player at recovery point[br]
## - [code]surface_info[/code]: GroundHandler surface info for surface at
## recovery point[br]
var recovery_info := {}

var current_max_vertical_speed := DEFAULT_MAX_VERTICAL_SPEED
var high_score := 0
