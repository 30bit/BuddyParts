class_name Pipe
extends Node2D

export (NodePath) var journey = "../Journey"
export (Vector2) var spit_velocity = Vector2(1000, 1000)
export (float) var journey_speed = 10000

onready var _first: RayCast2D = $First
onready var _second: RayCast2D = $Second
onready var _journey: Path2D = get_node(journey)

signal capture(captive)
signal release(captive)

func _ready():
	add_exception_recursive(get_tree().root)

func add_exception_recursive(root: Node):
	if not root is Jumper:
		_first.add_exception(root)
		_second.add_exception(root)
		for child in root.get_children():
			add_exception_recursive(child)

func _consume(captive: Jumper):
	var follow := PathFollow2D.new()
	follow.loop = false
	follow.rotate = false
	_journey.add_child(follow)
	var t = RemoteTransform2D.new()
	t.remote_path = captive.get_path()
	follow.add_child(t)
	captive.freeze()
	captive.collision_layer = 0
	
func _capture(captive: Jumper):
	emit_signal("capture", captive)
	_consume(captive)

func _try_capture():
	var first_collider = _first.get_collider()
	if first_collider and first_collider is Jumper:
		_capture(first_collider)
	var second_collider = _second.get_collider()
	if (second_collider 
	and second_collider is Jumper
	and second_collider != first_collider):
		_capture(second_collider)

func _process(delta: float):
	_try_capture()
	for captive in _journey.get_children():
		if captive is PathFollow2D:
			if captive.unit_offset >= 1:
				var t: RemoteTransform2D = captive.get_child(0)
				var jumper: Jumper = get_node(t.remote_path)
				jumper.collision_layer = 1
				jumper.unfreeze()
				jumper.get_node("Octo").flip_h = spit_velocity.x < 0
				jumper.velocity = spit_velocity
				emit_signal("release", jumper)
				captive.queue_free()
				return
			captive.unit_offset += delta * journey_speed / max(_journey.get_curve().get_baked_length(), 1)
		
		
