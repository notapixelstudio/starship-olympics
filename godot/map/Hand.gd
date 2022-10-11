extends Node2D

class_name HandNode

const SEPARATION = 600
export var size:= Vector2()

func get_size() -> Vector2:
	return size
	
func get_card(card_id):
	for card in get_children():
		if card.card_content.get_id() == card_id:
			return card
	return null
	
func update_card_positions():
	var cards = get_children()
	for i in range(len(cards)):
		var card : DraftCardGraphicNode = cards[i]
		card.reposition()
		card.position.x = (i-len(cards)/2.0+0.5)*(card.get_size().x+SEPARATION)
		#card.gracefully_go_to( Vector2( (i-len(cards)/2.0+0.5)*(card.get_size().x+SEPARATION), 0) )
		
func add_card(card:DraftCardGraphicNode):
	add_child(card)
	self.update_card_positions()
	
func get_all_cards():
	var cards = []
	for card in get_children():
		cards.append(card)
	return cards

func get_card_count():
	return get_child_count()

func get_card_index(card: DraftCardGraphicNode):
	var i= 0
	for card_in_hand in get_children():
		if card_in_hand == card:
			return i
		i+=1
	return 0
