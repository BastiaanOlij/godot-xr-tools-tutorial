@tool
extends XRToolsPickable

enum GunState {
	GUN_UNLOADED,
	GUN_LOADED,
	GUN_FIRED
}

@export var casing_scene : PackedScene
@export var bullet_scene : PackedScene

@onready var magazine_snapzone = $Pistol/MagazineSnapZone
@onready var slide_pivot = $SlidePivot
@onready var slide_pickup : XRToolsPickable = $SlidePivot/SlidePickup
@onready var slide_org_pos = $Pistol/Pistol2/slide.transform.origin

var max_pullback_slide = 0.075
var gun_state = GunState.GUN_UNLOADED
var slide_layer

var magazine : GunMagazine

# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "Gun"

func action():
	if $AnimationPlayer.is_playing():
		return
	
	if gun_state == GunState.GUN_LOADED:
		$AnimationPlayer.play("Shoot")
	else:
		$AnimationPlayer.play("EmptyShoot")

func _ready():
	super._ready()

	if Engine.is_editor_hint():
		return

	slide_layer = slide_pickup.collision_layer
	slide_pickup.collision_layer = 0


func on_magazine_loaded():
	pass


func on_magazine_ejected():
	magazine_snapzone.drop_object()


func _on_MagazineSnapZone_has_picked_up(what):
	$AnimationPlayer.play("LoadMagazine")

	magazine = what
	magazine.collisions_enabled = false


func _on_magazine_snap_zone_has_dropped():
	magazine.collisions_enabled = true
	magazine = null


func _shoot_bullet():
	if bullet_scene:
		var new_scene = bullet_scene.instantiate()
		if new_scene:
			new_scene.set_as_top_level(true)
			add_child(new_scene)
			new_scene.transform = $Pistol/BulletsSpawnPoint.global_transform
			new_scene.linear_velocity = new_scene.transform.basis.z * 20.0

	gun_state = GunState.GUN_FIRED

func _eject_and_load():
	# If bullet/shell is loaded, eject
	if gun_state != GunState.GUN_UNLOADED:
		_eject_bullet()

	# If bullet in magazine, load bullet
	if magazine and magazine.has_bullets():
		magazine.take_bullet()
		gun_state = GunState.GUN_LOADED

	_update_bullets()

func _eject_bullet():
	# eject our bullet
	if casing_scene:
		var new_scene : GunCasing = casing_scene.instantiate()
		if new_scene:
			new_scene.set_is_bullet(gun_state == GunState.GUN_LOADED)
			new_scene.set_as_top_level(true)
			add_child(new_scene)
			new_scene.transform = $Pistol/Pistol2/slide/CasingSpawnPoint.global_transform
			new_scene.linear_velocity = new_scene.transform.basis.y * 1.0

	gun_state = GunState.GUN_UNLOADED

func _update_bullets():
	$Pistol/Pistol2/slide/LoadedBullet.visible = gun_state == GunState.GUN_LOADED
	$Pistol/Pistol2/slide/FiredBullet.visible = gun_state == GunState.GUN_FIRED

func _process(_delta):
	if Engine.is_editor_hint():
		return

	var by_controller = get_picked_up_by_controller()

	if is_picked_up() and by_controller and by_controller.is_button_pressed("by_button"):
		if magazine:
			$AnimationPlayer.play("EjectMagazine")

	if slide_pickup.is_picked_up():
		var slide_pickup_pos = slide_pickup.global_transform.origin
		var slide_pickup_local = (slide_pickup_pos) * slide_pivot.global_transform

		var pullback = max(0.0, -slide_pickup_local.z)
		if pullback < max_pullback_slide:
			$Pistol/Pistol2/slide.transform.origin = slide_org_pos - Vector3(0.0, 0.0, pullback)
		else:
			_eject_and_load()

			# Make sure our hammer is cocked after this.
			$Pistol/Pistol2/hammer.rotation_degrees.x = -40
			var picked_up_by = slide_pickup.get_picked_up_by()
			if picked_up_by:
				picked_up_by.drop_object()

func _on_Gun_picked_up(_pickable):
	slide_pickup.enabled = true
	slide_pickup.collision_layer = slide_layer

func _on_Gun_dropped(_pickable):
	var picked_up_by = slide_pickup.get_picked_up_by()
	if picked_up_by:
		picked_up_by.drop_object()

	slide_pickup.enabled = false
	slide_pickup.collision_layer = 0

func _on_SlidePickup_dropped(_pickable):
	$Pistol/Pistol2/slide.transform.origin = slide_org_pos
	slide_pickup.transform = Transform3D()
	slide_pickup.collision_layer = slide_layer
