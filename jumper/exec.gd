class_name Exec
extends Node

export (NodePath) var jumper

export (Array, int, "None", "Left", "Right") var horizontal_inputs
export (Array, int, "None", "Charge", "Jump") var vertical_inputs
export (Array, float) var input_periods

onready var _jumper: Jumper = get_node(jumper)
var _time_accum: float = 10000000
onready var _period_index: int = 10000000
var _is_finished: bool = true

signal finished(exec)

func exec():
	_time_accum = 0
	_period_index = 0
	_is_finished = false

func _physics_process(delta):
#	print("proc: ", _time_accum, ", ", _period_index, ", ", _is_finished)
	if _is_finished:
		return
	if _period_index >= input_periods.size():
		_is_finished = true
		emit_signal("finished", self)
		return
	_time_accum += delta
	if _time_accum >= input_periods[_period_index]:
		_time_accum = 0
		_period_index += 1
		if _period_index >= input_periods.size():
			_is_finished = true
			emit_signal("finished", self)
			return
	var horizontal_input: int = horizontal_inputs[_period_index]
	var vertical_input: int = vertical_inputs[_period_index]
	_jumper.move_and_jump(delta, horizontal_input, vertical_input)
