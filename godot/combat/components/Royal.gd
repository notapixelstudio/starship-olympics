extends Component

var host

func _ready():
	host = ECM.E(self).get_host()
	refresh()
	
# intercept changes in enabled state to make children invisible if disabled
func set_enabled(value : bool):
	.set_enabled(value)
	
	refresh()
	
func refresh():
	$Crown.visible = enabled
	
func _process(delta):
	# keep the crown up
	$Crown.rotation = -host.rotation
