extends Minigame

@onready var obj = $Obj
@onready var show = $Show
@export var turns = 4
@onready var interval = 360/turns

var options = ["😀", "😂", "😎", "🥳", "🤖", "🧠", "🚀", "🌍", "🎯", "📚", "💡", "🔥", "🧪", "🎉", "🛠️", "🖼️", "🎮", "📈", "🕵️‍♂️", "💻"]

func _ready():
	super()
	var choice = options.pick_random()
	obj.text = choice
	show.text = choice
	obj.rotation_degrees.z = randi_range(1,turns-1)*interval

@rpc("any_peer","call_local","reliable")
func left():
	if not multiplayer.is_server(): return
	obj.rotation_degrees.z += interval
	print(obj.rotation_degrees.z)

@rpc("any_peer","call_local","reliable")
func right():
	if not multiplayer.is_server(): return
	obj.rotation_degrees.z -= interval
	print(obj.rotation_degrees.z)

@rpc("any_peer","call_local","reliable")
func middle():
	if not multiplayer.is_server(): return
	if int(round(obj.rotation_degrees.z))%360==0:
		success.emit()
	else:
		fail.emit()
