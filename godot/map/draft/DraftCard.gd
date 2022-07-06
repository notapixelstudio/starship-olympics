extends Card

var card_content: Minigame
export var order_id : int
class_name DraftCard

func set_minigame_label(name):
	$Ground/Front/MinigameLabel.text = name
	$Ground/Front/MinigameLabelShadow.text = name
	
func set_minigame_icon(texture):
	$Ground/Front/MinigameIcon.texture = texture
	$Ground/Front/MinigameIconShadow.texture = texture

func set_content_card(card: Minigame):
	card_content = card
	self.set_minigame_label(card.get_name())
	self.set_minigame_icon(card.get_icon())
	
# @override
func tap(author):
	if author is Ship:
		ship = author
		set_player(author.get_player())
	Events.emit_signal("card_tapped", author, self)
	print("{minigame} tapped by {author_name}".format({"minigame": card_content.id, "author_name":author.info_player.id}))
