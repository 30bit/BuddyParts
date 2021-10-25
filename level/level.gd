extends Node2D

func _ready():
	for comrade in ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh"]:
		var exec: Exec = get_node("Comrades/" + comrade + "/Exec")
		exec.exec()


func _on_exec_finished(exec: Exec):
	exec.exec()
