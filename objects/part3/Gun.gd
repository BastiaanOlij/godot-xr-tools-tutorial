extends XRToolsPickable

onready var magazine_snapzone = $Pistol/MagazineSnapZone

var magazine

func on_magazine_loaded():
	pass

func on_magazine_ejected():
	magazine_snapzone.drop_object()
	
	magazine = null

func _on_MagazineSnapZone_has_picked_up(what):
	$AnimationPlayer.play("LoadMagazine")
	
	magazine = what

func _process(delta):
	if is_picked_up() and by_controller and by_controller.is_button_pressed(XRTools.Buttons.VR_BUTTON_BY):
		if magazine:
			$AnimationPlayer.play("EjectMagazine")
	
