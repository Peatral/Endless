extends Node

var lootlocker_file = "user://lootlocker.data"

var game_API_key = OS.get_environment("lootlocker_api_key")
var development_mode = OS.is_debug_build()
var leaderboard_key = "highscore"
var session_token = ""

var auth_http = HTTPRequest.new()
var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()
var set_name_http = HTTPRequest.new()
var get_name_http = HTTPRequest.new()

signal authenticated()
signal leaderboard_received(leaderboard)
signal player_name_received(player_name)
signal player_name_changed()

var is_authenticated = false

func _ready():
	_authentication_request()

func _authentication_request():
	# Check if a player session has been saved
	var player_session_exists = false
	var player_identifier = ""
	if FileAccess.file_exists(lootlocker_file):
		var file = FileAccess.open(lootlocker_file, FileAccess.READ)
		player_identifier = file.get_as_text()
		file.close()
		if(player_identifier.length() > 1):
			player_session_exists = true
	
	## Convert data to json string:
	var data = { 
		"game_key": game_API_key, 
		"game_version": "0.0.0.1", 
		"development_mode": development_mode 
	}
	
	# If a player session already exists, send with the player identifier
	if(player_session_exists == true):
		data = { 
			"game_key": game_API_key, 
			"player_identifier": player_identifier, 
			"game_version": "0.0.0.1", 
			"development_mode": development_mode 
		}
	
	var headers = ["Content-Type: application/json"]
	auth_http = HTTPRequest.new()
	add_child(auth_http)
	auth_http.request_completed.connect(_on_authentication_request_completed)
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	print("LootLocker: authenticating")


func _on_authentication_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var file = FileAccess.open(lootlocker_file, FileAccess.WRITE)
	file.store_string(json.player_identifier)
	file.close()
	session_token = json.session_token
	auth_http.queue_free()
	is_authenticated = true
	print("LootLocker: authenticated")
	authenticated.emit()
	
	# Preload to display something in menu
	_get_leaderboards()


func _get_leaderboards():
	if not is_authenticated:
		return
	var url = "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	# Send request
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")
	print("LootLocker: retrieving leaderboard")


func _on_leaderboard_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var json = JSON.parse_string(body.get_string_from_utf8())
	leaderboard_http.queue_free()
	leaderboard_received.emit(json)
	print("LootLocker: retrieved leaderboard")


func _upload_score(score):
	if not is_authenticated:
		return
	
	var data = { 
		"score": str(score) 
	}
	var headers = [
		"Content-Type: application/json", 
		"x-session-token:"+session_token
	]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	print("LootLocker: uploading score")


func _on_upload_score_request_completed(result, response_code, headers, body) :
	var json = JSON.parse_string(body.get_string_from_utf8())
	submit_score_http.queue_free()
	print("LootLocker: uploaded score")


func _change_player_name(player_name):
	if not is_authenticated:
		return
	
	var data = { 
		"name": str(player_name) 
	}
	var url =  "https://api.lootlocker.io/game/player/name"
	var headers = [
		"Content-Type: application/json", 
		"x-session-token:"+session_token
	]
	
	# Create a request node for getting the highscore
	set_name_http = HTTPRequest.new()
	add_child(set_name_http)
	set_name_http.request_completed.connect(_on_player_set_name_request_completed)
	# Send request
	set_name_http.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))
	print("LootLocker: changing player name")


func _on_player_set_name_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	set_name_http.queue_free()
	print("LootLocker: changed player name")


func _get_player_name():
	if not is_authenticated:
		return
	
	var url = "https://api.lootlocker.io/game/player/name"
	var headers = [
		"Content-Type: application/json", 
		"x-session-token:"+session_token
	]
	
	# Create a request node for getting the highscore
	get_name_http = HTTPRequest.new()
	add_child(get_name_http)
	get_name_http.request_completed.connect(_on_player_get_name_request_completed)
	# Send request
	get_name_http.request(url, headers, HTTPClient.METHOD_GET, "")
	print("LootLocker: retrieving player name")


func _on_player_get_name_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print("LootLocker: retrieved player name")
	player_name_received.emit(json.name)
