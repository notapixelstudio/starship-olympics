extends ScrollContainer

export var MinigameListItemScene : PackedScene

const CARD_POOL_PATH = "res://map/draft/pool"

func _ready():
	var pool = load(CARD_POOL_PATH+'/the_card_pool.tres')
	var minigames = pool.cards.duplicate()
	minigames.sort_custom(self, 'sort_minigames')
	
	for i in minigames.size():
		var minigame = minigames[i]
		var item = MinigameListItemScene.instance()
		item.set_minigame(minigame, pool)
		if i % 2:
			item.color = Color(0,0,0,0.2)
		$VBoxContainer.add_child(item)
		
func sort_minigames(a, b):
	return a.get_name() < b.get_name()
