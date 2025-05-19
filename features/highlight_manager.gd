extends Node
class_name HighlightManager

@export var highlight_mesh:MeshInstance3D

func highlight(color:Color):
	highlight_mesh.get_active_material(0).albedo_color = color
