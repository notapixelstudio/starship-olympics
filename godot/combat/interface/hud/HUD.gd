extends HBoxContainer

var Bar = preload('res://combat/interface/hud/Bar.tscn')

var game_mode

func initialize(_game_mode):
	game_mode = _game_mode
	print("initializing HUD")
	$TimeLeft.text = str(int(floor(game_mode.time_left)))
	
	var i = 0
	for p_name in game_mode.scores:
		var player = game_mode.scores[p_name]
		var bar = Bar.instance()
		bar.position += Vector2(0, 25)*i
		$Bars.add_child(bar)
		bar.initialize(player.species_template.color, game_mode.TARGET_SCORE)
		bar.player = player
		i+=1
		
func _process(_delta):
	# update time left
	$TimeLeft.text = str(int(floor(game_mode.time_left)))
		
	# update scores
	var bars = $Bars.get_children()
	for bar in bars:
		var player : InfoPlayer = game_mode.scores[bar.player.species]
		bar.set_value(player.score)
	
	var old_bars = bars.duplicate()
	bars.sort_custom(self, "compare_by_score")
	var i = 0
	for bar in bars:
		bar.new_position = Vector2(0, 25)*i
		i += 1


func compare_by_score(a:Bar, b:Bar):
	if a.get_value() > b.get_value():
		return true
	else:
		return false