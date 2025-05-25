extends Area3D

@export var killer:CharacterBody3D

func _on_killer_control_dropped():
	$CollisionShape3D.disabled = false


func _on_killer_new_controller():
	$CollisionShape3D.disabled = true
