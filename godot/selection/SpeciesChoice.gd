tool
extends Control
"""
this Node is a renderer of the Species Selected. No logic in here. 
"""

export var species : Resource 
export var controls : String

onready var ship = $Ship
onready var tween = $Tween
onready var species_name = $SpeciesName/Label
onready var tagline1 = $SpeciesName/Tagline1
onready var tagline2 = $SpeciesName/Tagline2
onready var character = $Character/Character
onready var controls_sprite = $Controls 
onready var player_infotext = $PlayerInfo/PlayerID
onready var anim = $AnimationPlayer
onready var label_anim = $SpeciesName/AnimationPlayer
onready var select_rect = $SelectRect

const img_path : String = "res://assets/icon/"

func _ready():
	select_rect.visible = false
	character.modulate = Color(0.8,0.8,0.8,1)

func set_team(team_name: String):
	$TeamMode.visible = true
	$TeamMode/Label.text = ("TEAM\n" + team_name).to_upper()

func unset_team():
	$TeamMode.visible = false
	
func initialize(player_id:String):
	"""
	Factory for controls and species resource
	"""
	player_infotext.text = player_id
	controls_sprite.texture = load(img_path + controls + ".png")
	
func change_species(new_species:SpeciesTemplate):
	species = new_species
	ship.texture = species.ship
	species_name.text = species.species_name.to_upper()
	#forcing multiple line
	tagline1.text = tr(species.tagline1.replace(" ", "\n"))
	tagline2.text = species.tagline2
	character.texture = species.character_ok
	select_rect.modulate = species.color

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
	$PlayerInfo.visible = true
	$LeftArrow.enable()
	$RightArrow.enable()
	anim.play("standby")
	set_process_input(true)
	set_process(true)
	
func disable():
	$PlayerInfo.visible = false
	$LeftArrow.disable()
	$RightArrow.disable()
	anim.stop()
	set_process_input(false)
	set_process(false)
	