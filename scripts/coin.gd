extends Area2D

func _on_body_entered(body):
	if body is Player:
		Globals.score += 5
		$AnimationPlayer.play("implode")
