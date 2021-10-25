class_name Manip
extends Node

export (NodePath) var jumper
onready var _jumper: Jumper = get_node(jumper)

func _recv_horizontal_input() -> int:
	if Input.is_action_pressed("ui_left"):
		if not Input.is_action_pressed("ui_right"):
			return Jumper.HorizontalInput.LEFT
	elif Input.is_action_pressed("ui_right"):
		return Jumper.HorizontalInput.RIGHT
	return Jumper.HorizontalInput.NONE

func _recv_vertical_input() -> int:
	if Input.is_action_just_released("ui_select"):
		return Jumper.VerticalInput.JUMP
	elif Input.is_action_pressed("ui_select"):
		return Jumper.VerticalInput.CHARGE
	return Jumper.VerticalInput.NONE

func _physics_process(delta):
	var horizontal_input := _recv_horizontal_input()
	var vertical_input := _recv_vertical_input()
	_jumper.move_and_jump(delta, horizontal_input, vertical_input)
