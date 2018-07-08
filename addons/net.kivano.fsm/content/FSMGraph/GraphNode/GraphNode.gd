tool
extends Control
################################### R E A D M E ##################################
#
#
#

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################
const ArrowScn = preload("../Arrow/Arrow.tscn");

##################################################################################
#########                       Signals definitions                      #########
##################################################################################
signal doubleClick(inGraphNode);
signal singleClick(inGraphNode);
signal arrowDragEnd(inStateRepresentation, inAtPos, inSlot);
signal movementEnd(inGraphNode);
signal connectionRemoveRequest(inSource, inTarget);

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
const TYPE_STATE = 1;
const TYPE_TRANSITION = 2;

export (String) var stateName = "STATE NAME" setget setName;

onready var title = get_node("title");
onready var dragArrow = get_node("arrows/dragArrow");
var arrows;# = get_node("arrows");

var baseType = TYPE_STATE;
var inputConnectionType = TYPE_TRANSITION;
var outputConnectionType = TYPE_TRANSITION;
var ownerFsmRef = returnEmptyWeakRef();
#var relatedFSMNodeRef = returnEmptyWeakRef();
var isMousePressed = false;
var isControlPressed = false;

##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		arrows = get_node("arrows");
	elif(what == NOTIFICATION_READY):
		setName(name);
		dragArrow.target = get_global_position() + Vector2(200,0);
		yield(get_tree().create_timer(0.01), "timeout");
		dragArrow.hide();


func manualInit(inRelatedFsm):
	if(inRelatedFsm!=null):
		ownerFsmRef = weakref(inRelatedFsm);

##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func getAmountOfConnectedNodes():
	return getConnectedVisualNodes().size();

func getConnectedVisualNodes():
	var outputArray = [];
	for arrow in arrows.get_children():
		var target = arrow.getTargetNode();
		if(target!=null):
			outputArray.append(target);
	return outputArray;

func isAcceptingIncomingConnections():
	return true;

func canConnect2AnotherNode():
	return true;

func setName(inName):
	name = inName;
	if(!is_inside_tree()): return;
	title.set_text(name);

func getInputTrackingNode4GraphState(inSourceGraphState):
#	calculateNewArrowPointPosition(inSourceGraphState);
#	return get_node("arrowPoint2Position");
	return findNearestNodeFromArray(inSourceGraphState.get_global_position(),get_node("inputSocketPositions").get_children());

func calculateNewArrowPointPosition(inSourceNodePos):
	var nearestTrackingNode = findNearestNodeFromArray(inSourceNodePos.get_global_position(),get_node("inputSocketPositions").get_children());
	return nearestTrackingNode.get_global_position();


func getGlobalCenterPos():
#	return get_position(inNewPos) - get_size()/2
	return get_node("inputSocketPositions").get_global_position();

func isConnected2(inGraphNode):
	for arrow in arrows.get_children():
		if(arrow.getTargetNode()==inGraphNode):
			return true;
	return false;

#func setRelatedFSMNode(inRelatedFSMNode):
#	if(inRelatedFSMNode==null): return;
#	relatedFSMNodeRef = weakref(inRelatedFSMNode);
##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################

##################################################################################
#########                       Connected Signals                        #########
##################################################################################
func _on_TranslationFixIntervaler_timeout():
	set_global_position(Vector2(round(get_global_position().x), round(get_global_position().y)));

#		ownerFsmRef.get_ref().getTransition(get_name()).devLog = str(leftBtn);
var lastlyClickedAt = 0;
func _on_GraphNode_gui_input( ev ):
	if(ev is InputEventMouseButton):
		isMousePressed = ev.is_pressed();
		if(!isMousePressed):
			dragArrow.hide();
			if(ev.control || (ev.button_index & BUTTON_RIGHT)):
				emit_signal("arrowDragEnd", self, ev.global_position, 0);
			emit_signal("movementEnd", self);
		elif(ev.button_index & BUTTON_LEFT):
			if((lastlyClickedAt + 250) > OS.get_ticks_msec()):
				emit_signal("doubleClick", self);
			else:
				emit_signal("singleClick", self);
			lastlyClickedAt = OS.get_ticks_msec();
	elif(ev is InputEventMouseMotion):
		var leftBtn = (ev.button_mask & BUTTON_MASK_LEFT);
		var rightBtn = (ev.button_mask & BUTTON_MASK_RIGHT);
		if(ev.control&&(leftBtn && isMousePressed) ||  rightBtn):
			dragArrow.show();
			dragArrow.target =ev.global_position;
		elif(isMousePressed && leftBtn):
			setCenterGlobalPos(ev.global_position);

func onArrowRemoveConnectionRequest(inTargetGraphNode):
	emit_signal("connectionRemoveRequest", self, inTargetGraphNode);

##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################

##################################################################################
#########                         Public Methods                         #########
##################################################################################
func createNewArrowAndConnect2(inTagetGraphNode):
	if(self == inTagetGraphNode): return; #strange, but it seems empty nodepath sometimes works like "."
	var newArrow = ArrowScn.instance();
	arrows.add_child(newArrow);
	newArrow.set_target_node_path(newArrow.get_path_to(inTagetGraphNode));
	newArrow.connect("removeConnectionRequest", self, "onArrowRemoveConnectionRequest")
	if(baseType == TYPE_TRANSITION):
		newArrow.setPointingOnState(true);
#		ownerFsmRef.get_ref().getTransition(get_name()).devLog ="creating arrow in " + get_name() + " target: " + inTagetGraphNode.get_parent().get_name();

func setCenterGlobalPos(inNewGlobalPos):
	set_global_position(inNewGlobalPos - get_size()/2);

func setCenterPos(inNewPos):
	set_position(inNewPos - get_size()/2)

##################################################################################
#########                         Inner Methods                          #########
##################################################################################
static func returnEmptyWeakRef():
	var tempObj = Node.new();
	var weakRef = weakref(tempObj);
	tempObj.free()
	return weakRef;

static func findNearestNodeFromArray(inTestPoint, inCollection, maxDstSquared = -1, spatial2Ignore = null, ignoreSpatialFunc=null):
	var nearestCandidate = getFirstDifferentItem(inCollection, spatial2Ignore);
	var nearestDst = nearestCandidate.get_global_position().distance_squared_to(inTestPoint);
	for item in inCollection:
		if(item == spatial2Ignore): continue;
		var pos = item.get_global_position();
		var currentDst = pos.distance_squared_to(inTestPoint);
		if(currentDst<nearestDst):
			if(ignoreSpatialFunc!=null):
				if(ignoreSpatialFunc.call_func(item)): continue;

			nearestCandidate = item;
			nearestDst = currentDst;

	if(maxDstSquared==-1): return nearestCandidate;
	if(nearestDst<=maxDstSquared): return nearestCandidate;
	return null;

static func getFirstDifferentItem(inCollection, inDiffrentThan):
	for item in inCollection:
		if(item!=inDiffrentThan): return item;
	return null;

##################################################################################
#########                         Inner Classes                          #########
##################################################################################
