class_name Detector
extends Node2D

const ENTRY_RADIUS: int = 20
const DETECTION_RADIUS: float = 20.0

signal capture(captive)

var _first: RayCast2D
var _second: RayCast2D
var _third: RayCast2D

func enable(value: bool):
	for raycast in [_first, _second, _third]:
		raycast.enabled = value

func _new_raycast(y: float) -> RayCast2D:
	var raycast := RayCast2D.new()
	raycast.collision_mask = 0b10000_00000_10000_00000
	raycast.cast_to = Vector2.RIGHT * DETECTION_RADIUS * 2
	raycast.position = Vector2(-DETECTION_RADIUS, y)
	return raycast

func _ready():
	_first = _new_raycast(-ENTRY_RADIUS)
	_second = _new_raycast(0)
	_third = _new_raycast(ENTRY_RADIUS)
	for raycast in [_first, _second, _third]:
		add_child(raycast)

func _process(_delta):
	for raycast in [_first, _second, _third]:
		var collider = raycast.get_collider()
		if collider is Jumper:
			emit_signal("capture", collider)
			return
