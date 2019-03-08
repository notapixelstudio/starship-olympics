extends Component

var host

func _ready():
	host = ECM.E(self).get_host()
	print('and the host is...', host)
	
	disable()
	
# intercept changes in enabled state to make children invisible if disabled
func set_enabled(value : bool):
	.set_enabled(value)
	
	$Crown.visible = value
	
func _process(delta):
	# keep the crown up
	$Crown.rotation = -host.rotation
