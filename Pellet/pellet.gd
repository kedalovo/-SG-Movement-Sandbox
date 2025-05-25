extends RigidBody3D


@onready var area: Area3D = $Area


@export var force: int = 0
@export var repel_force: int = 0


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"Floor") or body.is_in_group(&"Junk"):
		explode()


func explode() -> void:
	for body in area.get_overlapping_bodies():
		if body.is_in_group(&"Junk"):
			body.apply_impulse((body.global_position - global_position).normalized() * repel_force)
		elif body is Player:
			body.velocity += (body.global_position - global_position).normalized() * repel_force * 2
	queue_free()
