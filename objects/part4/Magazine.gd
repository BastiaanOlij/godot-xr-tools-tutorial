extends XRToolsPickable
class_name GunMagazine

var bullet_count = 10

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
	_update_bullets()
