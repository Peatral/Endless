extends CanvasLayer

@onready var rect: ColorRect = $Fader

func fade_to_black(duration: float = 1.0) -> Tween:
	rect.color = Color(0, 0, 0, 0)
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(rect, "color", Color(0, 0, 0, 1), duration)
	return tween

func fade_from_black(duration: float = 1.0) -> Tween:
	rect.color = Color(0, 0, 0, 1)
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(rect, "color", Color(0, 0, 0, 0), duration)
	return tween
