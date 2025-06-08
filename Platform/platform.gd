@tool
extends Node3D


@onready var pivot: Node3D = $Pivot
@onready var body: AnimatableBody3D = $Body
@onready var mesh: CSGBox3D = $Body/Shape/Mesh
@onready var shape: CollisionShape3D = $Body/Shape

@onready var destination: Node3D = $Destination
@onready var wait_timer: Timer = $"Wait Timer"

var _size: Vector3 = Vector3.ONE
var _destination_pos: Vector3 = Vector3.ZERO
var _time: float = 1.0
var _rot_speed: Vector3 = Vector3.ZERO
var _wait_time: float = 0.0


@export var size: Vector3 = Vector3.ONE:
	get:
		return _size
	set(v):
		_size = v
		size = v
		if Engine.is_editor_hint():
			body = $Body
			for s in body.get_children():
				s.shape = BoxShape3D.new()
				s.shape.size = v
				var m: CSGBox3D = s.get_child(0)
				m.size = v

@export var destination_pos: Vector3 = Vector3.ZERO:
	get:
		return _destination_pos
	set(v):
		_destination_pos = v
		destination_pos = v
		if Engine.is_editor_hint():
			destination = $Destination
			destination.position = _destination_pos

@export var time: float = 1.0:
	get:
		return _time
	set(v):
		_time = clampf(v, 0.0, 30.0)
		time = _time

@export var rot_speed: Vector3 = Vector3.ZERO:
	get:
		return _rot_speed
	set(v):
		_rot_speed = v
		rot_speed = v

@export var wait_time: float = 0.0:
	get:
		return _wait_time
	set(v):
		_wait_time = clampf(v, 0.0, 30.0)
		wait_time = v

@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_QUART

var is_going_to: bool = true


func _ready() -> void:
	set_physics_process(false)
	for s in body.get_children():
		s.shape = BoxShape3D.new()
		s.shape.size = size
		var m: CSGBox3D = s.get_child(0)
		m.size = size
	if !Engine.is_editor_hint():
		if rot_speed != Vector3.ZERO:
			set_physics_process(true)
		else:
			body.constant_angular_velocity = rot_speed
		#for s in body.get_children():
			#s.size = size
			#var m: CSGBox3D = s.get_child(0)
			#m.size = size
		destination.position = _destination_pos
		destination.hide()
		if destination_pos != Vector3.ZERO:
			var pos_tween := get_tree().create_tween()
			pos_tween.tween_property(body, "global_position", destination.global_position, time).set_ease(ease_type).set_trans(trans_type)
			if wait_time > 0.0:
				pos_tween.finished.connect(func(): wait_timer.start(wait_time))
			else:
				pos_tween.finished.connect(_on_wait_timer_timeout)


func _physics_process(delta: float) -> void:
	body.rotate_x(rot_speed.x * delta)
	body.rotate_y(rot_speed.y * delta)
	body.rotate_z(rot_speed.z * delta)


func _on_wait_timer_timeout() -> void:
	if is_going_to:
		is_going_to = false
		var pos_tween := get_tree().create_tween()
		pos_tween.tween_property(body, "global_position", global_position, time).set_ease(ease_type).set_trans(trans_type)
		if wait_time > 0.0:
			pos_tween.finished.connect(func(): wait_timer.start(wait_time))
		else:
			pos_tween.finished.connect(_on_wait_timer_timeout)
	else:
		is_going_to = true
		var pos_tween := get_tree().create_tween()
		pos_tween.tween_property(body, "global_position", destination.global_position, time).set_ease(ease_type).set_trans(trans_type)
		if wait_time > 0.0:
			pos_tween.finished.connect(func(): wait_timer.start(wait_time))
		else:
			pos_tween.finished.connect(_on_wait_timer_timeout)
