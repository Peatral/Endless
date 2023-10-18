extends ColorRect

func _ready():
	ParticleCache.materials_cached.connect(load_main_scene)

func load_main_scene():
	get_tree().change_scene_to_packed(preload("res://scenes/main.tscn"))
