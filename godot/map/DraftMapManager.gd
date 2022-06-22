extends Node

func _ready():
	global.new_session()
	var hand = global.session.get_hand()
	print(hand)
