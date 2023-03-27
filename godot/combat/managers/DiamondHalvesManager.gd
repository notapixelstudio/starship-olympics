extends Node

export var left_icon : Texture
export var right_icon : Texture

func _ready():
	Events.connect("sth_collected", self, '_on_sth_collected')
	
func _on_sth_collected(collector, collectee):
	if not collectee is HalfDiamond:
		return
		
	var bag = collector.get_bag()
	
	if bag.is_empty():
		if collectee.left:
			collect_left(bag)
		else:
			collect_right(bag)
	else:
		if collectee.left:
			if bag.has_item_type('left'):
				collect_left(bag)
			else:
				score(collector)
		else: # collectee is right
			if bag.has_item_type('right'):
				collect_right(bag)
			else:
				score(collector)

func collect_left(bag):
	bag.set_item_type('left') 
	bag.set_image(left_icon)
	bag.increase()
	bag.modulate = Color('#00fa83')
	
func collect_right(bag):
	bag.item_type = 'right' 
	bag.set_image(right_icon)
	bag.increase()
	bag.modulate = Color('#9745cd')
	
func score(collector):
	collector.get_bag().decrease()
	global.the_match.add_score_to_team(collector.get_team(), 2)
	global.arena.show_msg(collector.get_player().species, 2, collector.position)
	
