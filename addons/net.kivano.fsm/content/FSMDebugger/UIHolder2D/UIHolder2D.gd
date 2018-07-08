extends Node2D;

signal onActivate;

export (NodePath)var followingSpatialPath = NodePath("..");
export var shift = Vector3(0,0,0);
export var automaticallyStartFollow = true;

export var cameraDistScaling = false;
export var minScale = 0.25;
export var minScaleAtCamDst = 50;
export var maxScale = 1.0;
export var maxScaleAtCamDst = 5;

onready var minScaleAtCamDstSquared = minScaleAtCamDst*minScaleAtCamDst;
onready var maxScaleAtCamDstSquared = maxScaleAtCamDst*maxScaleAtCamDst;
var camera;
var baseScale;

###########Initialization
############################
var firstTimeInReady = true;
func _ready():
	if(firstTimeInReady):
		firstTimeInReady = false;
		camera = get_node(followingSpatialPath).get_viewport().get_camera();
		if(automaticallyStartFollow): startFollowing();
		baseScale = get_scale();

func setFollowPath2(inNode):
	followingSpatialPath = get_path_to(inNode);
	camera = get_node(followingSpatialPath).get_viewport().get_camera();
	updateScreenPos();

func disableScaling():
	cameraDistScaling = false;

#############Logic
######################
func startFollowing():
	set_process(true);
	emit_signal("onActivate");

func stopFollowing():
	set_process(false);

func _process(delta):
	updateScreenPos();
	if(cameraDistScaling): updateScale();

func updateScreenPos():
	var posOnScreen = camera.unproject_position(get_node(followingSpatialPath).get_global_transform().origin+shift)
	set_position(posOnScreen)

func updateScale():
	var gPos = get_node(followingSpatialPath).global_transform.origin;
	var camPos = camera.get_translation();
	var currentDst2Cam = gPos.distance_squared_to(camPos);

	var currentScale = interpolateLinearBetween2Points(minScaleAtCamDstSquared, minScale, maxScaleAtCamDstSquared, maxScale, currentDst2Cam);
	currentScale = max(currentScale,minScale);
	currentScale = min(currentScale,maxScale);
	set_scale(baseScale*currentScale);


#####################
### INNER METHODS
#	/**
#	 *     v1+v2  (     )
#	 * y = ------*( x-1 )+v2
#	 *     p1+p2  (     )
#	 */
static func interpolateLinearBetween2Points( inP1,  inP1Val,  inP2, inP2Val, interpolationPoint):
	return ((interpolationPoint * inP1Val) - (interpolationPoint * inP2Val) + (inP1 * inP2Val) - (inP2 * inP1Val))/ (inP1 - inP2);
