extends Node

const data_location = "user://data.json"

signal score_changed(value)
signal biome_changed(value)
signal highscore_changed(value)
signal new_highscore()
signal player_name_changed(value)

enum State {
	WAITING,
	RUNNING,
	PLAYER_CRASHED,
	ENDED
}

var score = 0:
	set(value):
		score = value
		score_changed.emit(value)
		if score > highscore:
			highscore = score

var new_highscore_reached = false
var highscore = 0:
	set(value):
		if not new_highscore_reached:
			new_highscore_reached = true
			new_highscore.emit()
		highscore = value
		print("Globals: setting highscore %d %s" % [highscore, "new" if not new_highscore_reached else ""])
		highscore_changed.emit(highscore)

var state: State = State.WAITING

var biomes: Array[Biome] = [
	preload("res://assets/biomes/default.tres"),
	preload("res://assets/biomes/dungeon.tres")
]

var biome: Biome = preload("res://assets/biomes/default.tres"):
	set(value):
		biome = value
		biome_changed.emit(biome)

var player_name = "":
	set(value):
		if value == player_name:
			return
		player_name = value
		save_data()
		LootLocker._change_player_name(player_name)
		player_name_changed.emit(player_name)

func _ready():
	SaveLoad.data_loaded.connect(_on_saveload_data_loaded)
	LootLocker.player_name_received.connect(_on_loot_locker_player_name_received)
	LootLocker.authenticated.connect(_on_loot_locker_authentication)
	SaveLoad.load_data(data_location)
	


func _on_loot_locker_authentication():
	LootLocker._get_player_name()


func _on_loot_locker_player_name_received(p_name):
	player_name = p_name
	save_data()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()
		get_tree().quit()


func _on_saveload_data_loaded(location, data):
	if location == data_location:
		load_data(data)


func reset():
	new_highscore_reached = false
	score = 0
	save_highscore()
	state = State.WAITING

func pick_new_random_biome():
	biome = biomes.filter(func(b): return b != biome).pick_random()

func save_highscore():
	save_data()
	LootLocker._upload_score(highscore)

func load_data(data):
	print("Globals: loading data %s" % JSON.stringify(data))
	if "highscore" in data:
		highscore = data.highscore
	if "biome" in data:
		biome = Globals.biomes[data.biome]
	if "player_name" in data:
		player_name = data.player_name
	new_highscore_reached = false

func save_data():
	var data = {
		"highscore": Globals.highscore,
		"biome": Globals.biomes.find(Globals.biome),
		"player_name": Globals.player_name
	}
	print("Globals: saving data %s" % JSON.stringify(data))
	SaveLoad.save_data(data_location, data)
