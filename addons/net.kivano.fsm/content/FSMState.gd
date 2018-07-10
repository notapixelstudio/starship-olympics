extends Node;

var logicRoot;
var fsm;

func stateInit(inParam1=null,inParam2=null,inParam3=null,inParam4=null, inParam5=null): pass
func enter(fromState=null, fromTransition=null, inArg0=null,inArg1=null, inArg2=null): pass
func update(deltaTime, param0=null, param1=null,param2=null,param3=null,param4=null): pass
func exit(toState=null): pass

func computeNextState():
	return self.get_name()

######### INTERNAL/PRIVATE PART ########
var incomingSignals = [];

func storeIncomingSignals():
	incomingSignals.clear();
	var incomingConnections = get_incoming_connections();
	for connection in incomingConnections:
		incomingSignals.append(SignalData.new(connection.source, connection.signal_name, connection.method_name));
		connection.source.disconnect(connection.signal_name, self, connection.method_name);

func restoreIncomingSignals():
	for storedSignal in incomingSignals:
		if(!storedSignal.signalSourceRef.get_ref()): continue;
		storedSignal.signalSourceRef.get_ref().connect(storedSignal.signalName, self, storedSignal.targetFuncName);

class SignalData:
	var signalSourceRef;
	var signalName;
	var targetFuncName;
	
	func _init(inSource, inName, inTargetFunc):
		signalSourceRef = weakref(inSource);
		signalName = inName;
		targetFuncName = inTargetFunc;