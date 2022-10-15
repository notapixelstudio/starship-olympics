extends Node2D

class_name HandNode

const SEPARATION = 600
const CARD_SEPARATION = 300 # 0.25

export var size:= Vector2()

var horizontal_radius := 321.2
var vertical_radius := 21.2


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
		var target_pos = self.calculate_pos(i)
		var target_rot = self.calculate_rot(i)
		card.reposition(target_pos, target_rot)
		# card.position.x = (i-len(cards)/2.0+0.5)*(card.get_size().x+SEPARATION)
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

func calculate_pos(index_card: int) -> Vector2:
	var angle = PI/2 + CARD_SEPARATION*(float(index_card)/2 - index_card)
	var target_position = Vector2(horizontal_radius * cos(angle), - vertical_radius * sin(angle))
	return target_position

func calculate_rot(index_card: int) -> float: 
	var angle = PI/2 + CARD_SEPARATION*(float(index_card)/2 - index_card)
	return (90 - rad2deg(angle))/4

"""
func drawcard():
	var num_cards = get_card_count()
	angle = PI/2 + CARD_SEPARATION*(float(num_cards)/2 - num_cards)
	
	var oval_angle_vector = Vector2(horizontal_radius * cos(angle), - vertical_radius * sin(angle))
	
	var target_position = oval_angle_vector - CardSize
	
	var target_rotation = (90 - rad2deg(angle))/4

	Card_Numb = 0
	for Card in get_children(): # reorganise hand
		angle = PI/2 + CARD_SEPARATION*(float(NumberCardsHand)/2 - Card_Numb)
		OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad * sin(angle))
		
		Card.targetpos = CentreCardOval + OvalAngleVector - CardSize
		Card.startrot = Card.rect_rotation
		Card.targetrot = (90 - rad2deg(angle))/4
		
		Card_Numb += 1
		
	
	return DeckSize
"""

