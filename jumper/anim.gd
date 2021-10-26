extends AnimationPlayer

onready var _jumper: Jumper = get_parent()
onready var _sprite: Sprite = get_node("../Octo")
onready var _jump_sound: AudioStreamPlayer = get_node("../Sounds/Jump")
onready var _land_sound: AudioStreamPlayer = get_node("../Sounds/Land")
onready var _bounce_sound: AudioStreamPlayer = get_node("../Sounds/Bounce")

func _on_jump():
	if not _jump_sound.playing:
		_jump_sound.play()

func _on_begin_brake():
	play("Idle")

func _on_begin_fly():
	play("Fly")

func _on_bounce():
	if not _bounce_sound.playing and not _land_sound.playing:
		_bounce_sound.play()

func _on_begin_move():
	play("Walk")

func _on_flip_left():
	_sprite.flip_h = true

func _on_flip_right():
	_sprite.flip_h = false

func _on_land():
	play("Idle")
	if not _bounce_sound.playing and not _land_sound.playing and not _jump_sound.playing:
		_land_sound.play()
