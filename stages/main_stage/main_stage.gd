@tool
extends XRToolsSceneBase

@onready var _left_hand = $XROrigin3D/LeftHand/XRToolsCollisionHand/LeftHand
@onready var _left_ghost_hand = $XROrigin3D/LeftHand/LeftGhostHand
@onready var _right_hand = $XROrigin3D/RightHand/XRToolsCollisionHand/RightHand
@onready var _right_ghost_hand = $XROrigin3D/RightHand/RightGhostHand

# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "MainStage"


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

	if Engine.is_editor_hint():
		return

	# For some reason this is not set correctly, set layer 3, 11, 17 and 19
	$XROrigin3D/LeftHand/XRToolsCollisionHand/FunctionPickup.grab_collision_mask = (1 << 2) + (1 << 10) + (1 << 16) + (1 << 18)
	$XROrigin3D/RightHand/XRToolsCollisionHand/FunctionPickup.grab_collision_mask = (1 << 2) + (1 << 10) + (1 << 16) + (1 << 18)

func _process(delta):
	if Engine.is_editor_hint():
		return

	if _left_hand and _left_ghost_hand:
		_left_ghost_hand.visible = (_left_hand.global_position - _left_ghost_hand.global_position).length() > 0.005
	if _right_hand and _right_ghost_hand:
		_right_ghost_hand.visible = (_right_hand.global_position - _right_ghost_hand.global_position).length() > 0.005
