tool
extends Node2D
#######This code was originally written by
### Lars Kokemohr. Original Arrow plugin can be found on Godot plugin store, it's released on MIT license.
# https://bitbucket.org/lkokemohr/godot_arrow_plugin
signal removeConnectionRequest(to);

export(NodePath) var target_node_path = NodePath() setget set_target_node_path
var target_node = null
export(Vector2) var target = null setget set_target

export var closeIconActive = true;

var cached_target
var cached_pos

export(int) var width = 4 setget set_width

export(float) var start_offset = 0 setget set_start_offset
export(float) var end_offset = 0 setget set_end_offset
export(float) var side_offset = 0 setget set_side_offset

export(Color) var color = null setget set_color
export(Color) var beginningColor = null setget setBegginingColor;

export(bool) var editor_only = false
export(bool) var with_arrow = true setget setWithArrow;
var pointingOnState = true setget setPointingOnState;

onready var closeIcon = get_node("CloseIcon");

func _enter_tree():
	if is_visible():
		set_process(true)
	if(beginningColor == null):
		beginningColor = color;

func _ready():
	if is_visible():
		set_process(true);

	if(!closeIconActive):
		if(has_node("CloseIcon")):
			closeIcon.queue_free();
			closeIcon = null;



func setPointingOnState(inPointingOnState):
	pointingOnState = inPointingOnState;
	if(pointingOnState):
		end_offset = 5;

	if(pointingOnState):
		beginningColor = color;

func setWithArrow(inWithArrow):
	with_arrow = inWithArrow;
	update();


func setBegginingColor(inColor):
	beginningColor = inColor;

func getTargetNode():
	if(target_node_path==null):return null;
	if(has_node(target_node_path)):
		return get_node(target_node_path);
	else:
		return null;

func _draw():
	if not is_visible():
		return

	if target == null:
		return

	if color == null:
		color = Color(1,1,1,1)

	var points = PoolVector2Array()
	var colors = PoolColorArray()

	var arrowvec = target - get_global_position()
	var sidedir = Vector2(arrowvec.y, -arrowvec.x).normalized()
	var sidevec = sidedir * width * 0.5
	var pointvec = arrowvec.normalized() * width

	var startoffset = arrowvec.normalized() * start_offset
	var endoffset = -arrowvec.normalized() * end_offset
	var sideoffset = sidedir * side_offset

	if(arrowvec.length()<50): return;

	points.append(sideoffset + startoffset + sidevec)
	colors.append(beginningColor)
	points.append(sideoffset + endoffset + sidevec + arrowvec - pointvec)
	colors.append(color)
#	if(with_arrow):
	points.append(sideoffset + endoffset + 3*sidevec + arrowvec - pointvec)
	colors.append(color)
	points.append(sideoffset + endoffset + arrowvec + pointvec*1.2)
	colors.append(color)
#	if(with_arrow):
	points.append(sideoffset + endoffset - 3*sidevec + arrowvec - pointvec)
	colors.append(color)

	points.append(sideoffset + endoffset - sidevec + arrowvec - pointvec)
	colors.append(color)
	points.append(sideoffset + startoffset - sidevec)
	colors.append(beginningColor)

	self.draw_polygon(points, colors)

	if(getTargetNode()!=null) && (closeIcon!=null):
#		get_node("Label").set_text(getTargetNode().get_path());
		var middlePos = (get_global_position() + target)/2.0;
		middlePos.x = round(middlePos.x);
		middlePos.y = round(middlePos.y);
		closeIcon.set_global_position(middlePos);
	elif(closeIcon!=null):
		closeIcon.hide();

func set_target(p_target):
	if p_target != cached_target:
		target = p_target
		cached_target = target
		update()

func set_width(p_width):
	width = p_width
	update()

func set_target_node_path(p_target_node_path):
	target_node_path = p_target_node_path
	if null == target_node_path:
		target_node = null
		target = null
	else:
		target_node = get_node(target_node_path)
		if target_node == null:
			target = null

func _process(delta):
	if target_node != null:
		if(target_node.has_method("calculateNewArrowPointPosition")):
			set_target(target_node.calculateNewArrowPointPosition(self))
		else:
			set_target(target_node.get_global_position())

	if get_global_position() != cached_pos:
		cached_pos = get_global_position()
		update()

func is_visible():
	return not editor_only or Engine.is_editor_hint()

func set_start_offset(value):
	start_offset = value
	update()

func set_end_offset(value):
	end_offset = value
	update()

func set_side_offset(value):
	side_offset = value
	update()

func set_color(value):
	color = value
	update()

func _on_CloseIcon_onCloseBtnClicked():
	emit_signal("removeConnectionRequest", getTargetNode());
	queue_free();
