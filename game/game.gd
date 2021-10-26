extends Node2D

enum Act { Intro, FirstLesson, SecondLesson, ThirdLesson, Oblivion }

var _executing: bool = false
var _expecting: bool = false

export (int, "Intro", "FirstLesson",  "SecondLesson", "ThirdLesson", "Oblivion") var act

func exec_intro():
	$Buddy/Octo.flip_h = true
	$Buddy/Intro.exec()
	freeze_player($Buddy/Intro.input_periods[0] + 2.7)

func finish_intro(_exec):
	_executing = false
	act = Act.FirstLesson

func exec_first_lesson():
	$Buddy/FirstLesson.exec()

func interact_first_lesson(_exec):
	_expecting = true

func expect_second_lesson():
	var dist: float = $Buddy.position.x -$Player.position.x
	if dist <= 120:
		act = Act.SecondLesson
		_executing = false
		_expecting = false

func exec_second_lesson():
	$Buddy/SecondLesson.exec()

func interact_second_lesson(exec):
	_expecting = true

func expect_third_lesson():
	var dist: float = $Buddy.position.x - $Player.position.x
	if dist <= 210:
		act = Act.ThirdLesson
		_executing = false
		_expecting = false

func exec_third_lesson():
	$Buddy/ThirdLesson.exec()
	freeze_player(12)

func kill_buddy(captive: Jumper):
	if captive.name == "Buddy":
		act = Act.Oblivion
		$Fan/Sound.play()
		$Buddy.queue_free()
		$Theme.stream = load("res://game/themes/sad.wav")
		$Theme.play()
	

func exec_oblivion():
	pass

func freeze_player(seconds: float):
	$Player.freeze_kinematics()
	$Player/Anim.play("Idle")
	$Player/Octo.flip_h = false
	$Fridge.start(seconds)

func unfreeze_player():
	$Player.unfreeze_kinematics()

func _ready():
	$Fan/Anim.play("Idle")

func _process(_delta):
	if not _executing:
		match act:
			Act.Intro:
				exec_intro()
			Act.FirstLesson:
				exec_first_lesson()
			Act.SecondLesson:
				exec_second_lesson()
			Act.ThirdLesson:
				exec_third_lesson()
			Act.Oblivion:
				exec_oblivion()
		_executing = true
	else:
		if _expecting and $Player.is_on_floor():
			match act:
				Act.FirstLesson:
					expect_second_lesson()
				Act.SecondLesson:
					expect_third_lesson()
		if (act == Act.ThirdLesson or act == Act.FirstLesson) and not _expecting:
			$Cam.aim = $Buddy.position
		else:
			$Cam.aim = $Player.position

