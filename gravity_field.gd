@tool
extends Node3D


@onready var collision: CollisionShape3D = $Area/Collision

@export var field_size: Vector3:
	get:
		return collision.shape.size
	set(v):
		field_size = v.clamp(MIN_SIZE, MAX_SIZE)
		collision.shape.size = v.clamp(MIN_SIZE, MAX_SIZE)

const MAX_SIZE: Vector3 = Vector3(100, 100, 100)
const MIN_SIZE: Vector3 = Vector3(1, 1, 1)
