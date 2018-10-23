extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var buttons = get_node("Choose_container")
var num_players = 0
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func ready_to_fight(n_players):
	num_players = n_players
	buttons.get_node("Fight").text = str(n_players) + " players ready to fight!"
	yield(get_tree().create_timer(1.0), "timeout")
	for button in buttons.get_children():
		button.disabled = false

func _on_Back_pressed():
	get_tree().paused = false
	visible = false


func _on_Fight_pressed():
	# background music
	bgm.stream = load("res://assets/sounds/soundtracks/250143__foolboymedia__rave-digger.ogg")
	
	get_tree().paused = false
	global.num_players = num_players
	# needs to be on global if we want to save it
	global.level = str(num_players) + "players.tscn"
	get_tree().change_scene_to(load("res://screens/game_screen/levels/"+global.level))
