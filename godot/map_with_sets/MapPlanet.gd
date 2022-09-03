tool
extends MapLocation

class_name MapPlanet

export var set : Resource # Set
export var cursor_scene: PackedScene
onready var sprite = $Sprite
var cursors = [] # of Cursor

var not_available = false setget set_availability

signal updated
signal unhid
signal unlocked

func get_id() -> String:
	return set.get_id()
	
func set_status(v):
	status = v
	if not is_inside_tree():
		yield(self, 'ready')
	$Lock.visible = false
	if Engine.editor_hint:
		$Sprite.modulate = Color(1,1,1,1)
	elif status == TheUnlocker.UNLOCKED:
		$Sprite.modulate = Color(1,1,1,1)
	elif status == TheUnlocker.LOCKED:
		$Sprite.modulate = Color(0,0,0,0)
		$Lock.visible = true
	else:
		$Sprite.modulate = Color(0,0,0,0)
		
	$DebugLabel.text = status
	
func set_availability(value):
	not_available = value
	if sprite:
		$NA.visible = not_available
		
func set_set(v: Set):
	assert(v is Set)
	set = v
	
func get_set():
	return set
	
func _ready():
	if set:
		sprite.texture = set.planet_sprite
		$Label.text = set.name
		$Tagline.text = set.tagline1
		$Label2.text = set.name
		$Tagline2.text = set.tagline1
	self.set_status(TheUnlocker.get_status("sets", self.get_id()))
	
func unhide():
	if status != TheUnlocker.HIDDEN:
		return
		
	$AnimationPlayer.play("Unhide")
	yield($AnimationPlayer, "animation_finished")
	self.set_status(TheUnlocker.LOCKED)
	emit_signal('unhid')
	Events.emit_signal("sth_unhid", set, self)
	for body in get_overlapping_bodies():
		if body is Ship:
			show_tap_preview(body)
			break
	
func unlock():
	if status != TheUnlocker.LOCKED:
		return
		
	$AnimationPlayer.play("Unlock")
	yield($AnimationPlayer, "animation_finished")
	TheUnlocker.unlock_element("sets", self.get_id())
	self.set_status(TheUnlocker.UNLOCKED)
	emit_signal('unlocked')
	Events.emit_signal("sth_unlocked", set, self)
	for body in get_overlapping_bodies():
		if body is Ship:
			show_tap_preview(body)
			break

func show_tap_preview(_author):
	if status == TheUnlocker.UNLOCKED:
		$Label.visible = true
		$Tagline.visible = true
		$Tagline.text = set.tagline1
		$Label2.visible = true
		$Tagline2.visible = true
		$Tagline2.text = set.tagline1
		$CameraEye.set_active(true)
	elif status == TheUnlocker.LOCKED:
		$Tagline.visible = true
		$Tagline.text = "???"
		$Tagline2.visible = true
		$Tagline2.text = "???"
	
func hide_tap_preview():
	$Label.visible = false
	$Tagline.visible = false
	$Label2.visible = false
	$Tagline2.visible = false
	$CameraEye.set_active(false)
	
func tap(author: Ship):
	if self.get_status() == TheUnlocker.UNLOCKED:
		self.land_on(author)
		
		# remove author
		author.get_parent().remove_child(author)
		
func land_on(ship: Ship):
	var cursor: MapCursor = cursor_scene.instance()
	cursor.setup(ship.info_player)
	cursor.position = self.position
	get_parent().add_child(cursor)
	cursors.append(cursor)
	
	# fan the cursors
	var i = 0
	for c in cursors:
		c.set_rotation_degrees(60*(i - len(cursors)/2.0 + 0.5))
		i+=1
	
	cursor.land()
