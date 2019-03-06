extends Component

# intercept changes in enabled state to make children invisible if disabled
func set_enabled(value : bool):
	.set_enabled(value)
	
	$Particles2D.emitting = value
	