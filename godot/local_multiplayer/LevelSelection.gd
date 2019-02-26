extends Control

var array_levels : Array
var current_level : String


const LEVEL_PATH = "res://combat/levels/"
var scene_in_viewport : Node
onready var level_scene = $panel/ViewportContainer/Viewport

func _ready():
	# if you want to make the ships move. Comment the following lines
	get_tree().paused = true
	_initialize()


func _initialize(players_scene:String=""):
	array_levels = global.dir_contents(LEVEL_PATH, players_scene)
	current_level = array_levels[randi()%len(array_levels)]
	scene_in_viewport = load(LEVEL_PATH+current_level).instance()
	scene_in_viewport.mockup = true
	level_scene.add_child(scene_in_viewport)
	


func _on_Element_value_changed(what):
	level_scene.remove_child(scene_in_viewport)
	scene_in_viewport = load(LEVEL_PATH+what).instance()
	scene_in_viewport.mockup = true
	level_scene.add_child(scene_in_viewport)
