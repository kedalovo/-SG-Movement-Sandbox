extends RigidBody3D


class_name Pellet


@onready var area: Area3D = $Area
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mesh: CSGMesh3D = $CSGMesh3D
@onready var pop_sound: AudioStreamPlayer3D = $"Pop Sound"


@export var force: int = 0
@export var repel_force: int = 0


func _ready() -> void:
	var new_mesh := SphereMesh.new()
	new_mesh.radius = 0.2
	new_mesh.height = 0.4
	new_mesh.radial_segments = 16
	new_mesh.rings = 8
	
	var new_material := StandardMaterial3D.new()
	new_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	new_material.albedo_color = Color("5c67ff")
	
	new_mesh.material = new_material
	mesh.mesh = new_mesh


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"Floor") or body.is_in_group(&"Junk"):
		explode()


func explode() -> void:
	pop_sound.play()
	for body in area.get_overlapping_bodies():
		if body.is_in_group(&"Junk"):
			body.apply_impulse((body.global_position - global_position).normalized() * repel_force)
		elif body is Player:
			body.velocity += (body.global_position - global_position).normalized() * repel_force * 2
	animation_player.play(&"explode")
