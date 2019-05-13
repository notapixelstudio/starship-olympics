extends ParallaxBackground

var scroll_x : float = 0
func _process(delta):	
	# Scroll background
	scroll_x += 80 * delta
	self.scroll_offset.x = scroll_x

