extends Node

@export var anims: AnimationPlayer
@export var character: CharacterBody3D

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
	if character.dead:
		anims.pause()
		return
	if Vector2(character.velocity.x,character.velocity.z).length()>1:
		anims.play("RunAnims/Run")
	else:
		anims.play("IdleAnims/Idle")

func killer_update():
	if not character.can_move:
		anims.pause()
		return
	else:
		anims.play()
	if Vector2(character.velocity.x,character.velocity.z).length()>1:
		anims.play("RunAnims/Run")
	else:
		anims.play("IdleAnims/Idle")
