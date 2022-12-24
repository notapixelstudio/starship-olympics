extends ScrollContainer

export var CollectionItemScene : PackedScene

const CARD_POOL_PATH = "res://map/draft/pool"

func _ready():
	var pool = CardPool.new()
	var cards = pool.cards.duplicate()
	cards.sort_custom(self, 'sort_cards')
	
	for i in cards.size():
		var card = cards[i]
		var item = CollectionItemScene.instance()
		item.set_card(card, pool)
		if i % 2:
			item.color = Color(0,0,0,0.2)
		$VBoxContainer.add_child(item)
		
func sort_cards(a, b):
	return a.get_name() < b.get_name()
