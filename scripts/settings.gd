extends ColorRect

@onready var player_name_input = $MarginContainer/CenterContainer/PlayerNameContainer/PlayerNameInput

var player_name_input_text = ""

func _ready():
	player_name_input.text = Globals.player_name
	player_name_input_text = Globals.player_name
	Globals.player_name_changed.connect(_on_player_name_changed)

func _on_player_name_changed(value):
	player_name_input.text = value
	player_name_input_text = value
	

func fade_in():
	$AnimationPlayer.play("show")

func fade_out():
	$AnimationPlayer.play("hide")

func toggle_visibility():
	if $AnimationPlayer.is_playing():
		return
	if not visible:
		LootLocker._get_leaderboards()
		fade_in()
	else:
		fade_out()


func _on_player_name_input_text_submitted(new_text):
	player_name_input.release_focus()
	Globals.player_name = new_text
	


func _on_player_name_submit_button_pressed():
	player_name_input.release_focus()
	Globals.player_name = player_name_input_text


func _on_player_name_input_text_changed(new_text):
	player_name_input_text = new_text


func _on_player_name_input_focus_entered():
	if not DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD) and OS.has_feature("web"):
		var n = JavaScriptBridge.eval("window.prompt('Player Name:')")
		if n:
			_on_player_name_input_text_changed(n)
			player_name_input.release_focus()
			Globals.player_name = player_name_input_text
