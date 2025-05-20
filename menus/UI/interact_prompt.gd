extends Control

var point_interact
var area_interact

func get_interactable():
	
	if point_interact: return point_interact
	if area_interact: return area_interact
	return null

func show_text(req,msg):
	var button = InputMap.action_get_events("Interact")[0].as_text().rstrip(" (Physical)")
	%Label.text = "{r} {b} to {m}".format({"r":req,"b":button,"m":msg})
	show()

func _process(delta):
	if not get_interactable():
		hide()
		return
	var type = get_interactable().type
	var msg = get_interactable().interact_message
	show_text(type,msg)
