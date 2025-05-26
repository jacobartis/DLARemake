extends Node3D

@export var sfx: AudioStreamPlayer3D

@export var loops:int = 5
var curr: int = 0

@rpc("any_peer","call_local","reliable")
func play():
	curr = loops
	sfx.play()



func _on_audio_dist_finished():
	if curr <1: return
	curr -= 1
	sfx.play()
