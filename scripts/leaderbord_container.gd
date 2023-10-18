extends VBoxContainer

@onready var leaderboard_entry_grid = $LeaderboardEntryContainer

func _ready():
	reset()
	LootLocker.leaderboard_received.connect(parse_leaderboard)

func reset():
	for i in leaderboard_entry_grid.get_child_count():
		if i < 3:
			continue
		leaderboard_entry_grid.get_child(i).queue_free()

func parse_leaderboard(leaderboard):
	reset()
	for item in leaderboard.items:
		var item_rank = Label.new()
		item_rank.text = str(item.rank)
		
		var item_name = Label.new()
		if item.player.name:
			item_name.text = item.player.name
		else:
			item_name.text = str(item.player.id)
		
		var item_score = Label.new()
		item_score.text = str(item.score)
		
		leaderboard_entry_grid.add_child(item_rank)
		leaderboard_entry_grid.add_child(item_name)
		leaderboard_entry_grid.add_child(item_score)
		
