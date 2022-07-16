extends Node

export var this_arena_path : NodePath
export var hand_node_path : NodePath
export var pass_path : NodePath
export var hand_position_node_path : NodePath
export var draft_card_scene : PackedScene

var this_arena
var hand_node : Node
var hand_position : Node
var pass_node : Node
var ships_have_to_choose := false
var hand_refills := 0

const HAND_SIZE = 5

var players_choices := {} # {InfoPlayer : card}

onready var tween = $Tween

signal selection_finished
signal card_chosen

func _ready():
	Events.connect('continue_after_game_over', self, '_on_continue_after_game_over')
	Events.connect("card_tapped", self, "player_just_chose_a_card")
	
	this_arena = get_node(this_arena_path)
	hand_node = get_node(hand_node_path) # WARNING is this node ready here?
	pass_node = get_node(pass_path)
	
	#pass_node.connect("tapped", self, '_on_pass_tapped')
	
	global.new_session()
	var hand = global.session.get_hand()
	self.populate_hand(hand.duplicate())
	self.pick_next_card()
	
func _on_continue_after_game_over(session_ended):
	if not is_inside_tree():
		# this happens when the map is momentarily removed at the end of a session
		yield(self, "tree_entered")
		
	if session_ended:
		self.draw_anew()
		
	yield(get_tree().create_timer(1.5), "timeout") # this is also needed to wait for entering the tree
	
	var last_match_info = global.session.get_last_match()
	
	if not session_ended:
		# cleanup if session continues
		var last_played_card = hand_node.get_card(last_match_info["minigame_id"])
		last_played_card.queue_free()
	
	ships_have_to_choose = false
	 
	var hand = global.session.get_hand()
	if len(hand) == 0:
		ships_have_to_choose = true
		
		# TODO: almost a duplicate of global.gd, might need some love
		var deck = global.the_game.get_deck()
		
		var how_many_new_cards := 1
		if hand_refills == 0:
			how_many_new_cards = 2
		
		hand = deck.draw(HAND_SIZE-how_many_new_cards)
		# add a new card and draw it right now
		deck.add_new_cards(how_many_new_cards)
		hand.append_array(deck.draw(how_many_new_cards))
		hand.shuffle()
		global.session.set_hand(hand)
		hand_refills += 1
		
		yield(get_tree().create_timer(1.0), "timeout")
		self.populate_hand(hand.duplicate())
		
	
	yield(get_tree().create_timer(1.5), "timeout") 
	
	if ships_have_to_choose:
		this_arena.spawn_all_ships(true)
		#pass_node.visible = true
	else:
		self.pick_next_card()

func draw_anew():
	global.new_session()
	global.session.discard_hand() # we don't want a normal hand, we need to add a new game first
	for c in hand_node.get_all_cards():
		c.queue_free()
		
func player_just_chose_a_card(author, card):
	card.set_player(author.get_player())
	
	self.players_choices[author] = card
	author.get_parent().remove_child(author)
	
	self.selections_maybe_all_done()
	
func selections_maybe_all_done():
	if len(players_choices.keys()) == len(global.the_game.players):
		pass_node.visible = false
		
		var discarded = []
		var hand = global.session.get_hand()
		# everyone chose. let's discard cards that have not been chosen
		for draft_card in hand_node.get_all_cards():
			if draft_card in self.players_choices.values():
				print("well, actually {card_min} has been chosen ".format({"card_min": draft_card.card_content.id}))
			else:
				discarded.append(draft_card.card_content)
				var index = hand.find(draft_card.card_content)
				hand.pop_at(index)
				
				draft_card.queue_free()
				yield(get_tree().create_timer(0.5), "timeout")
		print("In the hand there are now {num_cards} cards".format({"num_cards": len(hand)}))
		
		var deck = global.the_game.get_deck()
		
		# all discarded cards get a strike
		var to_be_put_back = []
		for card in discarded:
			card.take_strike()
			if card.has_enough_strikes():
				print(card.get_id() + ' has enough strikes and will be removed.')
			else:
				to_be_put_back.append(card)
		
		# shuffle the remaining cards right back into the deck
		deck.put_back_cards(to_be_put_back)
		deck.shuffle()
		
		self.pick_next_card()
		# empty players_choices for the next round
		self.players_choices = {}
		
	
func pick_next_card():
	# TBD animation
	yield(get_tree().create_timer(3), "timeout")
	
	var picked_card : Minigame = global.session.choose_next_card()
	
	print("Card chosen is {picked}".format({"picked":picked_card.id})) # TBD could be null
	animate_selection(picked_card)
	yield(self, "card_chosen")
	Events.emit_signal("minigame_selected", picked_card)

func add_card(card, selected=false):
	# will put the card in first empty position
	var draft_card = draft_card_scene.instance()
	draft_card.set_content_card(card)
	for pos_card in hand_node.get_children():
		if pos_card.get_child_count() == 0:
			pos_card.add_child(draft_card)
			break
	yield(get_tree().create_timer(0.5), "timeout")
	if selected:
		draft_card.select()
	draft_card.reveal()
	
func sort_hand(a, b):
	return b.new
	
func populate_hand(hand: Array):
	# shake things up
	hand.shuffle()
	
	# keep the new cards at the rightmost place
	#hand.sort_custom(self, "sort_hand")
	
	for card in hand:
		yield(get_tree().create_timer(0.1), "timeout")
		self.add_card(card, not ships_have_to_choose) # if ships have not to choose, cards are already selected
		
func animate_selection(picked_card: Minigame):
	# This will animate the selection of the chosen card
	var index_selection = 0
	var index = 0
	var chosen_card = null
	var back_pos = Vector2(0,0)
	var back_size = Vector2(1,1)

	for card in hand_node.get_all_cards():
		if card.card_content == picked_card:
			index_selection = index
			back_pos = card.global_position
			back_size = card.scale
			card.z_index = 1000
			chosen_card = card
			tween.interpolate_property(chosen_card, "global_position", chosen_card.global_position, Vector2(0,0), 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
			tween.interpolate_property(chosen_card, "scale", chosen_card.scale, Vector2(4,4), 1.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
			
			break
		index+=1
	
	random_selection(hand_node.get_all_cards(), index_selection)
	yield(self, "selection_finished")
	chosen_card.chosen = true
	var wait_time = 0.5
	yield(get_tree().create_timer(wait_time), "timeout")
	chosen_card.chosen = false
	tween.start()
	yield(tween, "tween_all_completed")
	# TODO: danger of lock
	emit_signal("card_chosen")
	yield(get_tree().create_timer(2), "timeout")
	# everything back to position
	chosen_card.global_position = back_pos
	chosen_card.scale = back_size
	chosen_card.z_index = 0
	
func random_selection(list: Array, sel_index, loops=3, max_duration=5):
	list.shuffle()
	list.resize(min(5, len(list)))
	var total_wait: float = 0
	var duration_last_loop = max_duration * 0.8
	var first_loops = max_duration-duration_last_loop
	# each elements will have this speed for the first loops
	var fastest_wait_time = first_loops / len(list) / loops
	print("duration of last loop: " + str(duration_last_loop))
	var num_iterations = len(list)*loops +sel_index
	
	for i in range(num_iterations-1):
		# print("{i}: {what} for {miniga}".format({"i": i, "what": max(fastest_wait_time, duration_last_loop * 1/(pow(2, 1 + num_iterations-i))), "miniga":list[i%len(list)].content.get_id()}))
		var wait_time = max(fastest_wait_time, duration_last_loop * 1/(pow(4, 1 + num_iterations-i)))
		list[i%len(list)].chosen = true
		yield(get_tree().create_timer(wait_time), "timeout")
		total_wait+= wait_time
		list[i%len(list)].chosen = false
	print("Waited for "+ str(total_wait))
	emit_signal("selection_finished")

func _on_pass_tapped(author):
	if author is Ship:
		self.players_choices[author] = null
		author.get_parent().remove_child(author)
		self.selections_maybe_all_done()
