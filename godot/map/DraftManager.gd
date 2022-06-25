extends Node

export var hand_node_path : NodePath
export var draft_card_scene : PackedScene

var hand
var hand_node

func _ready():
	Events.connect('continue_after_game_over', self, '_on_continue_after_game_over')
	
	global.new_session()
	hand = global.session.get_hand()
	
	hand_node = get_node(hand_node_path) # WARNING is this node ready here?
	
	self.populate_hand()
	
	yield(get_tree().create_timer(3), "timeout")
	global.arena.spawn_all_ships(true)

func _on_continue_after_game_over(session_ended):
	if not session_ended:
		pick_next_card()
	else:
		pass # end of session -> new card etc
		
func pick_next_minigame():
	var picked_card = global.session.choose_next_card()
	yield(get_tree().create_timer(1), "timeout")
	
func pick_next_card():
	pass

func populate_hand():
	var i = 0
	for card in hand:
		var draft_card = draft_card_scene.instance()
		draft_card.set_minigame_label(card.get_name())
		draft_card.position.x = 700*i - 1050
		hand_node.add_child(draft_card)
		yield(get_tree().create_timer(0.2), "timeout")
		draft_card.reveal()
		i += 1
