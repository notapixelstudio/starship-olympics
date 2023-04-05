extends Node

export var left_icon : Texture
export var right_icon : Texture

func _ready():
	Events.connect("sth_collected", self, '_on_sth_collected')
	Events.connect("sths_bumped", self, '_on_sths_bumped')
	
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

func _on_sths_bumped(ship1, ship2):
	if not ship1 is Ship or not ship2 is Ship:
		return
		
	var bag1 = ship1.get_bag()
	var bag2 = ship2.get_bag()
	
	if not bag1.is_empty() and not bag2.is_empty() and bag1.get_item_type() != bag2.get_item_type():
		# join diamonds
		var amount1 = bag1.get_amount()
		var amount2 = bag2.get_amount()
		var difference = amount1 - amount2
		
	# TBD swap bag?
	
func collect_left(bag):
	bag.set_item_type('left') 
	bag.set_image(left_icon)
	bag.increase()
	bag.modulate = Color('#00ea83')
	
func collect_right(bag):
	bag.item_type = 'right' 
	bag.set_image(right_icon)
	bag.increase()
	bag.modulate = Color('#c765ff')
	
func score(collector):
	collector.get_bag().decrease()
	global.the_match.add_score_to_team(collector.get_team(), 1)
	global.arena.show_msg(collector.get_player().species, 1, collector.position)
	
