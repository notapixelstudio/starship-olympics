extends Card

var card_content: DraftCard
export var order_id : int
class_name DraftCardGraphicNode

onready var chosen : bool = false setget set_chosen

const SUIT_COLORS = {
	'diamond': Color.dodgerblue,
	'crown': Color.firebrick,
	'block': Color.darkorange,
	'heart': Color.white,
	'snake': Color.teal,
	'arrow': Color.forestgreen,
	'circle': Color.palevioletred
}

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
		get_node('%Border').self_modulate = tint
	else:
		get_node('%Border').self_modulate = Color(0,0,0,0) # invisible
	
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
			$"%SuitTopLeft".modulate = SUIT_COLORS[suit_top]
		if suit_bottom:
			$"%SuitBottomRight".texture = load("res://assets/sprites/signs/suits/"+suit_bottom+".png")
			$"%SuitBottomRight".modulate = SUIT_COLORS[suit_bottom]
	
# @override
func tap(author):
	.tap(author)
	if author is Ship:
		Events.emit_signal("card_tapped", author, self)
		print("{minigame} tapped by {author_name}".format({"minigame": card_content.get_id(), "author_name":author.info_player.get_id()}))
