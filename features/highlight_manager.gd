extends Node
class_name HighlightManager

@export var highlight_mesh:MeshInstance3D

func highlight(color:Color):
	highlight_mesh.get_active_material(0).albedo_color = color

func hide():
	highlight_mesh.hide()

func show():
	highlight_mesh.show()
