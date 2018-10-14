extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var buttons = get_node("Choose_container")
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func ready_to_fight(n_players):
	global.num_players = n_players
	buttons.get_node("Fight").text = str(n_players) + " " + buttons.get_node("Fight").text

func _on_Back_pressed():
	get_tree().paused = false
	visible = false


func _on_Fight_pressed():
	get_tree().paused = false
	get_tree().change_scene_to(load("res://screens/game_screen/levels/"+global.level))
