tool
extends Node
##################################### README  ###############################
# @author: Jakub Grzesik
#
# * To create new state check  "Create New:" subsection in FSM inspector
#
# * Dont be afraid to check FSM script to check available methods
#
# * Exported Variables of FSM which are intended to be used by users:
#
#     NodePath path2LogicRoot: states usually perform logic based on variables in
#         some external node, like 'Enemy'. This variable usually points to this node.
#         It dont have any other purpose other than to be available for child states.
#
#     bool onlyActiveStateOnTheScene: if this is true, then only active state is present
#         on scene tree. It might be handy if states have visual representation
#
#     bool initManually: #you can set this to true to set export vars in runtime from code,
#         before you will be able to use this FSM you will need to run init() function.
#         Run init() only after setting exported variables.
#
#     string Initial state: you can choose from this list with which state FSM should start.
#
#     int updateMode: if set to manual, then it's up to you to update this FSM. In this case
#         you need to call FSM.update(inDeltaTime) to update this fsm (usually once per frame)
#
#
##########
# * Exported variables that are editor helpers:
#
#      Subdirectory for states: you can set name of directory which will be automatically
#          created to hold all states for this FSM
#
#      Create state with name: when you enter and accept name for a state it will be
#          immediatelly created and added to scene tree as a child of current FSM
#          This state will have an unique script in which you can implement state logic.
#
#
###########
# * Functions that are intended to be used by users:
#
#     getStateID(): return name of current state
#
#     getState(): return node with current state
#
#     changeStateTo(inNewStateID): can be used to change state.
#        Usually dont need to be used if you are using graph to link your states
#
#     stateTime(): returns how long current state is active
#
#     update(inDeltaTime): update FSM to update current state. Should be
#        used in every game tick, but should use it only if you are using
#        updateMode="Manual".
#
#    init(): use only if initManually = true. You will be able to pass additional arguments
#        to your states and transitions
#
#
################
# * Members that are intended to be used by users:
#    STATE: you can use this dictionary to access state id. Using is is recommended because it's less error prone than
#        entering states ids by hand. ex. fsm.changeStateTo(fsm.STATE.START) <- when one of your states is named 'START')

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################
var StateScn = preload("res://addons/net.kivano.fsm/content/FSMState.gd");
var FSMDebuggerScn = preload("res://addons/net.kivano.fsm/content/FSMDebugger/FSMDebugger.tscn");
var FSMSpatialDebuggerScn = preload("res://addons/net.kivano.fsm/content/FSMDebugger/FSMDebugger3D.tscn");

##################################################################################
#########                       Signals definitions                      #########
##################################################################################
signal stateChanged(newStateID, oldStateID);

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################

#you can use this dictionary to access state id. Using is is recommended because it's less error prone than
#entering states ids by hand. ex. fsm.set_state(fsm.STATE.START) <- when one of your states is named 'START')
var STATE = {"":""};

#same as above but for transitions
var TRANSITION = {"":""};

const HISTORY_MAX_SIZE = 10;
const UPDATE_MODE_MANUAL = 0;
const UPDATE_MODE_PROCESS = 1;
const UPDATE_MODE_FIXED_PROCESS = 2;

const TYPE_3D = 0;
const TYPE_2D = 1;

export (NodePath) var path2LogicRoot = NodePath("..");
export (bool) var onlyActiveStateOnTheScene = false setget setOnlyActiveStateOnScene;
export (bool) var initManually = false;
export (int, "Manual", "Process", "Fixed") var updateMode = UPDATE_MODE_PROCESS;
export (bool) var receiceSignalsOnly4ActiveStatesAndTransitions = true;
export (bool) var enableDebug = false;

var stateTransitionsMap = {};

var initStateID = "" setget setInitState; #id of initial state for this fsm (id is the same as state node name)
var currentStateID = initStateID;
var currentState = null
var states = {};
var allTransitions = {};
var stateTime = 0;
var statesHistory = [];
var statesNode = null;
var transitionsNode = null;
var lastlyUsedTransitionID = null;

##################################################################################
#########                          Init code                             #########
##################################################################################
func _ready():
	set_process(false);
	set_physics_process(false);

	toolInit();
	add_to_group("FSM");
	if(initManually):
		return;
	init();

func init(inStatesParam1=null, inStatesParam2=null, inStatesParam3=null, inStatesParam4=null, inStatesParam5=null):

	#
	statesNode = get_node("States");
	transitionsNode = get_node("Transitions");

	if(statesNode.get_child_count()==0):
		return;

	#
	if(Engine.is_editor_hint()): return;
	if(get_child_count()==0): return;

	if(enableDebug):
		var debugger;
		if(get_parent() is Spatial):
			debugger = FSMSpatialDebuggerScn.instance();
		else:
			debugger = FSMDebuggerScn.instance();
		add_child(debugger);
		debugger.manualInit(self);

	#
	ensureInitStateIdIsSet();

	#
	states = {}; #to be sure
	STATE = {};  #to be sure
	var states2Add = statesNode.get_children();
	for state2Add in states2Add:
		if(state2Add is preload("FSMState.gd")):
			states[state2Add.get_name()] = state2Add;
			STATE[state2Add.get_name()] = state2Add.get_name();
			if(!Engine.is_editor_hint()):
				state2Add.logicRoot = get_node(path2LogicRoot);
				state2Add.fsm = self;
				state2Add.stateInit(inStatesParam1,inStatesParam2,inStatesParam3,inStatesParam4, inStatesParam5);

	#
	initTransitions(inStatesParam1, inStatesParam2, inStatesParam3, inStatesParam4, inStatesParam5);

	#
	if(onlyActiveStateOnTheScene):

		#remove transitions
		var transitions = transitionsNode.get_children();
		for transition in transitions:
			transitionsNode.remove_child(transition);

		#states
		var statesKeys = states.keys();
		for stateKey in statesKeys:
			if(stateKey!=initStateID):
				var state2Remove = statesNode.get_node(stateKey);
				statesNode.remove_child(state2Remove);

	#
	if(initStateID!=""):
		currentState = states[initStateID];
		currentStateID = initStateID;
	else:
		currentState = statesNode.get_children()[0];
		currentStateID = currentState.get_name();
	ensureTransitionsForStateIDAreReady(currentStateID)

	#
	currentState.enter();

	#
	initUpdateMode();

func initUpdateMode():
	if(updateMode==UPDATE_MODE_MANUAL): return;
	elif(updateMode==UPDATE_MODE_PROCESS): set_process(true);
	elif(updateMode==UPDATE_MODE_FIXED_PROCESS): set_physics_process(true);

func initTransitions(inParam1, inParam2, inParam3, inParam4, inParam5):
	TRANSITION = {};#to be sure
	for state in statesNode.get_children(): #ensure even states without transitions are here
		stateTransitionsMap[state.get_name()] = [];

	var transitions = transitionsNode.get_children()
	for transition in transitions:
		TRANSITION[transition.get_name()] = transition.get_name();
		transition.manualInit(inParam1, inParam2, inParam3, inParam4, inParam5);
		allTransitions[transition.get_name()] = transition;
		var transitionSourceStates = transition.getAllSourceNodes();
		for state in transitionSourceStates:
			if(!stateTransitionsMap.has(state.get_name())):
				stateTransitionsMap[state.get_name()] = [];
			if(!stateTransitionsMap[state.get_name()].has(transition)):
				stateTransitionsMap[state.get_name()].append(transition);

func ensureInitStateIdIsSet():
	if(initStateID == ""):
		initStateID = statesNode.get_child(0).get_name();

func initHolderNodes():
	if(has_node("States")):
		statesNode = get_node("States");
	else:
		statesNode = createEmptyHolderNode();
		add_child(statesNode);
		statesNode.set_name("States");
		statesNode.set_owner(get_tree().get_edited_scene_root());

	if(has_node("Transitions")):
		transitionsNode = get_node("Transitions");
	else:
		transitionsNode= createEmptyHolderNode();
		add_child(transitionsNode);
		transitionsNode.set_name("Transitions");
		transitionsNode.set_owner(get_tree().get_edited_scene_root());

func createEmptyHolderNode():
	if(self is Node2D):
		return Node2D.new();
	elif(self is Spatial):
		return Spatial.new();
	elif(self is Control):
		return Control.new();
	else:
		return Node.new();


##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func stateTime():
	return stateTime;

func getStateID():
	return currentStateID;

func getState():
	return currentState;

func changeStateTo(inNewStateID):
	if(currentStateID!=inNewStateID):
		setState(inNewStateID);

func setState(inStateID, inArg0=null,inArg1=null, inArg2=null):

	#
	var prevStateID = currentStateID;
	currentState.exit(inStateID);
	archiveStateInHistory(prevStateID)

	#
	if(receiceSignalsOnly4ActiveStatesAndTransitions):
		var incomingConnections = currentState.get_incoming_connections();
		for connection in incomingConnections:
			currentState.storeIncomingSignals();

		var oldTransitions = stateTransitionsMap[prevStateID];
		for transition in oldTransitions:
			transition.storeIncomingSignals();


	if(onlyActiveStateOnTheScene):

		#states
		statesNode.remove_child(currentState);
		statesNode.add_child(states[inStateID]);

		#transitions
		var transitions = transitionsNode.get_children();
		for transition in transitions: transitionsNode.remove_child(transition);

	#
	stateTime = 0.0;
	currentState = states[inStateID];
	currentStateID = currentState.get_name()
	ensureTransitionsForStateIDAreReady(inStateID, inArg0, inArg1, inArg2);
	currentState.enter(prevStateID, lastlyUsedTransitionID, inArg0, inArg1, inArg2);

	if(receiceSignalsOnly4ActiveStatesAndTransitions):
		currentState.restoreIncomingSignals();

	#
	emit_signal("stateChanged", currentStateID, prevStateID);

func ensureTransitionsForStateIDAreReady(inStateID, inArg0 = null, inArg1 = null, inArg2 = null):
	if(!stateTransitionsMap.has(inStateID)): return;
	var newTransitions = stateTransitionsMap[inStateID];
	for newTransition in newTransitions:
		if(!transitionsNode.has_node(newTransition.get_name())):
			transitionsNode.add_child(newTransition);
		newTransition.prepareTransition(inStateID, inArg0, inArg1, inArg2);

		if(receiceSignalsOnly4ActiveStatesAndTransitions):
			newTransition.restoreIncomingSignals();


func getLogicRoot():
	return get_node(path2LogicRoot);

func getStateFromID(inStateID):
	return statesNode.get_node(inStateID);

func getTransition(inID):
	if(Engine.is_editor_hint()): return transitionsNode.get_node(inID);  #<- not used because transition might not be in tree during runtime
	return allTransitions[inID];

#sugar
func getTransitionWithID(inID): return getTransition(inID);

func getLastlyUsedTransition():
	return getTransition(lastlyUsedTransitionID);

func lastlyUsedTransitionID():
	return lastlyUsedTransitionID;

func getActiveTransitions():
	return stateTransitionsMap[currentStateID];

### less often used below
######
func getStates():
	return statesNode.get_children();

func hasStateWithID(inID):
	return statesNode.has_node(inID);

func getTransitions():
	return transitionsNode.get_children();

func hasTransition(inID):
	return transitionsNode.has_node(inID);

func removeTargetConnection4TransitionID(inID):
	getTransition(inID).clearTargetStateNode();

func removeConnection2TransitionFromState(inStateID, inTransitionID):
	var stateNode = getStateFromID(inStateID);
	var transitionNode = getTransition(inTransitionID);
	transitionNode.removeSourceConnection(stateNode);

func addTransitionBetweenStatesIDs(inSourceStateID, inTargetStateID, inTransitionID):
	#assert: you should create transition from inspector first! (don't make a lot of sense to create it from code:
	#you will need to implement custom transition logic anyway)
	assert allTransitions.has(inTransitionID);
	var transitionNode = allTransitions[inTransitionID];
	transitionNode.addSourceStateNode(statesNode.get_node(inSourceStateID));
	transitionNode.setTargetStateNode(statesNode.get_node(inTargetStateID));


#### History
#######
func archiveStateInHistory(inState2Archive):
	var nmbOfElementsInHistory = statesHistory.size();
	if(nmbOfElementsInHistory>HISTORY_MAX_SIZE):
		statesHistory.pop_back();
	statesHistory.push_front(inState2Archive)

func getPrevStateFromHistory(inHowFar=0): #0 means prev
	if(statesHistory.size()<=inHowFar): return null;
	var historicState = statesHistory[inHowFar];
	return historicState;


#### setters bellow are used by tool
#######
func setInitState(inInitState):
	initStateID = inInitState;
	if(is_inside_tree() && Engine.is_editor_hint() && onlyActiveStateOnTheScene):
		hideAllVisibleStatesExceptInitOne();

func setOnlyActiveStateOnScene(inVal):
	onlyActiveStateOnTheScene = inVal;
	if(is_inside_tree() && Engine.is_editor_hint()):
		if(onlyActiveStateOnTheScene):
			hideAllVisibleStatesExceptInitOne();
		else:
			showAllVisibleStates();

##################################################################################
#########                         Public Methods                         #########
##################################################################################
#call function in current state
func stateCall(inMethodName, inArg0=null, inArg1=null, inArg2=null):
	if(currentState.has_method(inMethodName)):
		if(inArg2!=null): currentState.call(inMethodName, inArg0, inArg1, inArg2);
		elif(inArg1!=null): currentState.call(inMethodName, inArg0, inArg1);
		elif(inArg0!=null): currentState.call(inMethodName, inArg0);
		else: currentState.call(inMethodName);

#just an alias for update, for the cases when delta time dont have much sense
func perform():
	update(0);

func update(inDeltaTime, param0=null, param1=null, param2=null, param3=null, param4=null):
	var nextStateID = checkTransitionsAndGetNextStateID(inDeltaTime, param0, param1, param2, param3, param4);
	assert((typeof(nextStateID)==TYPE_STRING));  #ERROR: currentState.computeNextState() is not returning String!" Take a look at currentStateID variable in debugger
	if(nextStateID!=currentStateID):
		setState(nextStateID);

	stateTime += inDeltaTime;
	return currentState.update(inDeltaTime, param0, param1, param2, param3, param4);

#############
### Transitions check
func checkTransitionsAndGetNextStateID(inDeltaTime, param0, param1, param2, param3, param4): #work
	if(!stateTransitionsMap.has(currentStateID)): return currentStateID;
	var relatedTransitions = stateTransitionsMap[currentStateID];
	for transition in relatedTransitions:
		if(!transitionReady2BeChecked(inDeltaTime, transition)): continue;
		if(transition.check(inDeltaTime, param0, param1, param2, param3, param4)):
			lastlyUsedTransitionID = transition.get_name();
			return transition.getTargetStateID();
	return currentStateID;


func transitionReady2BeChecked(inDeltaTime, transition):
	if(transition.intervalBetweenChecks>0.0):
		transition.timeSinceLastCheck += inDeltaTime;
		if(transition.timeSinceLastCheck<transition.intervalBetweenChecks):
			return false;
		else:
			transition.timeSinceLastCheck = 0.0;
	return true;

#################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################
func _process(delta):
	update(delta);

func _physics_process(delta):
	update(delta);

##############################################################
######################        ################################
############### TOOL / PLUGIN part ###########################
########################    ##################################
##############################################################
var FSMGraphScn = preload("FSMGraph/FSMGraph.tscn");
var FSMGraphInstance;

const INSP_INIT_STATE = "Initial state:";
const INSP_SUBDIR_4_STATES  = "Create new:/Subdirectory for FSM nodes:";
const INSP_CREATE_NEW_STATE = "Create new:/Create state with name:";
const INSP_CREATE_NEW_TRANSITION = "Create new:/Create transition with name:";
const GRAPH_DATA = "GraphData"

const SUBDIR_4_STATES = "states";
const SUBDIR_4_TRANSITIONS = "transitions";

var additionalSubDirectory4FSMData = "FSM";
var additionalGraphData = {};

func toolInit():
	if(!Engine.is_editor_hint()): return;
	initHolderNodes();

#func getBaseFolderFilepath():
#	var owner = get_owner();
#	var dirPath = owner.get_filename().get_base_dir();
#	if(additionalSubDirectory4FSMData!=""):
#		dirPath = dirPath + "/" +additionalSubDirectory4FSMData + "/" + inStateID;
#	else:
#		dirPath = dirPath + "/" + inStateID;
#	return dirPath;

############
### Creating States/Transitions
func createState(inStateName):
	createElement(inStateName, statesNode, SUBDIR_4_STATES, "res://addons/net.kivano.fsm/content/StateTemplate.gd");

func createTransition(inTransitionName, inScriptPath = null):
	var script = null;
	if(inScriptPath!=null):
		script = load(inScriptPath);
	createElement(inTransitionName, transitionsNode, SUBDIR_4_TRANSITIONS, "res://addons/net.kivano.fsm/content/TransitionTemplate.gd", script);

func createElement(inElementName, inHolderNode, inElementsSubfolder, inTemplateScriptPath, inAlreadyExistingScript2Use = null):
	if (inElementName==null) || (inElementName.empty()) || has_node(inElementName): return;

	#
	var lowner = get_owner();

	#
	var dirMaker = Directory.new();
	var dirPath = getFolderFilepath4Element(inElementName, inElementsSubfolder);
	dirMaker.make_dir_recursive(dirPath);

	var scriptFilePath = dirPath + "/" + inElementName + ".gd";
	var sceneFilePath = dirPath + "/" + inElementName + ".tscn";

	#
	var script = inAlreadyExistingScript2Use;
	if(script==null):
		var saveGameFile = File.new();
		saveGameFile.open(scriptFilePath, File.WRITE);
		saveGameFile.store_string(load(inTemplateScriptPath).get_source_code());
		saveGameFile.close();
		script = load(scriptFilePath);

	#
	var scnStateNode = Node.new();
	scnStateNode.set_script(script);
	scnStateNode.set_name(inElementName);
	var packedScn = PackedScene.new();
	packedScn.pack(scnStateNode);
	ResourceSaver.save(sceneFilePath, packedScn);

	var scn2Add = load(sceneFilePath).instance();
	inHolderNode.add_child(scn2Add)
	scn2Add.set_owner(get_tree().get_edited_scene_root());

func getFolderFilepath4Element(inElementID, inElementsSubdir):
	var lowner = get_owner();
	var dirPath = lowner.get_filename().get_base_dir();
	if(additionalSubDirectory4FSMData!=""):
		dirPath = dirPath + "/" +additionalSubDirectory4FSMData + "/" + inElementsSubdir + "/" + inElementID;
	else:
		dirPath = dirPath + "/" + inElementsSubdir + "/" + inElementID;
	return dirPath;


############
#### properties
func _get_property_list():
	var currentStatesList = statesNode.get_children();
	var statesListString = "";
	for state in currentStatesList:
		statesListString = statesListString + state.get_name() + ",";
	statesListString.erase(statesListString.length()-1,1)

	return [
		{
            "hint": PROPERTY_HINT_ENUM,
            "usage": PROPERTY_USAGE_DEFAULT,
 			"hint_string":statesListString,
            "name": INSP_INIT_STATE,
            "type": TYPE_STRING
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": INSP_SUBDIR_4_STATES,
            "type": TYPE_STRING
        },
		{
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": INSP_CREATE_NEW_STATE,
            "type": TYPE_STRING
        },
			{
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": INSP_CREATE_NEW_TRANSITION,
            "type": TYPE_STRING
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_STORAGE,
            "name": GRAPH_DATA,
            "type": TYPE_DICTIONARY
        }
    ];
func _get(property):
	if(property == INSP_SUBDIR_4_STATES):
		return additionalSubDirectory4FSMData;
	elif(property==INSP_INIT_STATE):
		return initStateID;
	elif(property==GRAPH_DATA):
		return additionalGraphData;

func _set(property, value):
	if(property == INSP_SUBDIR_4_STATES):
		additionalSubDirectory4FSMData = value;
		return true;
	elif(property == INSP_CREATE_NEW_STATE):
		createState(value);
		return false;
	elif(property==INSP_CREATE_NEW_TRANSITION):
		createTransition(value);
		return false;
	elif(property==INSP_INIT_STATE):
		setInitState(value);
		return true
	elif(property==GRAPH_DATA):
		additionalGraphData = value;
		return true;

#### visibility of states
#######
func showAllVisibleStates():
	callMethodInStatesAndAllDirectChilds("show");
func hideAllVisibleStatesExceptInitOne():
	callMethodInStatesAndAllDirectChilds("hide");

func callMethodInStatesAndAllDirectChilds(inMethodName):
	var states = statesNode.get_children();
	for state in states:
		if(state.get_name()==initStateID):
			showStateOrItsDirectChilds(state);
			continue;
		if(state.has_method(inMethodName)):
			state.call(inMethodName);
			continue;
		var stateChilds = state.get_children();
		for stateChild in stateChilds:
			if(stateChild.has_method(inMethodName)): stateChild.call(inMethodName);

func showStateOrItsDirectChilds(inState):
	if(inState.has_method("show")):
		inState.show;
	else:
		var stateChilds = inState.get_children();
		for stateChild in stateChilds:
			if(stateChild.has_method("show")): stateChild.show();

##############
#### Graph
func toolSave2Dict():
	if(FSMGraphInstance!=null):
		return FSMGraphInstance.toolSave2Dict();

func toolLoadFromDict(state):
	if(FSMGraphInstance!=null):
		FSMGraphInstance.restorePernamentData(state);


##################################################################################
#########                         Inner Classes                          #########
##################################################################################
