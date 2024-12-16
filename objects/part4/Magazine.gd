@tool
extends XRToolsPickable
class_name GunMagazine

@export var collisions_enabled : bool = true:
	set(value):
		collisions_enabled = value

		if is_inside_tree():
			$CollisionShape3D.disabled = !collisions_enabled

var bullet_count = 10


# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "GunMagazine"

func has_bullets() -> bool:
	return bullet_count > 0

func take_bullet():
	if bullet_count > 0:
		bullet_count = bullet_count - 1
		_update_bullets()

func _update_bullets():
	$MagazineMesh/Bullet01.visible = bullet_count > 0
	$MagazineMesh/Bullet02.visible = bullet_count > 1

func _ready():
	super._ready()

	if Engine.is_editor_hint():
		return

	$CollisionShape3D.disabled = !collisions_enabled
	_update_bullets()
