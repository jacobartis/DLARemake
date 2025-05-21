@tool
extends OmniLight3D

func _func_godot_apply_properties(entity_properties: Dictionary):
	print(entity_properties)
	if entity_properties.has("color"):
		var c = entity_properties["color"]
		light_color = c#Color(c.x,c.y,c.z)
	
	if entity_properties.has("range"):
		omni_range = entity_properties["range"]
	
	if entity_properties.has("attention"):
		omni_attenuation = entity_properties["attention"]
	
	if entity_properties.has("energy"):
		light_energy = entity_properties["energy"]
