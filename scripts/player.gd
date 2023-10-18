class_name Player
extends CharacterBody2D

signal crashed

var target_position: Vector2 = Vector2.ZERO
var speed = 0.5
var moving = false

func _physics_process(delta):
	if not moving:
		return
	
	velocity = Vector2(-(position.x - target_position.x) * 0.02, -speed)
	rotate((get_angle_to(Vector2(position.x if abs(position.x - target_position.x) < 12.5 else target_position.x, position.y - 37.5)) + PI/2) * 0.3)
	var colliding = move_and_collide(velocity)
	if colliding:
		moving = false
		$Fire.emitting = true
		$AudioStreamPlayer2D.play()
		crashed.emit()
