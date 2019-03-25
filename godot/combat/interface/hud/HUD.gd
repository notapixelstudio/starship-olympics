extends HBoxContainer

var Bar = preload('res://combat/interface/hud/Bar.tscn')

var game_mode

func initialize(_game_mode):
	game_mode = _game_mode
	
	$TimeLeft.text = str(int(floor(game_mode.time_left)))
	
	for player in game_mode.scores:
		var bar = Bar.instance()
		$Bars.add_child(bar)
		bar.initialize(player.species_template.color, game_mode.TARGET_SCORE)
		bar.player = player
		
func _process(_delta):
	# update time left
	$TimeLeft.text = str(int(floor(game_mode.time_left)))
	
	# update scores
	for bar in $Bars.get_children():
		var player : InfoPlayer = game_mode.scores_index[bar.player.species]
		bar.set_value(player.score)
		