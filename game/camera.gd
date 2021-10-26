extends Camera2D

export var acceleration := 0.3

export var aim := Vector2.ZERO

func _process(delta):
	position.y = lerp(position.y, aim.y, acceleration * delta)
	position.x = lerp(position.x, aim.x, acceleration * delta)
