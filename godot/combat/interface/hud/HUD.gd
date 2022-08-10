extends Control

export var Bar = preload('res://combat/interface/hud/Bar.tscn')

var the_match: TheMatch
var draw: bool = true
var height
onready var Bars = $Bars
onready var Leading = $Content/LeaderPanel/Headshot
onready var LeadingLabel = $Content/LeaderPanel/Label
onready var TimeLeft = $Content/ModePanel/TimeLeft

const std_bar_height := 28
const team_bar_height := 20

func set_draft_card(draft_card : DraftCard):
	if draft_card == null:
		return
		
	get_node('%MinigameName').text = draft_card.get_minigame().get_name()
	$Content/ModePanel/Icon.texture = draft_card.get_minigame().get_icon()
	$Content/ModePanel/Icon.visible = true
	$Content/ModePanel/Shadow.texture = draft_card.get_minigame().get_icon()
	$Content/ModePanel/Shadow.visible = true
	get_node('%WinterLabel').visible = draft_card.is_winter()
	get_node('%PerfectionistStar').visible = draft_card.is_perfectionist()
	get_node('%PerfectionistLabel').visible = draft_card.is_perfectionist()

func _ready():
	set_process(false)

func post_ready():
	the_match = global.the_match
	the_match.connect('updated', self, '_on_matchscore_updated')
	the_match.connect('tick', self, '_on_match_tick')
	
	if the_match.time_left != -1:
		TimeLeft.text = str(the_match.time_left)
	else:
		TimeLeft.text = ''
	$Content/ModePanel/TimeLeftShadow.text = TimeLeft.text
	
	var i = 0

	for player in the_match.players.values():
		var bar = Bar.instance()
		Bars.add_child(bar)
		bar.post_ready(player)
		bar.player = player
		i+=1
		
	var y = sort_bars(true)
	
	# adjust background
	height = y
	$BarsBackground.rect_size.x = height + 36
	$BarsBottom.rect_position.x = height
	set_process(true)

func _on_match_tick(t):
	update_time_left(t)
	
func update_time_left(t):
	TimeLeft.text = str(int(ceil(t)))
	$Content/ModePanel/TimeLeftShadow.text = TimeLeft.text

func _on_matchscore_updated(author, broadcasted):
	# update scores
	var bars = Bars.get_children()
	var last_value = bars[0].get_value()
	for bar in bars:
		var player : InfoPlayer = global.the_match.get_player(bar.player.id)
		bar.set_value(player.get_score(), player if broadcasted else author)
		
	# sort_bars(false)
	
	update_leaders()
	
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
		y += std_bar_height if i == len(bars)-1 or bar.player.team != bars[i+1].player.team else team_bar_height
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
	
func update_leaders():
	var leaders = global.the_match.get_leader_players()
	if len(leaders) > 0:
		var leading: InfoPlayer = leaders[0]
		Leading.set_species(leading.species)
		var n = leading.get_species_name()
		LeadingLabel.text = leading.get_species_name()
	else:
		Leading.set_species(null)
		LeadingLabel.text = ""
