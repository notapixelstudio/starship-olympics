tool
extends Control
################################### R E A D M E ##################################
#
#
#

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################

##################################################################################
#########                       Signals definitions                      #########
##################################################################################
signal stateCreateRequest(inStateName);
signal transitionCreateRequest(inTransitionName, inCreateNewScriptAutomatically);

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
const OPENED_4_STATE = 1;
const OPENED_4_TRANSITION = 2;

onready var animator = get_node("AnimationPlayer");
onready var title = get_node("title");
onready var conditionLabel = get_node("conditionLabel");
onready var elementName = get_node("elementName");
var conditionOptions;
var opened4;

##################################################################################
#########                          Init code                             #########
##################################################################################

func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		conditionOptions = get_node("conditionOptions");
		conditionOptions.clear()
		conditionOptions.add_item("New condition", 0);
		conditionOptions.add_item("Choose existing",1);
		pass #all internal initialization
	elif(what == NOTIFICATION_READY):
		hide();


##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func appear4StateAtPos(inGlobalAppearPos):
	opened4 = OPENED_4_STATE;
	conditionOptions.hide();
	conditionLabel.hide();

	title.set_text("CREATE NEW STATE");
	set_global_position(inGlobalAppearPos);
	animator.play("fadein");
	show();

func appear4TransitionAtPos(inGlobalAppearPos):
	opened4 = OPENED_4_TRANSITION;
	conditionOptions.show();
	conditionLabel.show();

	title.set_text("CREATE NEW TRANSITION");
	set_global_position(inGlobalAppearPos);
	animator.play("fadein");
	show();


##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################

##################################################################################
#########                       Connected Signals                        #########
##################################################################################
func _on_btnCancel_pressed():
	animator.play("fadeout");

func _on_btnCreate_pressed():
	_create_state_or_transition(elementName.get_text())

func _on_elementName_text_entered(text):
	_create_state_or_transition(text)

##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################

##################################################################################
#########                         Public Methods                         #########
##################################################################################

##################################################################################
#########                         Inner Methods                          #########
##################################################################################

##################################################################################
#########                         Inner Classes                          #########
##################################################################################

func _create_state_or_transition(text):
	if text == null or text.strip_edges() == "": return
	if opened4 == OPENED_4_STATE:
		emit_signal("stateCreateRequest", text)
	elif opened4 == OPENED_4_TRANSITION:
		var createNewScriptAutomatically = conditionOptions.get_selected() == 0
		emit_signal("transitionCreateRequest", text, createNewScriptAutomatically)
	animator.play("fadeout")





