extends XRToolsPickable

onready var bow_skeleton : Skeleton = $bow/Armature/Skeleton
onready var pull_pick : XRToolsPickable = $PullPivot/PullPick
onready var pull_pivot : Spatial = $PullPivot
onready var pull_pivot_org_position = $PullPivot.transform.origin
onready var arrow_snap_zone : XRToolsSnapZone = $PullPivot/ArrowSnapZone

const pull_pick_layer = 1 << 10
const fire_factor = 100.0
const max_pullback = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

func _process(delta):
	if pull_pick.is_picked_up():
		var curr_pull_pivot_position = pull_pivot.transform.origin
		var pull_position = global_transform.xform_inv(pull_pick.global_transform.origin)

		# Move our pull pivot along the x axis
		pull_pivot.transform.origin.x = clamp(pull_position.x, pull_pivot_org_position.x, max_pullback)

		# Adjust our bones
		var pulled_back = pull_pivot.transform.origin.x - pull_pivot_org_position.x
		var pose_transform : Transform = Transform()
		pose_transform.origin.y = pulled_back * 20.0
		bow_skeleton.set_bone_pose(1, pose_transform)

		# Adjust our pull pick location by the movement we just added to pull_pivot
		pull_pick.transform.origin = curr_pull_pivot_position - pull_position


func _on_Bow_picked_up(_pickable):
	# Enable our pull pick and snap zone
	pull_pick.collision_layer = pull_pick_layer
	arrow_snap_zone.enabled = true


func _on_Bow_dropped(_pickable):
	# If we're holding our pull pick, drop that to
	if pull_pick.is_picked_up():
		pull_pick.picked_up_by.drop_object()

	# Disable our pull pick and snap zone
	pull_pick.collision_layer = 0
	arrow_snap_zone.enabled = false


func _on_PullPick_picked_up(_pickable):
	set_process(true)

func _on_PullPick_dropped(_pickable):
	set_process(false)

	# Move back to start location, and re-enable our collision layer
	pull_pick.transform = Transform()
	pull_pick.collision_layer = pull_pick_layer

	# Fire our arrow
	var arrow : RigidBody = arrow_snap_zone.picked_up_object
	if arrow:
		var pulled_back = pull_pivot.transform.origin.x - pull_pivot_org_position.x
		
		# drop our arrow
		arrow_snap_zone.drop_object()
		
		# Give is a linear velocity
		arrow.linear_velocity = global_transform.basis.xform(Vector3(-pulled_back, 0.0, 0.0) * fire_factor)
		
		$PullPivot/ArrowSnapZone/Timer.start()
	
	# Move our pivot back
	pull_pivot.transform.origin = pull_pivot_org_position
	
	# And reset our pose transform on our boes
	var pose_transform : Transform = Transform()
	bow_skeleton.set_bone_pose(1, pose_transform)


func _on_ArrowSnapZone_has_picked_up(_what):
	arrow_snap_zone.enabled = false


func _on_ArrowSnapZone_Timer_timeout():
	arrow_snap_zone.enabled = is_picked_up()
