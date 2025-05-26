extends HighlightManager


func default():
	mat.albedo_color = Color.WEB_GRAY
	if GameInfo.role(multiplayer.get_unique_id())=="Killer":
		set_albedo(.2)
