@tool
extends Node3D


@onready var collision: CollisionShape3D = $Area/Collision
@onready var particles: CPUParticles3D = $Particles
@onready var fog: FogVolume = $Fog
@onready var area: Area3D = $Area

var _field_size: Vector3 = Vector3(1.0, 1.0, 1.0)
var _gravity_type: enums.gravity_field_types = enums.gravity_field_types.ZERO
var _gravity_direction: Vector3 = Vector3(0.0, -1.0, 0.0)

@export var field_size: Vector3 = Vector3(1.0, 1.0, 1.0):
	get:
		return _field_size
	set(v):
		_field_size = v.clamp(MIN_SIZE, MAX_SIZE)
		field_size = _field_size
		if Engine.is_editor_hint():
			collision = $Area/Collision
			particles = $Particles
			collision.shape = BoxShape3D.new()
			fog = $Fog
			collision.shape.size = field_size
			particles.emission_box_extents = collision.shape.size / 2.0
			fog.size = field_size
			var t: Vector3 = collision.shape.size / Vector3(0.5, 0.5, 0.5)
			particles.amount = roundi((t.x + t.y + t.z) / 3.0) * 15

@export var gravity_type: enums.gravity_field_types = enums.gravity_field_types.ZERO:
	get:
		return _gravity_type
	set(v):
		_gravity_type = v
		gravity_type = v
		if Engine.is_editor_hint():
			match v:
				enums.gravity_field_types.ZERO:
					area.gravity = 0.0
				enums.gravity_field_types.DIRECTION:
					area.gravity = enums.DEFAULT_GRAVITY

@export var gravity_direction: Vector3 = Vector3(0, -1.0, 0):
	get:
		return _gravity_direction
	set(v):
		_gravity_direction = v
		gravity_direction = v
		if Engine.is_editor_hint():
			area.gravity_direction = v
		

const MAX_SIZE: Vector3 = Vector3(100, 100, 100)
const MIN_SIZE: Vector3 = Vector3(1, 1, 1)


func _ready() -> void:
	collision.shape = BoxShape3D.new()
	if !Engine.is_editor_hint():
		# Setting the gravity fields size and particles
		collision.shape.size = field_size
		particles.emission_box_extents = collision.shape.size / 2.0
		fog.size = field_size
		var t: Vector3 = collision.shape.size / Vector3(0.5, 0.5, 0.5)
		particles.amount = roundi((t.x + t.y + t.z) / 3.0) * 15
		# Setting the gravity type
		match gravity_type:
			enums.gravity_field_types.ZERO:
				area.gravity = 0.0
			enums.gravity_field_types.DIRECTION:
				area.gravity = enums.DEFAULT_GRAVITY
		# Setting the gravity direction
		area.gravity_direction = gravity_direction
