extends Resource
class_name Minigame
## A Minigame has a representative [member title] and a specific objective, game mechanics, aesthetics, and [member soundtrack].
## The [member icon] depicts the minigame's arena and main elements.
## The [member description] is a short summary of the minigame's objective.
## The actual game mechanics are defined in specific levels (see [Arena]).

@export var title : String = 'Title'
@export var icon: Texture
@export var description : String = 'Description'
@export var soundtrack : AudioStream

# ship configuration
@export var ship_scene : PackedScene = preload('res://godot4/actors/ships/Ship.tscn')
@export var player_brain_scene : PackedScene = preload("res://godot4/actors/brains/PlayerBrain.tscn")
@export var cpu_brain_scene : PackedScene = preload("res://godot4/actors/brains/CPUBrain.tscn")
@export var starting_weapon_scene : PackedScene
