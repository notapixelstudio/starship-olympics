extends Node2D

class_name Bar

const max_bar_width = 940
const bar_height = 20
const ministar_width = 20
const margin_left = 20
const margin_top = 10

const Star = preload('res://special_scenes/combat_UI/session_points/Star.tscn')

onready var progressbar = $ProgressBar
onready var sprite = $Ship/Sprite

onready var ministar_margin = ministar_width * global.win

var sprite_off
var sprite_on
var player
var new_position setget change_position
var current_value = 0

func initialize(p: PlayerStats, matchscore: MatchScores):
	player = p
	var species = player.species
	progressbar.modulate = species.color
	progressbar.max_value = matchscore.target_score
	
	progressbar.rect_size.x = max_bar_width - ministar_margin
	sprite_on = species.ship
	sprite_off = species.ship_off
	sprite.texture = sprite_off
	
	# ticks
	if matchscore.target_score != 100: # FIXME workaround for star sports
		for i in range(1, int(matchscore.target_score)):
			var tick = Line2D.new()
			var opacity = 1 if matchscore.target_score <= 10 or i%10 == 0 else 0.2
			tick.default_color = Color(0,0,0,opacity)
			tick.width = 3
			var x = round((max_bar_width - ministar_margin) / matchscore.target_score * i)
			tick.points = PoolVector2Array([Vector2(margin_left+x, margin_top), Vector2(margin_left+x, margin_top+bar_height)])
			$Ticks.add_child(tick)
	
	# mini stars
	for i in range(global.win):
		var star = Star.instance()
		star.scale = Vector2(0.18,0.18)
		star.position.x = margin_left + max_bar_width - ministar_margin + i*ministar_width + 18
		star.position.y = 18
		add_child(star)
		
	update_stars()
	
func update_stars():
	var stars = []
	for node in get_children():
		if node is StarIcon:
			stars.append(node)
			
	for i in range(global.win):
		if i < player.session_score:
			stars[i].won = true
	
func set_value(value):
	# round to 2 decimal digit
	if stepify(value, 0.01) > current_value:
		sprite.texture = sprite_on
	else:
		sprite.texture = sprite_off
	current_value = value
	progressbar.value = value
	$Ship.position.x = margin_left + current_value*progressbar.rect_size.x/progressbar.max_value
	
func get_value():
	return current_value

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()
	
