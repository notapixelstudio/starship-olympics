extends Control

var array_levels : Array
var current_level : String 


const LEVEL_PATH = "res://combat/levels/"
var scene_in_viewport : Node
onready var level_scene = $panel/ViewportContainer/Viewport
signal arena_selected
var back = false
var can_choose = false
var these_players = {}
func _ready():
	# if you want to make the ships move. Comment the following lines
	get_tree().paused = true
	#_initialize()
	# let's wait a bit to avoid the immediate selection of the arena
	yield(get_tree().create_timer(1.0), "timeout")
	can_choose = true
	$panel/Element.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if can_choose:
			emit_signal("arena_selected")
	elif event.is_action_pressed("ui_cancel"):
		back = true
		emit_signal("arena_selected")
		
func initialize(players_scene:String="", species={}):
	these_players = species
	array_levels = global.dir_contents(LEVEL_PATH, players_scene)
	current_level = players_scene + "players_toriels_1.tscn"
	scene_in_viewport = load(LEVEL_PATH+current_level).instance()
	scene_in_viewport.mockup = true
	yield(self, "ready")
	level_scene.add_child(scene_in_viewport)
	

func _on_Element_value_changed(what):
	level_scene.remove_child(scene_in_viewport)
	scene_in_viewport = load(LEVEL_PATH+what).instance()
	scene_in_viewport.mockup = true
	scene_in_viewport.initialize(these_players)
	level_scene.add_child(scene_in_viewport)

func _exit_tree():
	get_tree().paused = false