extends Control

export var gamemode : Resource setget set_gamemode

onready var animator = $AnimationPlayer

var array_players = [] # Array of InfoPlayers
var draft_card = null

##  signal to emit when we are ready to fight
signal ready_to_fight

func _ready():
	set_process_input(false)
	refresh()
	$Continue.modulate *= Color(1,1,1,0)


func refresh():
	if not is_inside_tree():
		yield(self, 'ready')
	$Label.text = tr(gamemode.name)
	$LabelShadow.text = tr(gamemode.name)
	var label_width = $Label.get("custom_fonts/font").get_string_size(tr(gamemode.name)).x
	$LineLeft.position.x = -62 - label_width/2 - 35
	$LineRight.position.x = 998 + label_width/2 + 35
	
	$Winter.visible = draft_card and draft_card.is_winter()
	
func set_gamemode(value: GameMode):
	gamemode = value
	refresh()
	
func set_draft_card(v: DraftCard):
	draft_card = v
	refresh()

signal letsfight

func appears():
	if global.is_game_running():
		array_players = global.the_game.get_players()
	for p_node in $PlayersReady.get_children():
		p_node.hide()
	for player_info in array_players:
		var player_ready = $PlayersReady.get_node((player_info as InfoPlayer).id)
		$PlayersReady.get_node((player_info as InfoPlayer).id).visible= true
		$PlayersReady.get_node((player_info as InfoPlayer).id).set_player_info((player_info as InfoPlayer))
	for p_node in $PlayersReady.get_children():
		# this is just because if not, we will receive multiple signals from player_node that are 
		# not playing. TODO: might need some love
		if not p_node.visible: 
			p_node.queue_free()
	Events.connect("player_ready", self, "a_player_is_ready")
	visible = true
	$AudioStreamPlayer.play()
	$Description.type(tr(gamemode.description))
	yield($Description, "done")
	animator.play("describeme")
	
func disappears():
	animator.play("getout")
	$Continue.queue_free()
	yield(animator, "animation_finished")
	emit_signal("ready_to_fight", $PlayersReady.get_children())
	queue_free()

func demomode(demo = false):
	$Continue.visible = not demo


func _on_Description_done():
	set_process_input(true)

var players_ready = []
func a_player_is_ready(player_info: InfoPlayer):
	print(player_info.id + "is ready")
	players_ready.append(player_info)
	for p_info in array_players:
		if not p_info in players_ready:
			return false
	disappears()

func get_starting_position() -> Array:
	var wheels := []
	for p in $PlayersReady.get_children():
		var ready_wheel: PlayerReadyWheel = p
		wheels.append(ready_wheel)
	return wheels
