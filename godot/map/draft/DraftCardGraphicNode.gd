extends Card

var card_content: DraftCard
export var order_id : int
class_name DraftCardGraphicNode

onready var chosen : bool = false setget set_chosen

signal zoomed_in

func set_chosen(v):
	chosen = v
	if not is_inside_tree():
		yield(self, "ready")
	$Ground/Select.visible = chosen
	
func set_minigame_label(name):
	$Ground/Front/MinigameLabelWrapper/MinigameLabel.text = name
	
func set_minigame_icon(texture):
	$Ground/Front/MinigameIcon.texture = texture
	$Ground/Front/MinigameIconShadow.texture = texture

func set_content_card(card: DraftCard):
	# default
	card_content = card
	var minigame: Minigame = card.get_minigame()
	if minigame:
		self.set_minigame_label(minigame.get_name())
		self.set_minigame_icon(minigame.get_icon())
		
	#$Ground/Front/Background.modulate = Color('#e0e0e0')
	var tint = card.get_tint()
	if tint:
		$'%Border'.self_modulate = tint
	else:
		$'%Border'.self_modulate = Color(0,0,0,0) # invisible
	
	# new
	get_node('%NewLabel').visible = card_content.is_new()
	
	# mystery
	$Ground/Front/Mystery.visible = card is MysteryCard
	$Ground/Front/MinigameLabelWrapper.visible = not card is MysteryCard
	$Ground/Front/MinigameIcon.visible = not card is MysteryCard
	$Ground/Front/MinigameIconShadow.visible = not card is MysteryCard
	if card is MysteryCard:
		$Ground/Front/Mystery.texture = card.get_cover()
	
	# winter
	$Ground/Front/MinigameLabelWrapper/WinterLabel.visible = card.is_winter()
	if card.is_winter():
		$Ground/Front/Border.self_modulate = Color('#9be9ff')
		$Ground/Front/Border.self_modulate.b = 1.2 # glow
		$Ground/Front/Border.z_index = -1
	
	# perfectionist
	var perfectionist := not card is MysteryCard and card.is_perfectionist()
	get_node('%PerfectionistStar').visible = perfectionist
	get_node('%PerfectionistLabel').visible = perfectionist
	if card.is_perfectionist():
		$Ground/Front/Border.self_modulate = Color('#ff5577') # takes priority over winter
		
	# suits
	if not card is MysteryCard:
		var suit_top = card.get_suit_top()
		var suit_bottom = card.get_suit_bottom()
		if suit_top:
			$"%SuitTopLeft".texture = load("res://assets/sprites/signs/suits/"+suit_top+".png")
			$'%SuitTopLeft'.self_modulate = global.SUIT_COLORS[suit_top]
			$'%Background'.self_modulate = global.SUIT_COLORS[suit_top] # TBD double color
			$'%MinigameLabel'.self_modulate = global.SUIT_COLORS[suit_top].lightened(0.2) # TBD double color
		if suit_bottom:
			$"%SuitBottomRight".texture = load("res://assets/sprites/signs/suits/"+suit_bottom+".png")
			$'%SuitBottomRight'.self_modulate = global.SUIT_COLORS[suit_bottom]
			
	
# @override
func select():
	.select()
	$"%SuitTopLeft".self_modulate = Color.white
	$"%SuitBottomRight".self_modulate = Color.white
	
# @override
func tap(author):
	.tap(author)
	if author is Ship:
		Events.emit_signal("card_tapped", author, self)
		print("{minigame} tapped by {author_name}".format({"minigame": card_content.get_id(), "author_name":author.info_player.get_id()}))

func gracefully_go_to(point: Vector2, angle: float = 0.0, duration: float = 0.5, easing = Tween.EASE_IN_OUT) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(easing)
	tween.tween_property(self, 'global_position', point, duration)
	tween.parallel().tween_property(self, 'global_rotation', angle, duration)


func gracefully_zoom_in():
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'global_position', Vector2(0, 300), 0.8)
	tween.parallel().tween_property(self, 'global_rotation', 0, 0.8)
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, 'scale', Vector2(8, 8), 2.5)
	yield(tween, "finished")
	emit_signal("zoomed_in")


func reposition():
	# called to reposition the card
	self.position = _recalculate_position_use_oval()
	self.rotation = _recalculate_rotation()

# Calculates the rotation the card should have based on its parent.
func _recalculate_rotation(index_diff = null)-> float:
	var calculated_rotation := float(self.rotation)
	calculated_rotation = 90.0 - _get_oval_angle_by_index(null, index_diff)
	return(calculated_rotation)


# Calculate the position after the rotation has been calculated that use oval shape
func _recalculate_position_use_oval(index_diff = null)-> Vector2:
	var card_position_x: float = 0.0
	var card_position_y: float = 0.0
	var hand_node = get_parent() # Should be HandNode
	# Oval hor rad, rect_size.x*0.5*1.5 it’s an empirical formula,
	# that's been tested to feel good.
	var hor_rad: float = hand_node.get_size().x * 0.5 * 1.5
	# Oval ver rad, rect_size.y * 1.5 it’s an empirical formula,
	# that's been tested to feel good.
	var ver_rad: float = hand_node.get_size().y * 1.5
	# Get the angle from the point on the oval to the center of the oval
	var angle = _get_angle_by_index(index_diff)
	var rad_angle = deg2rad(angle)
	# Get the direction vector of a point on the oval
	var oval_angle_vector = Vector2(hor_rad * cos(rad_angle),
			- ver_rad * sin(rad_angle))
	# Take the center point of the card as the starting point, the coordinates
	# of the top left corner of the card
	var left_top = Vector2(- get_size().x/2, - get_size().y/2)
	# Place the top center of the card on the oval point
	var center_top = Vector2(0, - get_size().y/2)
	# Get the angle of the card, which is different from the oval angle,
	# the card angle is the normal angle of a certain point
	var card_angle = _get_oval_angle_by_index(angle, null, hor_rad,ver_rad)
	# Displacement offset due to card rotation
	var delta_vector = left_top - center_top.rotated(deg2rad(90 - card_angle))
	# Oval center x
	var center_x = hand_node.get_size().x / 2 \
			+ hand_node.position.x # this should be 0.0
	# Oval center y, - parent_control.rect_size.y * 0.25:This method ensures that the card is moved to the proper position
	var center_y = hand_node.get_size().y * 1.5 \
			+ hand_node.position.y \
			- hand_node.get_size().y * 0.25
	card_position_x = (oval_angle_vector.x + center_x)
	card_position_y = (oval_angle_vector.y + center_y)
	return(Vector2(card_position_x, card_position_y) + delta_vector)


# Get the angle on the ellipse
func _get_angle_by_index(index_diff = null) -> float:
	var index = get_my_card_index()
	var hand = get_parent()
	var hand_size = hand.get_child_count()
	# This to prevent div/0 errors because the card will not be
	# reported when it's being dragged
	if hand_size == 0:
		hand_size = 1
	var half = (hand_size - 1) / 2.0
	var card_angle_max: float = 15
	var card_angle_min: float = 6.5
	# Angle between cards
	var card_angle = max(min(60 / hand_size, card_angle_max), card_angle_min)
	# When foucs hand, the card needs to be offset by a certain angle
	# The current practice is just to find a suitable expression function, if there is a better function, please replace this function: - sign(index_diff) * (1.95-0.3*index_diff*index_diff) * min(card_angle,5)
	if index_diff != null:
		return 90 + (half - index) * card_angle \
				- sign(index_diff) * (1.95 - 0.3 * index_diff * index_diff) \
				* min(card_angle, 5)
	else:
		return 90 + (half - index) * card_angle


# Get card angle in hand by index that use oval shape
# The angle of the normal on the ellipse
func _get_oval_angle_by_index(
		angle = null,
		index_diff = null,
		hor_rad = null,
		ver_rad = null) -> float:
	if not angle:
		# Get the angle from the point on the oval to the center of the oval
		angle = _get_angle_by_index(index_diff)
	var hand_node
	if not hor_rad:
		hand_node = get_parent()
		hor_rad = hand_node.get_size().x * 0.5 * 1.5
	if not ver_rad:
		hand_node = get_parent()
		ver_rad = hand_node.get_size().y * 1.5
	var card_angle
	if angle == 90:
		card_angle = 90
	# Convert oval angle to normal angle
	else:
		# To avoid div/0
		if hor_rad == 0:
			card_angle = 90
		else:
			card_angle = rad2deg(atan(- ver_rad / hor_rad / tan(deg2rad(angle))))
			card_angle = card_angle + 90
	return(card_angle)


# Returns the Card's index position among other card objects
func get_my_card_index() -> int:
	if get_parent().has_method('get_card_index'):
		return(get_parent().get_card_index(self))
	else:
		return(0)

