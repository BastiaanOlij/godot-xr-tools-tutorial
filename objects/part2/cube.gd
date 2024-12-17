@tool
extends XRToolsPickable

@export var size : Vector3 = Vector3(0.1, 0.1, 0.1):
	set(value):
		size = value
		if is_inside_tree():
			_update_size()

func _update_size():
	$CollisionShape3D.shape.size = size
	$MeshInstance3D.mesh.size = size
	$GrabPointHandLeft.position.x = -(size.x * 0.5 - 0.005)
	$GrabPointHandRight.position.x = size.x * 0.5 - 0.005
	$Weight01.position.z = size.z * 0.5 + 0.001
	$Weight02.position.z = -(size.z * 0.5 + 0.001)

func _ready():
	super._ready()

	_update_size()
	$Weight01.text = "%d Kg" % [ mass ]
	$Weight02.text = "%d Kg" % [ mass ]
