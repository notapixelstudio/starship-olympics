extends Card

var card_content: Minigame
export var order_id : int
class_name DraftCard

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

func set_content_card(card: Minigame):
	card_content = card
	self.set_minigame_label(card.get_name())
	self.set_minigame_icon(card.get_icon())
	$Ground/Front/MinigameLabelWrapper/NewLabel.visible = card_content.new
	
# @override
func tap(author):
	.tap(author)
	if author is Ship:
		Events.emit_signal("card_tapped", author, self)
		print("{minigame} tapped by {author_name}".format({"minigame": card_content.id, "author_name":author.info_player.id}))
