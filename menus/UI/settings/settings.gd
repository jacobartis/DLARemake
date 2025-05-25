extends Control

@export var master_vol:HSlider
@export var music_vol:HSlider
@export var SFX_vol:HSlider
@export var sense_slide:HSlider
var max_mouse_sense: float = 0.02

func set_bus_vol(bus_name:String,val:float):
	var bus = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus,linear_to_db(val))

func get_bus_vol(bus_name:String):
	var bus = AudioServer.get_bus_index(bus_name)
	return db_to_linear(AudioServer.get_bus_volume_db(bus))

func _on_master_vol_value_changed(value):
	set_bus_vol("Master",value/100.0)

func _on_sfx_vol_value_changed(value):
	set_bus_vol("SFX",value/100.0)

func _on_music_vol_value_changed(value):
	set_bus_vol("Music",value/100.0)

func _on_mouse_sense_value_changed(value):
	Settings.mouse_sense = value/100.0 * max_mouse_sense

func _on_close_button_pressed():
	hide()

func _on_draw():
	master_vol.value = get_bus_vol("Master")*100
	music_vol.value = get_bus_vol("Music")*100
	SFX_vol.value = get_bus_vol("SFX")*100
	sense_slide.value = (Settings.mouse_sense/max_mouse_sense)*100


func _on_audi_in_vol_value_changed(value):
	set_bus_vol("AudioIn",value/100.0)
