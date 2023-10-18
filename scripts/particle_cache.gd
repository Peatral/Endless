extends CanvasLayer

signal materials_cached()
var particle_materials: ParticleMaterialList = preload("res://assets/particle_materials/all_particle_materials.tres")

func _ready():
	for material in particle_materials.materials:
		var particle = GPUParticles2D.new()
		particle.process_material = material
		particle.one_shot = true
		particle.modulate = Color(1, 1, 1, 0)
		particle.emitting = true
		add_child(particle)
	get_tree().create_timer(1.0).timeout.connect(emit_materials_cached)

func emit_materials_cached():
	materials_cached.emit()
