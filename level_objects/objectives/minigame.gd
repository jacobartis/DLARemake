extends Node3D
class_name  Minigame

signal success()
signal fail()

func _ready():
	global_position = global_position+Vector3.UP*10000

func left():
	pass

func right():
	pass

func middle():
	pass
