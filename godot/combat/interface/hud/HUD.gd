extends Control

export var Bar = preload('res://combat/interface/hud/Bar.tscn')

var the_match: TheMatch
var draw: bool = true
var height
onready var Bars = $Bars
onready var Leading = $Content/LeaderPanel/Headshot
onready var LeadingLabel = $Content/LeaderPanel/Label
onready var TimeLeft = $Content/ModePanel/TimeLeft

func set_planet(planet: String, mode: GameMode):
	$Content/ModePanel/PlanetName.text = (mode as GameMode).name
	$Content/ModePanel/Icon.texture = (mode as GameMode).icon
	$Content/ModePanel/Icon.visible = true
	$Content/ModePanel/Shadow.texture = (mode as GameMode).icon
	$Content/ModePanel/Shadow.visible = true

func _ready():
	set_process(false)

func initialize():
	the_match = global.the_match
	the_match.connect('updated', self, '_on_matchscore_updated')
	
	TimeLeft.text = str(the_match.time_left)
	var i = 0

	for player in the_match.player_scores:
		var bar = Bar.instance()
		Bars.add_child(bar)
		bar.initialize(player)
		bar.player = player
		i+=1
		
	var y = sort_bars(true)
	
	# adjust background
	height = 10 + y
	$BarsBackground.rect_size.y = height
	$BarsBottom.rect_position.y = height
	set_process(true)

func _process(_delta):
	# update time left
	TimeLeft.text = str(int(ceil(global.the_match.time_left)))

func _on_matchscore_updated(author, broadcasted):
	# update scores
	var bars = Bars.get_children()
	var last_value = bars[0].get_value()
	for bar in bars:
		var player : PlayerStats = global.the_match.get_player(bar.player.id)
		bar.set_value(player.team_stats.score, player if broadcasted else author)
		if last_value == bar.get_value():
			draw = true
		else:
			draw = false
		
	sort_bars(false)
	
	# leading player
	if not draw:
		var leading = bars[0]
		Leading.set_species(leading.player.species)
		LeadingLabel.text = leading.player.species_name
	else:
		Leading.set_species(null)
		LeadingLabel.text = ""
		
	# stars
	for bar in bars:
		bar.update_stars()
	
func sort_bars(instantaneous):
	var bars = Bars.get_children()
	bars.sort_custom(self, "compare_by_score_team_and_id")
	var y = 0
	var i = 0
	for bar in bars:
		var pos = Vector2(0, y)
		y += 32 if i == len(bars)-1 or bar.player.team != bars[i+1].player.team else 20
		if instantaneous:
			bar.position = pos
		else:
			bar.new_position = pos
		i += 1
		
	return y
	
func compare_by_score_team_and_id(a:Bar, b:Bar):
	var va = a.get_value()
	var vb = b.get_value()
	if va == vb:
		var ta = a.player.team
		var tb = b.player.team
		if ta == tb:
			return a.player.id < b.player.id
		else:
			return ta < tb
	else:
		return a.get_value() > b.get_value()
	
func get_height():
	return height
	
