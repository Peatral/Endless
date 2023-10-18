extends Node

signal data_loaded(location, data)
signal data_saved(location)

func load_data(location):
	if FileAccess.file_exists(location):
		var file = FileAccess.open(location, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		file.close()
		data_loaded.emit(location, json)

func save_data(location, data):
	var file = FileAccess.open(location, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	data_saved.emit(location)
