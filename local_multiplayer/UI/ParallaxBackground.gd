extends ParallaxBackground

var scroll_x = 0
var scroll_y = 0
func _process(delta):	
	# Scroll background
	scroll_x += 80 * delta
	scroll_y += 40 * delta
	self.scroll_offset.x = scroll_x
	#self.scroll_offset.y = scroll_y