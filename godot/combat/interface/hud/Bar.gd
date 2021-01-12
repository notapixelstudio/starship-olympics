extends Node2D

class_name Bar

const max_bar_width = 940
const bar_height = 20
const ministar_width = 20
const margin_left = 20
const margin_top = 10
const streak_arrow_width = 8
var max_score

const Star = preload('res://special_scenes/combat_UI/session_points/Star.tscn')

onready var sprite = $Ship/Sprite

onready var ministar_margin = ministar_width * global.win

var player
var new_position setget change_position
var current_value = 0
var previous_value = 0
var author

var streaking = false
var current_streak_bar
var streak_start

func initialize(p: PlayerStats):
	player = p
	var species = player.species
	max_score = global.the_match.target_score
	
	sprite.texture = species.ship
	
	# background
	$Background.rect_position = Vector2(margin_left, margin_top)
	$Background.rect_size = Vector2(max_bar_width - ministar_margin, bar_height)
	$Background.color = species.color
	
	# megabar
	$MegaBar.color = species.color
	
	# ticks
	for i in range(1, int(max_score)):
		var tick = Line2D.new()
		var opacity = 0.8 if max_score <= 10 or i%10 == 0 else (0.2 if max_score < 100 else 0)
		tick.default_color = Color(0,0,0,opacity)
		tick.width = 3
		var x = round((max_bar_width - ministar_margin) / max_score * i)
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
		if i < len(player.session_score):
			stars[i].won = true
			stars[i].perfect = player.session_score[i].perfect
	
func set_value(value, new_author):
	if value == current_value:
		return
		
	author = new_author
	previous_value = current_value
	current_value = clamp(value, 0, max_score)
	
	if current_value > previous_value:
		streak_on()
		
	$Ship.position.x = margin_left + (max_bar_width - ministar_margin) / max_score * current_value
	
func get_value():
	return current_value

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()
	
func streak_on():
	if not streaking:
		streaking = true
		add_streak_bar()
	$StreakTimer.start(0.5)
	update_current_streak_bar()
	update_megabar()
	
func streak_off():
	streaking = false
	
	# stop glowing for older bars
	if current_streak_bar:
		current_streak_bar.color = author.species.color

func _on_StreakTimer_timeout():
	streak_off()

func add_streak_bar():
	current_streak_bar = Polygon2D.new()
	
	# glow
	current_streak_bar.material = CanvasItemMaterial.new()
	current_streak_bar.color = GlowColor.new(author.species.color, 1.15).color
	
	streak_start = previous_value
	$Streaks.add_child(current_streak_bar)
	
func update_current_streak_bar():
	var left = margin_left + (max_bar_width - ministar_margin) / max_score * streak_start
	var right = margin_left + (max_bar_width - ministar_margin) / max_score * current_value
	current_streak_bar.polygon = PoolVector2Array([
		Vector2(left, margin_top+bar_height),
		Vector2(left, margin_top),
		Vector2(max(left,right-streak_arrow_width), margin_top),
		Vector2(right, margin_top+bar_height/2),
		Vector2(max(left,right-streak_arrow_width), margin_top+bar_height)
	])
	
func update_megabar():
	var right = margin_left + (max_bar_width - ministar_margin) / max_score * current_value
	$MegaBar.polygon = PoolVector2Array([
		Vector2(margin_left, margin_top+bar_height),
		Vector2(margin_left, margin_top),
		Vector2(max(margin_left,right-streak_arrow_width), margin_top),
		Vector2(right, margin_top+bar_height/2),
		Vector2(max(margin_left,right-streak_arrow_width), margin_top+bar_height)
	])
