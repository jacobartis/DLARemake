extends Minigame

@export var connected_obj: ThreeButtonObj
@onready var obj = $Obj
@onready var example = $Show
@export var turns = 4
@onready var interval = 360/turns

var tween: Tween
var options = ["😀", "😂", "😎", "🥳", "🤖", "🧠", "🚀", "🌍", "🎯", "📚", "💡", "🔥", "🧪", "🎉", "🛠️", "🖼️", "🎮", "📈", "🕵️‍♂️", "💻"]
var current_rot: Vector3 = Vector3(0,0,0)

func _ready():
	super()
	if connected_obj.get("func_godot_properties"):
		var obj_prop = connected_obj.get("func_godot_properties")
		if obj_prop.has("turns"):
			turns = obj_prop["turns"]
	var choice = options.pick_random()
	obj.text = choice
	example.text = choice
	current_rot.z = randi_range(1,turns-1)*interval
	obj.rotation_degrees.z = current_rot.z

func rot_tween(rot):
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(obj,"rotation_degrees",rot,.2)
	print(tween)

func left():
	current_rot.z += interval
	rot_tween(current_rot)

func right():
	current_rot.z -= interval
	rot_tween(current_rot)

func middle():
	if int(round(obj.rotation_degrees.z))%360==0:
		success.emit()
	else:
		fail.emit()
