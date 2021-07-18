tool
extends Button

class_name NavigatorButton

export var tooltip: String
export var option_menu: PackedScene
export var title: String

signal request_nav_to #asking to Session container to nav through

func _ready():
	if tooltip:
		$Tooltip.tooltip_text = tooltip
		$Tooltip.position.x = self.rect_size.x + 50
		$Tooltip.position.y = self.rect_size.y/2
		$Tooltip.visible = false
		
func _process(delta):
	self.text = tr(title.to_upper())
	
func _on_Controls_pressed():
	emit_signal("request_nav_to", title, option_menu)


func _on_NavigatorButton_focus_entered():
	$Tooltip.visible = true


func _on_NavigatorButton_focus_exited():
	$Tooltip.visible = false
