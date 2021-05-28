extends Control

export var Minicard : PackedScene

class_name MapPanel


var species setget set_species
onready var sprite = $Sprite
onready var desc = $Label
onready var info = $Info

var map_element setget set_map_element
var rest_text = "choose an arena"
var chosen = false setget set_chosen
onready var background = $Background
const deselected_modulate = Color(0.6,0.6,0.6,1)

func get_player() -> String:
	return self.name.to_lower()
	
func _ready():
	disable()
	background.self_modulate = deselected_modulate

func set_chosen(chosen_):
	if not is_inside_tree():
		yield(self, "ready")
	chosen = chosen_
	if chosen:
		background.self_modulate = Color(1.1,1.1,1.1,1)
		$Tween.interpolate_property(self, 'rect_position',
			rect_position, Vector2(rect_position.x,-30), 0.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	else:
		background.self_modulate = deselected_modulate
		$Tween.interpolate_property(self, 'rect_position',
			rect_position, Vector2(rect_position.x,0), 0.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	
func set_species(species_):
	if not is_inside_tree():
		yield(self, "ready")
	if species_:
		species = species_
		sprite.texture = species.ship
		desc.text = rest_text
		background.modulate = species.color
	
func set_map_element(map_element_):
	if not is_inside_tree():
		yield(self, "ready")
	if map_element_:
		map_element = map_element_
		desc.text = map_element.name
		info.text = map_element.description
		create_minicards()
	else:
		desc.text = rest_text
		info.text = ""
		destroy_minicards()

func enable():
	modulate = Color(1,1,1,1)
	sprite.visible = true
	
func disable():
	modulate = Color(1,1,1,0.1)
	sprite.visible = false
	
const dx = 110
const dy = 70
func create_minicards():
	destroy_minicards() # FIXME ugly, but useful
	if not map_element is Planet:
		return
	var i = 0
	for minigame in map_element.minigames:
		var minicard = Minicard.instance()
		minicard.status = "locked"
		
		if TheUnlocker.unlocked_games.get(minigame.get_id(), TheUnlocker.INVISIBLE) == TheUnlocker.UNLOCKED:
			minicard.status = "unlocked"
		minicard.content = minigame
		$Minicards.add_child(minicard)
		minicard.position = Vector2(dx*(i%2) - dx/2, dy*floor(i/2) - dy/2)
		i += 1
	
func destroy_minicards():
	for minicard in $Minicards.get_children():
		minicard.queue_free()
	
func get_minicards():
	return $Minicards.get_children()

