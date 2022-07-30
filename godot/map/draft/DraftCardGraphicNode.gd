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
	$Ground/Front/MinigameLabelWrapper/MinigameLabelShadow.text = name
	
func set_minigame_icon(texture):
	$Ground/Front/MinigameIcon.texture = texture
	$Ground/Front/MinigameIconShadow.texture = texture

func set_content_card(card: DraftCard):
	card_content = card
	var minigame: Minigame = card.get_minigame()
	self.set_minigame_label(minigame.get_name())
	self.set_minigame_icon(minigame.get_icon())
	$Ground/Front/MinigameLabelWrapper/NewLabel.visible = card_content.new
	$Ground/Front/Mystery.visible = card is MysteryCard
	
# @override
func tap(author):
	.tap(author)
	if author is Ship:
		Events.emit_signal("card_tapped", author, self)
		print("{minigame} tapped by {author_name}".format({"minigame": card_content.get_id(), "author_name":author.info_player.get_id()}))
