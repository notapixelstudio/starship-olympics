extends Resource
class_name Minigame
## A Minigame has a representative [member title] and a specific objective, game mechanics, aesthetics, and [member soundtrack].
## The [member icon] depicts the minigame's arena and main elements.
## The [member description] is a short summary of the minigame's objective.
## The actual game mechanics are defined in specific levels (see [Arena]).

@export var title : String = 'Title'
@export var icon: Texture
@export var description : String = 'Description'
@export var starting_weapon : PackedScene
@export var soundtrack : AudioStream
