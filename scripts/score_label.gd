extends Label

var score = 0:
	set(value):
		if abs(value - score) <= 1:
			_score_interpolation = value
		else:
			create_tween().set_trans(Tween.TRANS_LINEAR).tween_property(self, "_score_interpolation", value, 0.2)
		score = value

var _score_interpolation = 0:
	set(value):
		_score_interpolation = value
		text = str(_score_interpolation)

func _ready():
	Globals.score_changed.connect(func(value): score = value)
