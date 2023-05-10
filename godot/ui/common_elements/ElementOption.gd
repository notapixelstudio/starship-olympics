tool
extends GenericOption

export (OPTION_TYPE) var elem_type = OPTION_TYPE.NUMBER
export var suffix := ''
onready var value_node = $Container/ValueContainer/Value
onready var suffix_node = $Container/ValueContainer/Suffix
onready var left = $Container/ValueContainer/left
onready var right = $Container/ValueContainer/right
onready var container = $Container
onready var description_node = $Container/Description

const focus_color = Color(1,1,1)
const DELAY = 0.4
const DEADZONE = 0.1

var index_value
var min_value
var max_value
var array_value
var action_time = 0.0

func _ready():
	setup()
	
func setup():
	if not label_description:
		label_description = element_path
		
	description_node.text = label_description.to_upper()
	suffix_node.text = suffix
	
	left.disabled = false
	right.disabled = false
	self.value = node_owner.get(element_path)
	
	if elem_type == OPTION_TYPE.NUMBER:
		min_value = node_owner.get("min_"+element_path)
		max_value = node_owner.get("max_"+element_path)
		left.disabled = value <= min_value
		right.disabled = value >= max_value
	elif elem_type == OPTION_TYPE.ARRAY:
		array_value = node_owner.get("array_"+element_path)
		# get first element if there is not already set
		var default_value = node_owner.get(element_path)
		if default_value:
			self.value = default_value
		else:
			self.value = array_value[0]
		max_value = len(array_value) - 1
		min_value = 0
		index_value = array_value.find(value)
		left.disabled = index_value <= min_value
		right.disabled = index_value >= max_value
	
	value_node.text = tr(str(value))
	
func _process(_delta):
	# with this we make sure we 
	$Container/Description.text = tr(str(label_description))
	if action_time >= 0.0:
		action_time -= _delta
	if elem_type == OPTION_TYPE.ARRAY:
		if Input.is_action_pressed("ui_right") and Input.get_action_strength("ui_right") > DEADZONE and not right.disabled and action_time <= 0.0 and has_focus():
			left.disabled = false
			index_value = array_value.find(self.value)
			index_value = global.mod((index_value + 1), len(array_value))

			self.value = array_value[index_value]
			value_node.text = str(value)
			right.disabled = index_value >= max_value
			action_time = DELAY
		elif Input.is_action_pressed("ui_left") and Input.get_action_strength("ui_left") > DEADZONE and not left.disabled and action_time <= 0.0 and has_focus():
			right.disabled = false
			value = str(value_node.text)
			index_value = array_value.find(value)

			index_value = global.mod((index_value - 1), len(array_value))

			self.value = array_value[index_value]
			value_node.text = str(value)
			left.disabled = index_value <= min_value
			action_time = DELAY
	

func _input(event):
	if elem_type == OPTION_TYPE.ON_OFF:
		if event.is_action_pressed("ui_fire"):
			value = (value_node.text == 'TRUE')
			self.value = not value
			value_node.text = str(value)
			
	if elem_type == OPTION_TYPE.NUMBER:
		print("option type number");
		if event.is_action_pressed("ui_right") and not right.disabled:
			left.disabled = false
			value = int(value_node.text)
			value +=1
			self.value = value
			value_node.text = str(value)
			right.disabled = value >= max_value
			
		elif event.is_action_pressed("ui_left") and not left.disabled:
			right.disabled = false
			value = int(value_node.text)
			value -=1
			self.value = value
			value_node.text = str(value)
			left.disabled = value <= min_value
			

	node_owner.set(element_path, value)
	

func _on_Element_focus_entered():
	set_process_input(true)
	self.add_stylebox_override("panel", load("res://interface/themes/olympic/focus.tres"))
	description_node.modulate = focus_color.darkened(0.1)
	value_node.modulate = focus_color.darkened(0.1)
	value_node.set("custom_colors/font_color",Color(0,0,0))
	description_node.set("custom_colors/font_color",Color(0,0,0))

func _on_Element_focus_exited():
	self.add_stylebox_override("panel", load("res://interface/themes/olympic/normal.tres"))
	for node in container.get_children():
		node.modulate = Color(1,1,1)
	value_node.modulate = Color(1,1,1)
	value_node.set("custom_colors/font_color", null)
	description_node.set("custom_colors/font_color", null)
	set_process_input(false)


