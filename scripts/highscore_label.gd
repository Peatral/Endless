extends Label

var highscore = 0:
	set(value):
		if abs(value - highscore) <= 1:
			_highscore_interpolation = value
		else:
			create_tween().set_trans(Tween.TRANS_LINEAR).tween_property(self, "_highscore_interpolation", value, min(abs(highscore - value) / 50, 0.75))
		highscore = value

var _highscore_interpolation = 0:
	set(value):
		_highscore_interpolation = value
		text = str(_highscore_interpolation)

func display_highscore():
	highscore = Globals.highscore
