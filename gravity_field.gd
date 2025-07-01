@tool
extends Node3D


@onready var collision: CollisionShape3D = $Area/Collision
@onready var particles: CPUParticles3D = $Particles
@onready var fog: FogVolume = $Fog
@onready var area: Area3D = $Area

var _field_size: Vector3 = Vector3(1.0, 1.0, 1.0)
var _gravity_type: enums.gravity_field_types = enums.gravity_field_types.ZERO
var _gravity_direction: Vector3 = Vector3(0.0, -1.0, 0.0)
var _gravity_force: float = 9.8
var _is_glowing: bool = false

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
		if !Engine.is_editor_hint():
			match v:
				enums.gravity_field_types.ZERO:
					$Area.gravity = 0.0
					$Area.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
				enums.gravity_field_types.DIRECTION:
					$Area.gravity = gravity_force
					$Area.gravity_space_override = Area3D.SPACE_OVERRIDE_COMBINE

@export var gravity_direction: Vector3 = Vector3(0, -1.0, 0):
	get:
		return _gravity_direction
	set(v):
		_gravity_direction = v
		gravity_direction = v
		if !Engine.is_editor_hint():
			$Area.gravity_direction = v

@export var gravity_force: float = 9.8:
	get:
		return _gravity_force
	set(v):
		_gravity_force = v
		gravity_force = v
		if !Engine.is_editor_hint():
			$Area.gravity = v

@export var is_glowing: bool = false:
	get:
		return _is_glowing
	set(v):
		_is_glowing = v
		is_glowing = v
		$Particles.mesh = SphereMesh.new()
		$Particles.mesh.radius = 0.08
		$Particles.mesh.height = 0.16
		$Particles.mesh.radial_segments = 8
		$Particles.mesh.rings = 4
		$Particles.mesh.material = StandardMaterial3D.new()
		$Particles.mesh.material.transparency = BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA
		$Particles.mesh.material.vertex_color_use_as_albedo = true
		$Particles.mesh.material.albedo_color = Color("ffa100")
		$Particles.mesh.material.emission_enabled = v
		$Particles.mesh.material.emission = Color("ffa100")
		$Particles.mesh.material.emission_energy_multiplier = 100.0


const MAX_SIZE: Vector3 = Vector3(100, 100, 100)
const MIN_SIZE: Vector3 = Vector3(1, 1, 1)


func _ready() -> void:
	collision.shape = BoxShape3D.new()
	particles.mesh = SphereMesh.new()
	particles.mesh.radius = 0.08
	particles.mesh.height = 0.16
	particles.mesh.radial_segments = 8
	particles.mesh.rings = 4
	particles.mesh.material = StandardMaterial3D.new()
	particles.mesh.material.transparency = BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA
	particles.mesh.material.vertex_color_use_as_albedo = true
	particles.mesh.material.albedo_color = Color("ffa100")
	particles.mesh.material.emission_enabled = is_glowing
	particles.mesh.material.emission = Color("ffa100")
	particles.mesh.material.emission_energy_multiplier = 100.0
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
				area.gravity = gravity_force
		# Setting the gravity direction
		area.gravity_direction = gravity_direction


func _on_area_body_entered(body: Node3D) -> void:
	if body is Player and gravity_type == enums.gravity_field_types.ZERO:
		body.is_in_gravity = true


func _on_area_body_exited(body: Node3D) -> void:
	if body is Player and gravity_type == enums.gravity_field_types.ZERO:
		body.is_in_gravity = false
