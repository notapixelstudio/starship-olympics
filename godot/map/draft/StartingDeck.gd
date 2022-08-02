extends Resource

class_name StartingDeck

export var id : String
export var cards : Array = [Object(), Object(), Object(), Object()] # DraftCard

func get_id() -> String:
	return self.resource_path.get_basename().get_file()
	
func get_name() -> String:
	return get_id()
	
