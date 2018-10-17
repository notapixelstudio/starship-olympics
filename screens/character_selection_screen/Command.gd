extends VBoxContainer

export (String) var key = "<-"
export (String) var description = "LEFT"

func _ready():
	$CenterContainer/Panel/Key.text = ""
	$Description.text = description
	
