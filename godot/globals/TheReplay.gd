extends Node
# This script handles scores and in-game stats

class_name TheReplay

class ReplayableElement:
	var timestamp: int
	var type: String
	var position: Vector2
	var rotation: float
	var extra
	
	func setup(ts, what, where, angle, extra = null):
		self.timestamp = ts
		self.type = what
		self.position = where
		self.rotation = angle
		self.extra = extra
	
	func to_dict() -> Dictionary:
		return {
			"type" : self.type,
			"position": var2str(self.position),
			"rotation": self.rotation,
			"arguments": self.extra
		}
		
class ReplayData:
	var timestamp : int
	var elements := [] # List[ReplayableElement]
	
	func to_dict() -> Dictionary:
		return {
			"timestamp": self.timestamp,
			"elements": self.elements
		}
	func add_element(element_dict: Dictionary) -> void:
		self.elements.append(element_dict)

var replay_data = [] # List[ReplayData]

func start():
	global.add_child(self)
	set_process(true)

func stop():
	set_process(false)

func update(delta):
	var timestamp = OS.get_ticks_msec()
	var data = ReplayData.new()
	data.timestamp = timestamp
	for element in get_tree().get_nodes_in_group("replayable"):
		var repl_elem = ReplayableElement.new()
		var extra = {}
		if element.has_method("get_extra_info"):
			extra = element.get_extra_info()
		repl_elem.setup(timestamp, element.get_class(), element.get_position(), element.get_rotation(), extra)
		data.add_element(repl_elem.to_dict())
	
	replay_data.append(data.to_dict())
	

func to_dict() -> Dictionary:
	return {"minigame": global.the_match.this_game_mode.get_id(), "data":self.replay_data}
