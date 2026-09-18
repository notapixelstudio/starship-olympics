extends Control

# based on this post and adapted to gdscript : https://www.reddit.com/r/gamemaker/comments/18isrdj/entering_initials_for_high_score_list_arcade_style/
# pixel font found here : https://frostyfreeze.itch.io/pixel-bitmap-fonts-png-xml

@onready var blink_anim: AnimationPlayer = $BlinkAnim
@onready var alphabet_letter_1: Sprite2D = $AlphabetLetter1
@onready var alphabet_letter_2: Sprite2D = $AlphabetLetter2
@onready var alphabet_letter_3: Sprite2D = $AlphabetLetter3
@onready var alphabet_letter_end: Sprite2D = $AlphabetLetterEnd

# REPLACE THIS WITH YOUR OWN INPUTS
var input_event_next_letter:= "ui_down"
var input_event_previous_letter:= "ui_up"
var input_event_accept:= "ui_accept"
var input_event_delete:= "ui_cancel"
var input_event_reset:= "ui_select"

# REMEMBERING WHAT YOU SELECTED
var input_name_array: Array
# STORING THE SELECTION INTO A SINGLE NAME
var input_name: String

# THE CURRENTLY SELECTED CHARACTER
var current_letter_selected: int = 0
# THE FRAME OF THE "END" SPRITE ON THE SPRITE SHEET
var end_sprite_index: int = 37

# EACH CHARACTER INDEX IN THE ARRAY CORRESP0NDS TO THE FRAME NUMBER OF THAT CHARACTER ON THE SPRITE SHEET
var letter_index_array:= ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9", " "]


func _ready() -> void:
	alphabet_letter_end.visible = false


func _process(_delta: float) -> void:
	# MOVE TO NEXT CHARACTER
	if input_name_array.size() == 0:
		show_letter_on_screen(alphabet_letter_1, current_letter_selected)
		show_letter_on_screen(alphabet_letter_2, 0)
		show_letter_on_screen(alphabet_letter_3, 0)
		blink_anim.play("letter1_blink")
	if input_name_array.size() == 1:
		show_letter_on_screen(alphabet_letter_1, input_name_array[0])
		show_letter_on_screen(alphabet_letter_2, current_letter_selected)
		show_letter_on_screen(alphabet_letter_3, 0)
		blink_anim.play("letter2_blink")
	if input_name_array.size() == 2:
		show_letter_on_screen(alphabet_letter_1, input_name_array[0])
		show_letter_on_screen(alphabet_letter_2, input_name_array[1])
		show_letter_on_screen(alphabet_letter_3, current_letter_selected)
		blink_anim.play("letter3_blink")
	if input_name_array.size() == 3:
		show_letter_on_screen(alphabet_letter_1, input_name_array[0])
		show_letter_on_screen(alphabet_letter_2, input_name_array[1])
		show_letter_on_screen(alphabet_letter_3, input_name_array[2])
		alphabet_letter_end.visible = true
		blink_anim.play("letterend_blink")


	if Input.is_action_just_pressed(input_event_previous_letter):
		if current_letter_selected == 0:
			current_letter_selected = letter_index_array.size() - 1
		elif current_letter_selected > 0 && current_letter_selected < letter_index_array.size():
			current_letter_selected -= 1
		blink_anim.play("RESET")


	if Input.is_action_just_pressed(input_event_next_letter):
		if current_letter_selected < letter_index_array.size() - 1:
			current_letter_selected += 1
		elif current_letter_selected == letter_index_array.size() - 1:
			current_letter_selected = 0
		blink_anim.play("RESET")


	if Input.is_action_just_pressed(input_event_accept):
		if input_name_array.size() <= 3:
			input_name_array.append(current_letter_selected)
			current_letter_selected = 0
			blink_anim.play("RESET")
		if alphabet_letter_end.visible == true:
			input_name = get_input_name()
			print("NAME: ", input_name)
			alphabet_letter_end.visible = false

	if Input.is_action_just_pressed(input_event_delete):
		if input_name_array.size() <= 3:
			input_name_array.remove_at(input_name_array.size() - 1)
			current_letter_selected = 0
			blink_anim.play("RESET")
		if alphabet_letter_end.visible == true:
			alphabet_letter_end.visible = false
	
	if Input.is_action_just_pressed(input_event_reset):
		clear_name()

func clear_name() -> void:
	input_name_array.clear()

func show_letter_on_screen(alphabet_letter: Sprite2D, index: int) -> void:
	alphabet_letter.set_frame(index)

func get_input_name() -> String:
	return letter_index_array[input_name_array[0]] + letter_index_array[input_name_array[1]] + letter_index_array[input_name_array[2]]
