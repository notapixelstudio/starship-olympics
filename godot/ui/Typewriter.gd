extends RichTextLabel

export var voices := []
export var delay_voice := 0
export var random_voice_selection := true
signal done

onready var voice_sound = $Voice
onready var voice_timer = $VoiceDelay
var step = 0

func select_voice():
	voice_sound.set_stream(voices[step])
	step = global.mod(step+1, len(voices))
	voice_timer.start()
	
func _ready():
	voice_timer.wait_time = delay_voice
	voices.shuffle()


func type(text_to_type : String, bbcode = false):
	set_process_input(true)
	visible_characters = 0
	text = text_to_type
	bbcode_text = "[center]"+text_to_type+"[/center]"
	$Tween.interpolate_property(self, "visible_characters", 0, len(text_to_type), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.0)
	$Tween.start()
	if len(voices)>0:
		select_voice()
	

func done():
	$Tween.stop_all()
	$Tween.remove_all()
	visible_characters = -1
	if len(voices)>0:
		if voice_timer.time_left > 0:
			voice_sound.play()
			voice_timer.stop()
	else:
		emit_signal("done")
	

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process_input(false)
		self.done()

func get_text():
	return self.text

func _on_Tween_tween_all_completed():
	if voice_sound.is_playing():
		return
	else:
		emit_signal('done')


func _on_Timer_timeout():
	voice_sound.play()


func _on_Voice_finished():
	emit_signal('done')
	
