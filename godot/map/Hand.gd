extends Node2D

class_name HandNode

const SEPARATION = 600
const CARD_SEPARATION_ANGLE = 1.8

export var size:= Vector2()

var horizontal_radius := 2200.0
var vertical_radius := 300.0


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
		print("number of cards {cards} with angle {angle}".format({"cards": self.get_card_count(), "angle": rad2deg(self.calculate_angle(i))}))
		card.reposition(target_pos, target_rot)
		# card.position.x = (i-len(cards)/2.0+0.5)*(card.get_size().x+SEPARATION)
		#card.gracefully_go_to( Vector2( (i-len(cards)/2.0+0.5)*(card.get_size().x+SEPARATION), 0) )
		
func add_card(card:DraftCardGraphicNode):
	add_child(card)
	self.update_card_positions()

func remove_card(card:DraftCardGraphicNode):
	remove_child(card)
	card.queue_free()
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

var values = [[0], [-1,1], [-1,0,1],[-2,-1,1,2],[-2,-1,0,1,2]]
# we can take inspiration from: https://github.com/db0/godot-card-game-framework/blob/f58bbc3e9ac5010f6e213189f0796042bd3ec24c/src/core/CardTemplate.gd#L2678
func calculate_angle(index_card: int) -> float:
	var num_cards = self.get_card_count()
	var half = (num_cards - 1) / 2.0
	var card_angle_max: float = 15
	var card_angle_min: float = 6.5
	# Angle between cards
	var card_angle = max(min(60 / num_cards, card_angle_max), card_angle_min)
	return deg2rad(90 + CARD_SEPARATION_ANGLE*(half - index_card) * card_angle )
	# return deg2rad(card_angle)
	# return PI/2 + CARD_SEPARATION*(float(index_card - self.get_card_count())/2 + 0.5)
	
func calculate_pos(index_card: int) -> Vector2:
	# (i-len(cards)/2.0+0.5)*(card.get_size().x+SEPARATION)
	var angle = self.calculate_angle(index_card)
	# var target_position = (i-self.get_cards/2.0+0.5)*(card.get_size().x+SEPARATION)
	var target_position = Vector2(horizontal_radius * cos(angle), - vertical_radius * sin(angle))
	return target_position 

func calculate_rot(index_card: int) -> float: 
	var angle = self.calculate_angle(index_card)
	return (90 - rad2deg(angle))/4
