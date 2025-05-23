extends Node
class_name HighlightManager

@export var highlight_node:Node3D

func highlight(color:Color):
	if highlight_node is MeshInstance3D:
		highlight_node.get_active_material(0).albedo_color = color
	elif highlight_node is Sprite3D:
		highlight_node.modulate = color

func down():
	if highlight_node is Sprite3D:
		highlight_node.flip_v = false
		return
	highlight_node.rotation_degrees.y = -180

func up():
	if highlight_node is Sprite3D:
		highlight_node.flip_v = true
		return
	highlight_node.rotation_degrees.y = 0


func hide():
	highlight_node.hide()

func show():
	highlight_node.show()
