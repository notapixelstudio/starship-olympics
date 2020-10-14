extends Control

var Bar = preload('res://combat/interface/hud/Bar.tscn')

var matchscore
var draw: bool = true
onready var Bars = $Bars
onready var Leading = $Content/LeaderPanel/Headshot
onready var LeadingLabel = $Content/LeaderPanel/Label
onready var TimeLeft = $Content/ModePanel/TimeLeft
var session 

func set_planet(planet: String, mode: GameMode):
	$Content/ModePanel/PlanetName.text = planet
	$Content/ModePanel/ModeIcon.texture = (mode as GameMode).logo
	$Content/ModePanel/ModeIcon.visible = true


func _ready():
	set_process(false)

func initialize(_session: SessionScores):
	matchscore = _session.matches[0]
	matchscore.connect('updated', self, '_on_matchscore_updated')
	
	TimeLeft.text = str(int(floor(matchscore.time_left)))
	var i = 0

	for player in matchscore.player_scores:
		var bar = Bar.instance()
		bar.position += Vector2(0, 25) * i
		Bars.add_child(bar)
		bar.initialize(player, matchscore)
		bar.player = player
		i+=1
		
	# adjust background
	var h = 15 + 25 * len(matchscore.player_scores)
	$BarsBackground.rect_size.y = h
	$BarsBottom.rect_position.y = h
	set_process(true)

func _process(_delta):
	# update time left
	TimeLeft.text = str(int(ceil(matchscore.time_left)))

func _on_matchscore_updated(author):
	# update scores
	var bars = Bars.get_children()
	var last_value = bars[0].get_value()
	for bar in bars:
		var player : PlayerStats = (matchscore as MatchScores).get_player(bar.player.id)
		bar.set_value(player.team_stats.score, author)
		if last_value == bar.get_value():
			draw = true
		else:
			draw = false
		
	bars.sort_custom(self, "compare_by_score")
	var i = 0
	for bar in bars:
		bar.new_position = Vector2(0, 25)*i
		i += 1
		
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
	
func compare_by_score(a:Bar, b:Bar):
	return a.get_value() > b.get_value()
