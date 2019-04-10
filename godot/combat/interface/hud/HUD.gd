extends Control

var Bar = preload('res://combat/interface/hud/Bar.tscn')

var game_mode

onready var Bars = $Bars
onready var Leading = $Content/LeaderPanel/Headshot
onready var LeadingLabel = $Content/LeaderPanel/Label
onready var TimeLeft = $Content/ModePanel/TimeLeft

func initialize(_game_mode):
	game_mode = _game_mode
	print("initializing HUD")
	TimeLeft.text = str(int(floor(game_mode.time_left)))
	var i = 0

	for player in game_mode.scores:
		var bar = Bar.instance()
		bar.position += Vector2(0, 25)*i
		Bars.add_child(bar)
		bar.initialize(player.species_template, game_mode.TARGET_SCORE)
		bar.player = player
		i+=1
		
	# adjust background
	var h = 15 + 25 * len(game_mode.scores)
	$BarsBackground.rect_size.y = h
	$BarsBottom.rect_position.y = h

func _process(_delta):
	# update time left
	TimeLeft.text = str(int(floor(game_mode.time_left)))

	# update scores
	var bars = Bars.get_children()
	for bar in bars:
		var player : InfoPlayer = game_mode.scores_index[bar.player.species]
		bar.set_value(player.score)

	bars.sort_custom(self, "compare_by_score")
	var i = 0
	for bar in bars:
		bar.new_position = Vector2(0, 25)*i
		i += 1
		
	# leading player
	var leading = bars[0]
	Leading.set_species(leading.player.species_template)
	LeadingLabel.text = leading.player.species
	
func compare_by_score(a:Bar, b:Bar):
	if a.get_value() > b.get_value():
		return true
	else:
		return false