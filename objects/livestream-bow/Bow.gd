@tool
extends XRToolsPickable

@onready var bow_skeleton : Skeleton3D = $bow/Armature/Skeleton3D
@onready var pull_pick : XRToolsPickable = $PullPivot/PullPick
@onready var pull_pivot : Node3D = $PullPivot
@onready var pull_pivot_org_position = $PullPivot.transform.origin
@onready var arrow_snap_zone : XRToolsSnapZone = $PullPivot/ArrowSnapZone

const pull_pick_layer = 1 << 10 # 11
const fire_factor = 100.0
const max_pullback = 0.5
const string_pose_offset = -1.638

var held_arrow : Arrow

# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "Bow"


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

	if Engine.is_editor_hint():
		return

	set_process(false)


func _process(delta):
	if Engine.is_editor_hint():
		return

	if pull_pick.is_picked_up():
		var curr_pull_pivot_position = pull_pivot.transform.origin
		var pull_position = (pull_pick.global_transform.origin) * global_transform

		# Move our pull pivot along the x axis
		pull_pivot.transform.origin.x = clamp(pull_position.x, pull_pivot_org_position.x, max_pullback)

		# Adjust our bones
		var pulled_back = pull_pivot.transform.origin.x - pull_pivot_org_position.x
		var pose_position : Vector3 = Vector3()
		pose_position.y = string_pose_offset - (pulled_back * 20.0)
		bow_skeleton.set_bone_pose_position(1, pose_position)

		# Adjust our pull pick location by the movement we just added to pull_pivot
		pull_pick.transform.origin = curr_pull_pivot_position - pull_position


func _on_Bow_picked_up(_pickable):
	# Enable our pull pick and snap zone
	pull_pick.collision_layer = pull_pick_layer
	pull_pick.enabled = true
	arrow_snap_zone.enabled = true


func _on_Bow_dropped(_pickable):
	# If we're holding our pull pick, drop that to
	var picked_up_by = pull_pick.get_picked_up_by()
	if picked_up_by:
		picked_up_by.drop_object()

	# Disable our pull pick and snap zone
	pull_pick.collision_layer = 0
	pull_pick.enabled = false
	arrow_snap_zone.enabled = false


func _on_PullPick_picked_up(_pickable):
	set_process(true)


func _on_PullPick_dropped(_pickable):
	set_process(false)

	# Move back to start location, and re-enable our collision layer
	pull_pick.transform = Transform3D()
	pull_pick.collision_layer = pull_pick_layer

	# Fire our arrow
	var arrow : Arrow = held_arrow
	if arrow:
		var pulled_back = pull_pivot.transform.origin.x - pull_pivot_org_position.x
		
		# drop our arrow
		arrow_snap_zone.drop_object()
		
		# Give is a linear velocity
		arrow.linear_velocity = global_transform.basis * (Vector3(-pulled_back, 0.0, 0.0) * fire_factor)
		
		$PullPivot/ArrowSnapZone/Timer.start()
	
	# Move our pivot back
	pull_pivot.transform.origin = pull_pivot_org_position
	
	# And reset our pose transform on our boes
	var pose_position : Vector3 = Vector3()
	pose_position.y = string_pose_offset
	bow_skeleton.set_bone_pose_position(1, pose_position)


func _on_ArrowSnapZone_has_picked_up(_what):
	held_arrow = _what
	held_arrow.collisions_enabled = false
	arrow_snap_zone.enabled = false


func _on_arrow_snap_zone_has_dropped():
	held_arrow.collisions_enabled = true
	held_arrow = null


func _on_ArrowSnapZone_Timer_timeout():
	arrow_snap_zone.enabled = is_picked_up()
