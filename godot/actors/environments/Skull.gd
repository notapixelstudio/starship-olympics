tool
extends Ball

var active := false

func _ready():
	Events.connect('holdable_loaded', self, '_on_holdable_loaded')
	
func _on_holdable_loaded(holdable, ship):
	if holdable == self:
		active = true
		
