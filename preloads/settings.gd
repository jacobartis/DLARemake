extends Node

var mouse_sense: float = 0.008

func clamp_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func free_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
