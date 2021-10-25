extends Camera2D

export var acceleration := 0.3

onready var player := get_node("../Player")

func _process(_delta):
	position.y = lerp(position.y, player.position.y, acceleration)
	position.x = lerp(position.x, player.position.x, acceleration)
