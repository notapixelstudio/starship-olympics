extends Control

export var Minicard : PackedScene

class_name MapPanel


var player : InfoPlayer = null

var content # could be Set
var rest_text = "choose an arena"
var chosen = false
const deselected_modulate = Color(0.6,0.6,0.6,1)

func get_id() -> String:
	return self.name.to_lower()
	
func _ready():
	if player == null:
		disable()
	$Background.self_modulate = deselected_modulate

func set_chosen(chosen_):
	if not is_inside_tree():
		yield(self, "ready")
	chosen = chosen_
	if chosen:
		$Background.self_modulate = Color(1.1,1.1,1.1,1)
		$Tween.interpolate_property(self, 'rect_position',
			rect_position, Vector2(rect_position.x,-30), 0.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	else:
		$Background.self_modulate = deselected_modulate
		$Tween.interpolate_property(self, 'rect_position',
			rect_position, Vector2(rect_position.x,0), 0.5,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	
func set_player(v : InfoPlayer):
	assert(v != null)
	player = v
	$Sprite.texture = player.species.ship
	$Label.text = rest_text
	$Background.modulate = player.species.color
	
func set_content(v):
	if not is_inside_tree():
		yield(self, "ready")
	if v:
		content = v
		$Label.text = content.name
		$Info.text = content.description
		create_minicards()
	else:
		$Label.text = rest_text
		$Info.text = ""
		destroy_minicards()

func enable():
	modulate = Color(1,1,1,1)
	$Sprite.visible = true
	
func disable():
	modulate = Color(1,1,1,0.1)
	$Sprite.visible = false
	
const dx = 110
const dy = 70
func create_minicards():
	destroy_minicards() # FIXME ugly, but useful
	if not content is Set:
		return
	var i = 0
	for minigame in content.minigames:
		var minicard = Minicard.instance()
		minicard.set_content(minigame)
		$Minicards.add_child(minicard)
		minicard.position = Vector2(dx*(i%2) - dx/2, dy*floor(i/2) - dy/2)
		i += 1
	
func destroy_minicards():
	for minicard in $Minicards.get_children():
		minicard.queue_free()
	
func get_minicards():
	return $Minicards.get_children()

