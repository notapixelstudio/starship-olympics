extends Area2D

class_name Card

onready var outline = $Ground/Outline
onready var border = $Ground/Front/Border
onready var background = $Ground/Front/Background
onready var monogram = $Ground/Front/Wrapper/Monogram
onready var timer = $Timer

export (String) var content = null setget set_content, get_content

export var auto_flip_back = false setget set_auto_flip_back
export var take_ownership = false
export var multiple_owners := false
export var float_when_selected := true

signal revealing_while_undetermined
signal taken
signal revealed

var selected = false
var flipping = false
var face_down = true

var player = null setget set_player, get_player
var players := []
var ship
var character_player

func set_player(v):
	var previous_player = player
	player = v
	
	if multiple_owners:
		if player != null and not players.has(player):
			players.append(player)
	
	if take_ownership:
		if multiple_owners:
			if len(players) == 0:
				blur()
			else:
				var ids = ''
				for p in players:
					ids += '[color=#' + p.get_color().to_html() + ']' + p.get_id() + '[/color]  '
				ids = ids.strip_edges()
				monogram.bbcode_text = "[center]" + ids + "[/center]"
				monogram.visible = true
				
				self.select()
		else:
			if player == null:
				blur()
			else:
				monogram.bbcode_text = "[center]" + player.get_id() + "[/center]"
				monogram.modulate = player.species.color
				monogram.visible = true
				
				self.select()
				border.modulate = player.species.color # override color
	
	# this should be emitted here, after the value is updated correctly
	if player != previous_player and player != null:
		emit_signal('taken', self, v, ship)
	
func get_player():
	return player

func set_content(v):
	content = v
	refresh_texture()
	
func get_content():
	return content
	
func set_character_player(v):
	character_player = v
	if character_player != null:
		$Ground/Front/Character.visible = true
		$Ground/Front/Circle.visible = true
		$Ground/Front/Border.visible = true
		$Ground/Front/TopLeft.visible = true
		
		$Ground/Front/Background.self_modulate = Color(0.7,0.7,0.7)
		$Ground/Front/TopLeft/Monogram.self_modulate = Color(0.7,0.7,0.7)
		
		$Ground/Front/Background.modulate = character_player.species.color
		$Ground/Front/TopLeft/Monogram.modulate = character_player.species.color
		
		$Ground/Front/Character.texture = character_player.species.character_ok
		$Ground/Front/TopLeft/Monogram.text = character_player.get_id()
		
func get_character_player():
	return character_player
	
func _ready():
	refresh_texture()
	
func refresh_texture():
	if content:
		$Ground/Front/Figure.texture = load('res://assets/sprites/' + content + '.png')
	else:
		$Ground/Front/Figure.texture = null

func tap(author):
	# no retaking if single owner
	if (not face_down or flipping) and not multiple_owners:
		return
		
	flipping = true
	if author is Ship:
		ship = author
		set_player(author.get_player())
	
	if face_down:
		reveal()

func reveal():
	face_down = false
	if content == null:
		emit_signal('revealing_while_undetermined', self)
	$AnimationPlayer.play("Reveal")
	yield($AnimationPlayer, "animation_finished")
	flipping = false
	emit_signal("revealed")
	if not selected or float_when_selected:
		$AnimationPlayer.play("Float")
	
	if auto_flip_back:
		# reflip after 6 seconds
		timer.start(6)
	
func select():
	selected = true
	border.modulate = Color(1.3,1.1,1.0)
	border.visible = true
	if not float_when_selected:
		$AnimationPlayer.play("Stand")
	
func deselect():
	selected = false
	$AnimationPlayer.play("Float")
	
func blur():
	border.visible = false
	monogram.visible = false
	
func hide():
	timer.stop()
	if face_down:
		return
		
	flipping = true
	face_down = true
	self.set_player(null)
	self.players = []
	selected = false
	$AnimationPlayer.play_backwards("Reveal")
	yield($AnimationPlayer, "animation_finished")
	flipping = false

func equals(other_card):
	return content == other_card.content
	
func set_tint(color):
	$Ground/Front/Background.modulate = color
	
func _on_Card_body_entered(body):
	if body is Ship:
		Events.emit_signal("tappable_entered", self, body)
		
func show_tap_preview(ship : Ship):
	outline.visible = true
	outline.modulate = ship.species.color
	
func _on_ExitArea_body_exited(body):
	if body is Ship:
		Events.emit_signal("tappable_exited", self, body)
		
func hide_tap_preview():
	outline.visible = false
	
func _on_Timer_timeout():
	hide()

func set_auto_flip_back(v):
	auto_flip_back = v
	if not auto_flip_back:
		$Timer.stop()
		
func show_mark(v):
	$Ground/Front/Wrapper/Monogram.visible = true
	$Ground/Front/Wrapper/Monogram.bbcode_text = "[center]" + str(v) + "[/center]"
	
