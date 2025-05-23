extends Control

@export var end_screen: Control

func _process(delta):
	if end_screen:
		if end_screen.visible: return
	if Input.is_action_just_pressed("Pause"):
		visible = !visible
		if visible:
			Settings.free_mouse()
		else:
			Settings.clamp_mouse()

func _on_disconnect_pressed():
	MultiplayerManager._on_server_disconnected()

func _on_visibility_changed():
	if visible:
		mouse_filter = Control.MOUSE_FILTER_STOP 
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE 
