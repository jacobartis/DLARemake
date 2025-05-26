extends Node
class_name HighlightManager

@export var meshes:Array[MeshInstance3D] = []
var mat

func _ready():
	mat = StandardMaterial3D.new()
	mat.albedo_color.a = 0
	mat.no_depth_test = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for mesh in meshes:
		mesh.material_overlay = mat
	default()

func default():
	mat.albedo_color = Color.WHITE
	set_albedo(0)

func highlight(color:Color):
	color.a = mat.albedo_color.a
	mat.albedo_color = color

func set_albedo(a:float):
	mat.albedo_color.a = a

func hide():
	set_albedo(0)
