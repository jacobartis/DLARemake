extends Node

enum VoiceType{
	ALWAYS_ON,
	PUSH_TO_TALK,
	OFF
}

var mouse_sense: float = 0.008
var voice_type: VoiceType = VoiceType.ALWAYS_ON

func clamp_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func free_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
