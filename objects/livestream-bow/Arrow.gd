@tool
class_name Arrow
extends XRToolsPickable

const force_factor = 0.1

@export var collisions_enabled : bool = true:
	set(value):
		collisions_enabled = value

		if is_inside_tree():
			$CollisionShape3D.disabled = !collisions_enabled

@onready var last_ghost_pos = global_transform.origin

# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "Arrow"


func _ready():
	super._ready()

	if Engine.is_editor_hint():
		return

	$CollisionShape3D.disabled = !collisions_enabled


func _physics_process(_delta):
	if Engine.is_editor_hint():
		return

	if not freeze:
		var forward_direction = -global_transform.basis.x
		var forward_motion = linear_velocity

		var speed = forward_motion.length()
		if speed > 1.0:
			forward_motion = forward_motion.normalized()
			var dot = 1.0 - max(0.0, forward_motion.dot(forward_direction))
			var sideways = forward_motion.cross(forward_direction).normalized()
			var force_vector = sideways.cross(forward_direction).normalized()

			var impulse_position = global_transform.basis * ($ArrowMesh.transform.origin)
			apply_impulse(force_vector * dot * force_factor * speed, impulse_position)


func _on_Arrow_body_entered(body):
	# Just react to the floor for now, this can be improved upon loads
	if body.name == "Floor":
		freeze = true
