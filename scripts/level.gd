class_name Level
extends Node2D

@export var player_scene: PackedScene = preload("res://scenes/player.tscn")
@export var wall_scene: PackedScene = preload("res://scenes/wall.tscn")
@export var wall_gap_size: float = 42
@export var wall_distance: float = 125

@onready var obstacles = $Obstacles

signal game_ended

var last_mouse_position: Vector2 = Vector2.ZERO
var player: Player
var vertical_camera_offset: float = 0.0



func _ready():
	randomize()
	
	last_mouse_position = $InitialPositionPlayer.global_position + Vector2(0, -13)
	vertical_camera_offset = $Camera.position.y - $InitialPositionPlayer.position.y
	
	spawn_player()
	spawn_wall($InitialPositionWall.position)
	spawn_wall(Vector2(get_random_wall_x(), $InitialPositionWall.position.y - wall_distance))

func _process(delta):
	remove_offscreen_walls()
	if player and Globals.state == Globals.State.RUNNING:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			last_mouse_position = get_viewport().get_mouse_position()
			player.target_position = Vector2(last_mouse_position.x / $Camera.zoom.x, player.position.y - 13)
		if player.moving:
			$Camera.position = Vector2($Camera.position.x, player.position.y + vertical_camera_offset)

func _on_wall_passed(wall):
	player.speed += 0.03
	var next_y = wall.position.y - wall_distance * 2
	if randf() <= 0.1:
		Globals.pick_new_random_biome()
	if randf() <= 0.2:
		call_deferred("spawn_coin", Vector2($InitialPositionPlayer.position.x, next_y - wall_distance * 0.5))
	call_deferred("spawn_wall", Vector2(get_random_wall_x(), next_y))

func _on_player_crashed():
	Globals.state = Globals.State.PLAYER_CRASHED
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Camera, "zoom", $Camera.zoom * 2, 2.0)
	tween.parallel().tween_property($Camera, "position", player.position - get_viewport_rect().size / $Camera.zoom / 4 + Vector2(0, -25), 2.0)
	tween.finished.connect(func(): game_ended.emit())

func start():
	if player:
		player.moving = true

func stop():
	if player:
		player.moving = false

func spawn_player():
	player = player_scene.instantiate()
	player.crashed.connect(_on_player_crashed)
	player.position = $InitialPositionPlayer.position
	add_child(player)

func spawn_wall(pos: Vector2):
	var wall: Wall = wall_scene.instantiate()
	wall.position = pos
	wall.gap_size = wall_gap_size
	wall.texture = Globals.biome.wall_texture
	wall.player_exited_gap.connect(func(): _on_wall_passed(wall))
	obstacles.add_child(wall)

func spawn_coin(pos: Vector2):
	var coin = preload("res://scenes/coin.tscn").instantiate()
	coin.position = pos
	obstacles.add_child(coin)

func remove_offscreen_walls():
	if obstacles.get_child_count() > 0 and obstacles.get_child(0).position.y > $Camera.position.y + get_viewport_rect().size.y / $Camera.zoom.y * 1.5:
		obstacles.get_child(0).queue_free()

func get_random_wall_x():
	return randi_range(0 + wall_gap_size * 0.75, 135 - wall_gap_size * 0.75)
