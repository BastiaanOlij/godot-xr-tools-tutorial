extends XRToolsPickable

const force_factor = 0.1

var sphere_mesh : SphereMesh
onready var last_ghost_pos = global_transform.origin

func _ready():
	sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.01
	sphere_mesh.height = 0.02
	sphere_mesh.radial_segments = 16
	sphere_mesh.rings = 8

func _physics_process(delta):
	if mode == RigidBody.MODE_RIGID:
		var forward_direction = -global_transform.basis.x
		var forward_motion = linear_velocity

		var speed = forward_motion.length()
		if speed > 1.0:
			forward_motion = forward_motion.normalized()
			var dot = 1.0 - max(0.0, forward_motion.dot(forward_direction))
			var sideways = forward_motion.cross(forward_direction).normalized()
			var force_vector = sideways.cross(forward_direction).normalized()

			var position = global_transform.basis.xform($ArrowMesh.transform.origin)
			apply_impulse(position, force_vector * dot * force_factor * speed)

			return
			# TESTING REMOVE!
			var distance = ($ArrowMesh.global_transform.origin - last_ghost_pos).length()
			if distance > 1.0:
				last_ghost_pos = $ArrowMesh.global_transform.origin

				var mesh_instance = MeshInstance.new()
				mesh_instance.mesh = $ArrowMesh.mesh
				add_child(mesh_instance)
				mesh_instance.set_as_toplevel(true)
				mesh_instance.global_transform = $ArrowMesh.global_transform

				var swmesh = MeshInstance.new()
				swmesh.mesh = sphere_mesh
				mesh_instance.add_child(swmesh)
				swmesh.global_transform.origin = mesh_instance.global_transform.origin + force_vector * 0.1

func _on_Arrow_body_entered(body):
	# Just react to the floor for now, this can be improved upon loads
	if body.name == "Floor":
		mode = RigidBody.MODE_STATIC
