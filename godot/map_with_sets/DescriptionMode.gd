extends Control

@export var gamemode : Resource :
	get:
		return gamemode # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_gamemode

@onready var animator = $AnimationPlayer

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
		await self.ready
	$Label.text = tr(gamemode.name)
	$LabelShadow.text = tr(gamemode.name)
	var label_width = $Label.get("custom_fonts/font").get_string_size(tr(gamemode.name)).x
	$LineLeft.position.x = -62 - label_width/2 - 35
	$LineRight.position.x = 998 + label_width/2 + 35
	
	if draft_card:
		var suit = draft_card.get_suit_top()
		if suit: # TBD double suit
			$Label.modulate = global.SUIT_COLORS[suit]
			$LineLeft.modulate = global.SUIT_COLORS[suit]
			$LineRight.modulate = global.SUIT_COLORS[suit]
		
		$Winter.visible = draft_card.is_winter()
		$WinterShadow.visible = draft_card.is_winter()
		
		$Perfectionist.visible = draft_card.is_perfectionist()
		$PerfectionistShadow.visible = draft_card.is_perfectionist()
	
func set_gamemode(value: GameMode):
	gamemode = value
	refresh()
	
func set_draft_card(v: DraftCard):
	draft_card = v
	refresh()

signal letsfight

func appears():
	if global.is_game_running():
		array_players = global.the_game.get_human_players()
	for p_node in $PlayersReady.get_children():
		p_node.hide()
	for player_info in array_players:
		var player_ready = $PlayersReady.get_node((player_info as InfoPlayer).id)
		player_ready.visible = true
		player_ready.set_player_info((player_info as InfoPlayer))
	for p_node in $PlayersReady.get_children():
		# this is just because if not, we will receive multiple signals from player_node that are 
		# not playing. TODO: might need some love
		if not p_node.visible: 
			p_node.queue_free()
	Events.connect("player_ready",Callable(self,"a_player_is_ready"))
	visible = true
	$AudioStreamPlayer.play()
	$Description.type(tr(gamemode.description))
	await $Description.done
	animator.play("describeme")
	
	if len(array_players) == 0:
		# no human players, wait a bit then go
		await get_tree().create_timer(1.0).timeout
		disappear()
	
func disappear():
	animator.play("getout")
	$Continue.queue_free()
	await animator.animation_finished
	emit_signal("ready_to_fight")
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
	disappear()
