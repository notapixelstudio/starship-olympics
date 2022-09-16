extends MarginContainer

@onready var scroll_container = $Container/AutoHScrollContainer
@export var action: String :
	get:
		return action # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of _set_action
@export var device: String 
@export  (String, "custom", "keyboard", "joypad") var device_category 



func _ready():
	Events.connect("remap_event",Callable(self,"on_remap"))
	set_process_input(false)
	
func _set_action(value_):
	action = value_
	if not is_inside_tree():
		await self.ready
	setup()

func setup():
	clear()
	fill_mapping()

func clear():
	scroll_container.clear()
	
func fill_mapping():
	for event in InputMap.action_get_events(self.action):
		add_mapping_to_screen(event)

func add_mapping_to_screen(new_event: InputEvent):
	scroll_container.add_element(new_event)
	
	
func on_remap(event: InputEvent, complete_action: String, substitute=true):
	"""
	Add new mapping for the device and< action. Remove the existing mapping, 
	if any
	param: 
		complete_action : e.g. kb1_fire
	"""
	if "joypad" == self.device_category and not event is InputEventJoypadButton and not event is InputEventJoypadMotion:
			print("Can't map Input different than joypad events")
			return
	if self.device_category == "keyboard" and not event is InputEventKey:
		print("Can't map Input different than keyboard events")
		return
	
	# TODO: check if this exists already 
	for action in global.input_mapping:
		for command in global.input_mapping[action]:
			if global.event_to_text(event) == command:
				if action == complete_action:
					print("This exists already in " + action)
					return
				if substitute:
					print("found in " + action)
					global.clear_mapping(action, event)
					
	var new_control_key = global.remap_action_to(complete_action, event)
	# emit_signal("remap", action, event, substitute)
	add_mapping_to_screen(event)
	# save
	persistance.save_game()

