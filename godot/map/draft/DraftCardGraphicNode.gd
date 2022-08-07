extends Card

var card_content: DraftCard
export var order_id : int
class_name DraftCardGraphicNode

onready var chosen : bool = false setget set_chosen

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
		
	#$Ground/Front/Background.modulate = Color('#e6e6e6')
	$Ground/Front/Border.self_modulate = Color('#efd2a0')
	
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
		#$Ground/Front/Background.modulate = Color('#9debff')
		$Ground/Front/Border.self_modulate = Color('#9be9ff')
		
# @override
func tap(author):
	.tap(author)
	if author is Ship:
		Events.emit_signal("card_tapped", author, self)
		print("{minigame} tapped by {author_name}".format({"minigame": card_content.get_id(), "author_name":author.info_player.get_id()}))
