extends StaticBody2D

signal laser_telegraph_flash_started()
signal laser_telegraph_started()
signal laser_attack_finished()
signal laser_attack_started()
const ACTIVATIION_DURATION = 1.0
const TELEGRAPH_DURATION = 2.0
var activation_timer: Timer = Timer.new()
var telegraph_timer: Timer = Timer.new()
var telegraphing: bool = false

@export var state_machine: StateMachinePlayer

func _ready() -> void:
	state_machine.set_param('attack_done', false)
	state_machine.set_param('telegraph_time', 10.0)
	activation_timer.wait_time = ACTIVATIION_DURATION
	activation_timer.one_shot = true
	activation_timer.timeout.connect(func():
		state_machine.set_param('attack_done', true)
	)
	add_child(activation_timer)

	telegraph_timer.wait_time = TELEGRAPH_DURATION
	telegraph_timer.one_shot = true
	add_child(telegraph_timer)


func _physics_process(delta: float) -> void:
	if telegraphing:
		state_machine.set_param('telegraph_time', telegraph_timer.time_left)


func do_attack() -> void:
	laser_attack_started.emit()
	activation_timer.start()


func do_telegraph() -> void:
	laser_telegraph_started.emit()
	telegraph_timer.start()


func do_telegraph_flash() -> void:
	laser_telegraph_flash_started.emit()


func deactivate_laser() -> void:
	laser_attack_finished.emit()


func _transited_state(from: String, to: String) -> void:
	_enter_state(to)


func _enter_state(state: String) -> void:
	match state:
		'Telegraph':
			telegraphing = true
			do_telegraph()
		'TelegraphFlash':
			telegraphing = true
			do_telegraph_flash()
		'Attack':
			telegraphing = false
			do_attack()
		'Exit':
			telegraphing = false
			deactivate_laser()
		_:
			telegraphing = false
			return

