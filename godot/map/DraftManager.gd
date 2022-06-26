extends Node

export var this_arena_path : NodePath
export var hand_node_path : NodePath
export var draft_card_scene : PackedScene

var this_arena
var hand_node : Node

func _ready():
	Events.connect('continue_after_game_over', self, '_on_continue_after_game_over')
	
	global.new_session()
	var hand = global.session.get_hand()
	
	this_arena = get_node(this_arena_path)
	hand_node = get_node(hand_node_path) # WARNING is this node ready here?
	
	self.populate_hand(hand)
	self.pick_next_card()
	
func _on_continue_after_game_over(session_ended):
	yield(get_tree().create_timer(1.5), "timeout") # this is also needed to wait for entering the tree
	
	var last_card_played = hand_node.get_child(0)
	hand_node.remove_child(last_card_played)
	var ships_have_to_choose = false
	 
	var hand = global.session.get_hand()
	if len(hand) == 0:
		ships_have_to_choose=true
		# TODO: duplicate of global.gd, might need some love
		var deck = global.the_game.get_deck()
		hand = deck.draw(4)
		global.session.set_hand(hand)
		self.populate_hand(hand)
		
	yield(get_tree().create_timer(1.5), "timeout") 
	
	if not session_ended:
		if ships_have_to_choose:
			this_arena.spawn_all_ships(true)
		self.pick_next_card()
	else:
		pass # end of session -> new card etc
	
func pick_next_card():
	# TBD animation
	yield(get_tree().create_timer(3), "timeout")
	
	var picked_card : Minigame = global.session.choose_next_card()
	print(picked_card.id) # TBD could be null
	Events.emit_signal("minigame_selected", picked_card)
	
func populate_hand(hand: Array):
	var i = 0
	for card in hand:
		var draft_card = draft_card_scene.instance()
		draft_card.set_minigame_label(card.get_name())
		draft_card.set_content_card(card)
		draft_card.position.x = 700*i - 1050
		hand_node.add_child(draft_card)
		yield(get_tree().create_timer(0.2), "timeout")
		draft_card.reveal()
		i += 1
