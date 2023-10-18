extends Node2D

var level_scene = preload("res://scenes/level.tscn")

var level: Level

@onready var highscore_label = $StartUILayer/StartUI/Center/HighscoreLabels/Highscore

func _ready() -> void:
	reload_level()
	Globals.highscore_changed.connect(_on_globals_highscore_changed)
	Globals.new_highscore.connect(func(): $AnimationPlayer.play("new_highscore"))
	Globals.biome_changed.connect(_on_biome_changed)
	
	var tween = Fader.fade_from_black()
	tween.finished.connect(animate_highscore)

func _on_globals_highscore_changed(value):
	Globals.highscore_changed.disconnect(_on_globals_highscore_changed)
	highscore_label.highscore = Globals.highscore
	

func _on_game_ended() -> void:
	stop_game()

func _on_fade_to_black_ended() -> void:
	reset()
	var tween = Fader.fade_from_black()
	tween.finished.connect(animate_highscore)

func _on_biome_changed(biome: Biome) -> void:
	create_tween().tween_property($BackgroundLayer/ColorRect, "color", biome.color, 0.5)

func reset() -> void:
	reload_level()
	$AnimationPlayer.play("RESET")
	Globals.reset()


func reload_level():
	if is_instance_valid(level):
		level.queue_free()
	level = level_scene.instantiate()
	level.game_ended.connect(_on_game_ended)
	add_child(level)


func _on_start_ui_gui_input(event):
	if event is InputEventMouseButton:
		start_game()

func start_game():
	if Globals.state != Globals.State.WAITING:
		return
	
	Globals.state = Globals.State.RUNNING
	
	if level:
		level.start()
		$AnimationPlayer.play("start")

func stop_game():
	if Globals.state == Globals.State.ENDED:
		return
	
	Globals.state = Globals.State.ENDED
	
	if level:
		level.stop()
	
	var tween: Tween = Fader.fade_to_black()
	tween.finished.connect(_on_fade_to_black_ended)

func animate_highscore():
	highscore_label.display_highscore()
