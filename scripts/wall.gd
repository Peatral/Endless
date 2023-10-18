@tool
class_name Wall
extends StaticBody2D

signal player_exited_gap()

@onready var sprite_left = $CollisionShapeWallLeft/SpriteWallLeft
@onready var sprite_right = $CollisionShapeWallRight/SpriteWallRight

@export var texture = preload("res://assets/sprites/walls/wall_default.png") :
	set(value):
		texture = value
		call_deferred("apply_texture")

@export var gap_size = 42 :
	set(value):
		gap_size = value
		$Gap/CollisionShapeGap.shape.size.x = gap_size
		$CollisionShapeWallLeft.position.x = -44 - gap_size / 2.0
		$CollisionShapeWallRight.position.x = 44 + gap_size / 2.0


func _on_gap_body_exited(body):
	if body is Player and Globals.state == Globals.State.RUNNING:
		Globals.score += 1
		$AnimationPlayer.play("implode")
		$AudioStreamPlayer.play()
		player_exited_gap.emit()

func apply_texture():
	sprite_left.texture = texture
	sprite_right.texture = texture
