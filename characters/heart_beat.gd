extends MeshInstance3D

var max_energy: float = 2.5
var time:float = 0
var dur: float = 1

var mat: StandardMaterial3D

func _ready():
	mat = mesh.material
	
	if GameInfo.role(multiplayer.get_unique_id())=="Killer": return
	hide()

func _process(delta):
	time += delta
	mat.emission_energy_multiplier = max_energy*pingpong(time,dur)
