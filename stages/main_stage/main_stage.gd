@tool
extends XRToolsSceneBase

# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "MainStage"


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

	if Engine.is_editor_hint():
		return

	# For some reason this is not set correctly, set layer 3, 11, 17 and 19
	$XROrigin3D/LeftHand/FunctionPickup.grab_collision_mask = (1 << 2) + (1 << 10) + (1 << 16) + (1 << 18)
	$XROrigin3D/RightHand/FunctionPickup.grab_collision_mask = (1 << 2) + (1 << 10) + (1 << 16) + (1 << 18)
