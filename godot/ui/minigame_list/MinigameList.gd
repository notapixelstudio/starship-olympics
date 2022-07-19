extends ScrollContainer

export var MinigameListItemScene : PackedScene

const DECK_PATH = "res://map/draft/"
const CARD_POOL_PATH = "res://map/draft/pool"

func _ready():
	var classic_minigames = load(DECK_PATH+'/classic.tres').minigames
	var pool = load(CARD_POOL_PATH+'/the_card_pool.tres')
	var minigames = classic_minigames + pool.cards
	
	for i in minigames.size():
		var minigame = minigames[i]
		var item = MinigameListItemScene.instance()
		item.set_minigame(minigame, pool)
		if i % 2:
			item.color = Color(0,0,0,0.2)
		$VBoxContainer.add_child(item)
		
