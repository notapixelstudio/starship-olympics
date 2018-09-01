tool
extends "res://addons/net.kivano.fsm/content/FSMTransition.gd";
################################### R E A D M E ##################################
# For more informations check script attached to FSM node
# All params are optional and will be used only if you decide to manually initialize FSM (fsm.init())
# or update manually (fsm.update(deltaTime))
#
# You can also use accomplish() method on this transition to mark it as accomplised until next related 
# state activation (you can use it from code, or connect some signals to accomplish() method)

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################

######################################
####### Getters
func getFSM(): return fsm; #access to owner FSM, defined in parent class
func getLogicRoot(): return logicRoot; #access to logic root of FSM (usually fsm.get_parent())

######################################
####### Implement those below ########
func transitionInit(inParam1=null, inParam2=null, inParam3=null, inParam4=null, inParam5=null): 
	#you can optionally implement this to initialize transition on it's creation time 
	pass

func prepare(inNewStateID, inArg0 = null, inArg1 = null, inArg2 = null): 
	#you can optionally implement this to reset transition when related state has been activated
	pass

func transitionCondition(inDeltaTime, inParam0=null, inParam1=null, inParam2=null, inParam3=null, inParam4=null): 
	#YOU MUST IMPLEMENT TRANSITION CONDITION CHECK HERE: Return true/false
	return false;
