tool
extends EditorPlugin

const FSMGraphUIscn = preload("content/FSMGraph/FSMGraphUI/FSMGraphUI.tscn");

var editorInstance;
func _enter_tree():
	add_custom_type("FSMControl","Control", preload("content/fsm.gd"), preload("assets/icoControl.png"))
	add_custom_type("FSM2D","Node2D", preload("content/fsm.gd"), preload("assets/ico2d.png"))
	add_custom_type("FSM3D","Spatial", preload("content/fsm.gd"), preload("assets/ico3d.png"))

	editorInstance = FSMGraphUIscn.instance();
	print("Editor instance script: ", editorInstance.get_script());
	get_editor_interface().get_editor_viewport().add_child(editorInstance);
	get_editor_interface().get_editor_viewport().connect("resized", self, "on_resized");
	on_resized();
	editorInstance.connect("openScriptRequest", self, "onScriptOpenRequest");
	editorInstance.connect("selectNodeRequest", self, "onNodeSelectRequest");

	get_editor_interface().get_selection().connect("selection_changed", self, "onEditorTreeSelectionChanged");

func _exit_tree():
	remove_custom_type("FSMControl")
	remove_custom_type("FSM2D")
	remove_custom_type("FSM3D")

	if(editorInstance!=null):
		editorInstance.queue_free();
	queue_free()

func get_name():
	return "FSM";

func has_main_screen():
	return true

func apply_changes():
	if(editorInstance!=null):
		editorInstance.save();

var handlesRecentlyReturned = false;
#this method is useless for some reason.
#it never enter here for aything else than the simplest Node (why?)
#implemented editor selection onEditorTreeSelectionChanged signal as a workaround
func handles(object):
	return false;
	return (object is preload("content/fsm.gd"))
	if(!object is Node): return false;

	var parentName = object.get_parent().get_name();
	var isInsideFsm =  (parentName == "States") || (parentName == "Transitions") || (parentName.begins_with("FSM"));

	if(object is preload("content/fsm.gd")):
		editorInstance.manualInit(object);
		return true;
	elif(isInsideFsm):
		return true;
	return false;

func make_visible(visible):
	if(visible):
		editorInstance.show();
	else:
		editorInstance.hide();

############
### Signals
func onEditorTreeSelectionChanged():
	var selectedNodes = get_editor_interface().get_selection().get_selected_nodes()
	if(selectedNodes.size()!=1): return;
	var selectedNode = selectedNodes[0];

	if(selectedNode is preload("content/fsm.gd")):
		editorInstance.manualInit(selectedNode);
		make_visible(true);
	elif(selectedNode.has_node("..")):
		var parentName = selectedNode.get_parent().get_name();
		var isInsideFsm =  (parentName == "States") || (parentName == "Transitions") || (parentName.begins_with("FSM"));
		if(isInsideFsm):
			pass
		else:
			make_visible(false);

func on_resized():
	var viewport_size = get_editor_interface().get_editor_viewport().get_size();
	editorInstance.set_size(viewport_size);
	editorInstance.set_global_position(get_editor_interface().get_editor_viewport().get_global_position());
	editorInstance.graph.set_size(viewport_size);

func onScriptOpenRequest(inNodeWithScript):
	if(inNodeWithScript!=null) && (inNodeWithScript.get_script()!=null):
		get_editor_interface().edit_resource(inNodeWithScript.get_script()); #load(inNodeWithScript.get_filename()));
		var editorSelection = get_editor_interface().get_selection();
		editorSelection.clear();
		editorSelection.add_node(inNodeWithScript);
		make_visible(false);

func onNodeSelectRequest(inNode):
	if(inNode!=null):
		var editorSelection = get_editor_interface().get_selection();
		editorSelection.clear();
		editorSelection.add_node(inNode);


##########
## Helpers
static func returnEmptyWeakRef():
	var tempObj = Node.new();
	var weakRef = weakref(tempObj);
	tempObj.free()
	return weakRef;
