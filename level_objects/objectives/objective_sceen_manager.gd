extends Node3D

enum ScreenID{
	MINI=0,
	DIS=1,
	INC=2,
	COR=3,
}

@export var minigame:Sprite3D
@export var disabled:Sprite3D
@export var incorrect:Sprite3D
@export var correct:Sprite3D

@rpc("any_peer","call_local","reliable")
func show_screen(val:int):
	hide_all()
	print(val)
	match val:
		ScreenID.MINI:
			minigame.show()
		ScreenID.DIS:
			disabled.show()
		ScreenID.INC:
			incorrect.show()
		ScreenID.COR:
			correct.show()

func hide_all():
	minigame.hide()
	disabled.hide()
	incorrect.hide()
	correct.hide()
