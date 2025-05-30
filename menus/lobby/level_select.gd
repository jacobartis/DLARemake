extends Panel
signal level_selected(level_id:String)

@export var level_button:PackedScene
@export var display:Button

func _ready():
	if not multiplayer.is_server(): return
	var first = null
	for level_id in GameInfo.level_infos:
		var button = level_button.instantiate()
		button.display(level_id)
		button.button_up.connect(level_pressed.bind(button))
		%LevelContainer.add_child(button)
		if !first: first = button
	first.button_pressed = true
	level_pressed(first)

func level_pressed(button):
	print(button)
	for but in get_tree().get_nodes_in_group("level_button"):
		if but == button: 
			but.button_pressed = true
			continue
		but.button_pressed = false
	level_selected.emit(button.level_id)
	update_display(button.level_id)
	hide()

func update_display(id:String):
	var info = GameInfo.level_infos[id]
	display.icon = info.level_background
	display.text = info.level_name
