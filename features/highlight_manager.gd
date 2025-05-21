extends Node
class_name HighlightManager

@export var highlight_mesh:MeshInstance3D

func highlight(color:Color):
	highlight_mesh.get_active_material(0).albedo_color = color

func down():
	highlight_mesh.mesh.size.y = -.7

func up():
	highlight_mesh.mesh.size.y = .7

func hide():
	highlight_mesh.hide()

func show():
	highlight_mesh.show()
