extends Card

var card_content: Minigame
class_name DraftCard

func set_minigame_label(name):
	$Ground/Front/MinigameLabel.text = name

func set_content_card(card: Minigame):
	card_content = card
	
# @override
func tap(author):
	if author is Ship:
		ship = author
		set_player(author.get_player())
		# remove author
		author.get_parent().remove_child(author)
		

	print("{minigame} tapped by {author_name}".format({"minigame": card_content.id, "author_name":author.info_player.id}))
