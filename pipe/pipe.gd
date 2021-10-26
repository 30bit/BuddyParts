class_name Pipe
extends Path2D

const JOURNEY_SPEED: float = 10000.0
const SPIT_SPEED: float = 1000.0
const FORGET_DELAY: float = 1.5

export (bool) var is_start_an_entry = true
export (bool) var is_end_an_entry = true

var _start: Detector
var _end: Detector
var _travelers: Dictionary
var _mem: Array

enum _Travel { START_TO_END, END_TO_START }

func _new_detector(position: Vector2, look: Vector2) -> Detector:
	var detector := Detector.new()
	detector.position = position
	detector.rotation = look.angle()
	add_child(detector)
	return detector

func _ready():
	var curve := get_curve()
	var index_pre_last := curve.get_point_count() - 2
	var first := curve.interpolate(0, 0)
	var second := curve.interpolate(0, 1)
	var pre_last := curve.interpolate(index_pre_last, 0)
	var last := curve.interpolate(index_pre_last, 1)
	_start = _new_detector(first, second - first)
	_start.connect("capture", self, "_capture_with_start")
	_end = _new_detector(last, pre_last - last)
	_end.connect("capture", self, "_capture_with_end")

func _update_entries():
	_start.enable(is_start_an_entry)
	_end.enable(is_end_an_entry)

func _get_start_exit_normal() -> Vector2:
	var curve := get_curve()
	var first := curve.interpolate(0, 0)
	var second := curve.interpolate(0, 1)
	return (first - second).normalized()

func _get_end_exit_normal() -> Vector2:
	var curve := get_curve()
	var index_pre_last := curve.get_point_count() - 2
	var pre_last := curve.interpolate(index_pre_last, 0)
	var last := curve.interpolate(index_pre_last, 1)
	return (last - pre_last).normalized()

func _release(captive: PathFollow2D):
	var t: RemoteTransform2D = captive.get_child(0)
	var jumper: Jumper = get_node(t.remote_path)
	jumper.collision_layer = 1
	jumper.unfreeze()
	if _travelers[jumper] == _Travel.END_TO_START:
		jumper.velocity = SPIT_SPEED * _get_start_exit_normal()
	else:
		jumper.velocity = SPIT_SPEED * _get_end_exit_normal()
	_mem.push_back(jumper)
	var forget := Timer.new()
	_mem.push_back(forget)
	add_child(forget)
	forget.connect("timeout", self, "_forget_traveler")
	forget.start(FORGET_DELAY)
	forget.one_shot = true
	captive.queue_free()

func _forget_traveler():
	_travelers.erase(_mem.front())
	_mem.pop_front()
	_mem.front().queue_free()
	_mem.pop_front()

func _update_captive(delta: float, captive: PathFollow2D):
	var t: RemoteTransform2D = captive.get_child(0)
	var jumper: Jumper = get_node(t.remote_path)
	var travel: int = _travelers[jumper]
	
	match travel:
		_Travel.START_TO_END:
			if captive.unit_offset >= 1:
				_release(captive)
			else:
				captive.unit_offset += delta * JOURNEY_SPEED / get_curve().get_baked_length()
		_Travel.END_TO_START:
			if captive.unit_offset <= 0:
				_release(captive)
			else:
				captive.unit_offset -= delta * JOURNEY_SPEED / get_curve().get_baked_length()

func _capture_with_start(captive: Jumper):
	if not _travelers.has(captive):
		_travelers[captive] = _Travel.START_TO_END
		_consume(captive, 0)

func _capture_with_end(captive: Jumper):
	if not _travelers.has(captive):
		_travelers[captive] = _Travel.END_TO_START
		_consume(captive, 1)

func _consume(captive: Jumper, unit_offset: float):
	var follow := PathFollow2D.new()
	add_child(follow)
	var t = RemoteTransform2D.new()
	t.remote_path = captive.get_path()
	follow.add_child(t)
	t.global_rotation = captive.rotation
	t.global_scale = captive.scale
	follow.unit_offset = unit_offset
	follow.loop = false
	follow.rotate = false
	captive.freeze()
	captive.collision_layer = 0

func _process(delta: float):
	_update_entries()
	for child in get_children():
		if child is PathFollow2D:
			_update_captive(delta, child)
