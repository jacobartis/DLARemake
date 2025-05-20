extends Control

var level_id: String

func display(id:String):
	level_id = id
	var info = GameInfo.level_infos[id]
	%Background.texture = info.level_background
	%LevelName.text = info.level_name

func _on_toggled(toggled_on):
	if toggled_on:
		#Dim gray color
		modulate = Color(0.411765, 0.411765, 0.411765, .8)
	else:
		modulate = Color(1,1,1,1)
