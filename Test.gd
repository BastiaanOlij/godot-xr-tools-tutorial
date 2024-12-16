extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time_passed = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_passed += delta
	$StaticBody.transform.origin.x = -1.0 + sin(time_passed)


func _on_Area_body_entered(body):
	print("Body entered ", body.name)


func _on_Area_body_exited(body):
	print("Body exited ", body.name)
