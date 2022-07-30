extends Resource

class_name DraftCard

export var minigame: Resource # Minigame
export var id : String

func get_minigame()-> Minigame:
	return (minigame as Minigame)

func get_id() -> String:
	return self.resource_path.get_basename().get_file()
