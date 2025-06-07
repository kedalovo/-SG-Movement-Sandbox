extends Node3D


func _on_area_body_entered(body: Node3D) -> void:
	if body is Player:
		body.checkpoint = global_position + Vector3(0.0, 1.0, 0.0)
		queue_free()
