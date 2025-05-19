extends Node

@export var anims: AnimationPlayer
@export var char: CharacterBody3D

@export_enum("Killer","Survivor") var char_type = 0

func is_authority():
	return get_multiplayer_authority()==multiplayer.get_unique_id()

func _process(delta):
	if not is_authority(): return
	if char_type==1:
		survivor_update()
	else:
		killer_update()

func survivor_update():
	if char.dead:
		anims.pause()
		return
	if Vector2(char.velocity.x,char.velocity.z).length()>1:
		anims.play("RunAnims/Run")
	else:
		anims.play("IdleAnims/Idle")

func killer_update():
	if not char.can_move:
		anims.pause()
		return
	else:
		anims.play()
	if Vector2(char.velocity.x,char.velocity.z).length()>1:
		anims.play("RunAnims/Run")
	else:
		anims.play("IdleAnims/Idle")
