@tool
extends Node3D

@onready var body: AnimatableBody3D = $Body
@onready var mesh: CSGBox3D = $Body/Mesh
@onready var shape: CollisionShape3D = $Body/Shape

@onready var destination: Node3D = $Destination

var _size: Vector3 = Vector3.ONE
var _destination_pos: Vector3 = Vector3.ZERO
var _time: float = 0.0
var _rot_x_speed: float = 0.0
var _rot_y_speed: float = 0.0
var _rot_z_speed: float = 0.0


@export var size: Vector3 = Vector3.ONE:
	get:
		return _size
	set(v):
		_size = v
		size = v
		mesh.size = v
		shape.shape.size = v


func _ready() -> void:
	shape.shape = BoxShape3D.new()
