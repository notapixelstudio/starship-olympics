tool
extends Control
"""
this Node is a renderer of the Species Selected. No logic in here. 
"""

export var species : Resource setget _set_species
export var controls : String

onready var ship = $Ship
onready var tween = $Tween
onready var species_name = $SpeciesName/Label
onready var character = $Character/Character
onready var controls_sprite = $Controls 
onready var player = $Player
onready var anim = $AnimationPlayer
onready var label_anim = $SpeciesName/AnimationPlayer
onready var select_rect = $SelectRect


const img_path : String = "res://assets/icon/"

func _ready():
	select_rect.visible = false
	character.modulate = Color(0.8,0.8,0.8,1)
	
func _set_species(new_value : SpeciesTemplate):
	species = new_value
	
	if not species:
		return
		
	if Engine.is_editor_hint():
		if has_node("Ship"):
	        get_node("Ship").texture = species.ship
		if has_node("Character/Character"):
	        get_node("Character/Character").texture = species.character
		if has_node("SpeciesName/Label"):
        get_node("SpeciesName/Label").text = species.species_name.to_upper()
	

func initialize(player_id:String):
	"""
	Factory for controls and species resource
	"""
	player.text = player_id
	controls_sprite.texture = load(img_path + controls + ".png")
	
func change_species(new_species:SpeciesTemplate):
	species = new_species
	ship.texture = species.ship
	species_name.text = species.species_name.to_upper()
	character.texture = species.character_ok
	select_rect.texture = species.select_rect

func previous():
	label_anim.play("shake")
	
func next():
	label_anim.play("shake")

func select():
	select_rect.visible = true
	character.modulate = Color(1,1,1,1)
	$LeftArrow.disable()
	$RightArrow.disable()

func deselect():
	select_rect.visible = false
	character.modulate = Color(0.8,0.8,0.8,1)

func enable():
	select_rect.visible = false
	character.modulate = Color(0.8,0.8,0.8,1)
	$LeftArrow.enable()
	$RightArrow.enable()
	anim.play("standby")
	set_process_input(true)
	set_process(true)
	
func disable():
	$LeftArrow.disable()
	$RightArrow.disable()
	anim.stop()
	set_process_input(false)
	set_process(false)
	