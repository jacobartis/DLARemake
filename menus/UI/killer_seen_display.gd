extends TextureRect

var fade_in_tween: Tween
var fade_out_tween: Tween
var pulse_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pulse_tween = get_tree().create_tween()
	pulse_tween.tween_property(self,"scale",Vector2(1.5,1.5),1)
	pulse_tween.tween_property(self,"scale",Vector2(1.1,1.1),1)
	pulse_tween.set_loops()
	pulse_tween.set_trans(Tween.TRANS_QUAD)
	modulate.a = 0

func fade_in():
	if fade_out_tween:
		if fade_out_tween.is_running():
			fade_out_tween.stop()
	fade_in_tween = get_tree().create_tween()
	fade_in_tween.tween_property(self,"modulate",Color(1,1,1,1),.5)

func fade_out():
	if fade_in_tween:
		if fade_in_tween.is_running():
			fade_in_tween.stop()
	fade_out_tween = get_tree().create_tween()
	fade_out_tween.tween_property(self,"modulate",Color(1,1,1,0),.5)


func _on_tree_exiting():
	if fade_in_tween:
		fade_in_tween.kill()
	if fade_out_tween:
		fade_out_tween.kill()
	if pulse_tween:
		pulse_tween.kill()
