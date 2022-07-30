extends DraftCard
class_name MysteryCard

export var minigame_list : Array = []

func randomize_minigame() -> void:
	randomize()
	minigame_list.shuffle()
	print("Mystery card")
	print(minigame_list)
	minigame = minigame_list[0]

func on_card_drawn() -> void:
	randomize_minigame()
	
