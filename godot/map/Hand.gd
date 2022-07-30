extends Node2D

class_name Hand

func get_card(card_id):
	for card_pos in get_children():
		if card_pos.get_child_count() > 0:
			var card = card_pos.get_child(0)
			if card.card_content.get_id() == card_id:
				return card
				
	return null


func get_all_cards():
	var cards = []
	for card_pos in get_children():
		if card_pos.get_child_count() > 0:
			var card = card_pos.get_child(0)
			cards.append(card)
	return cards
