extends RigidBody

func _on_LifetimeTimer_timeout():
	queue_free()
