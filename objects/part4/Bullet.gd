extends RigidBody3D

func _on_LifetimeTimer_timeout():
	queue_free()
