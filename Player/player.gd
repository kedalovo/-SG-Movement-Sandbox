extends CharacterBody3D


class_name Player


signal shooting(pos: Vector3, direction: Vector3)


@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 15.0
@export var max_speed: float = 8.0
@export var sprint_speed: float = 4.0
@export var air_control: float = 0.5
@export var air_friction: float = 0.1
@export var gravity_control: float = 0.15
@export var floor_friction: float = 2.0

@export var zoom_limit: float = 5.0
@export var zoom_force: float = 0.2

@export_range(0.1, 2.0, 0.01) var mouse_sensitivity: float = 1.0
@export var max_head_angle: float = 75.0
@export var min_head_angle: float = -75.0

@export var bounce_factor: float = 1.0

@onready var camera_gymbal: Marker3D = $"Camera Gymbal"
@onready var right_marker: Marker3D = $"Right Marker"
@onready var up_marker: Marker3D = $"Up Marker"
@onready var shoot_reference: Marker3D = $"Camera Gymbal/Shoot Reference"
@onready var position_offset: Marker3D = $"Camera Gymbal/Position Offset"

@onready var coyote_timer: Timer = $"Coyote Timer"
@onready var shoot_timer: Timer = $"Shoot Timer"

var direction: Vector3 = Vector3.ZERO

var checkpoint: Vector3 = Vector3(0.0, 3.0, 0.0)

var additional_speed: float = 0.0

var _is_in_gravity: bool = false

var is_in_gravity: bool = false:
	get:
		return _is_in_gravity
	set(v):
		_is_in_gravity = v
		is_in_gravity = v
		if v:
			motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		toggle_gravity(v)

var is_moving: bool = false
var is_coyote_time: bool = false
var has_landed: bool = false
var can_shoot: bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if is_in_gravity:
			var right_dir: Vector3 = (right_marker.global_position - global_position).normalized()
			var up_dir: Vector3 = (up_marker.global_position - global_position).normalized()
			
			rotate(right_dir, deg_to_rad(-event.screen_relative.y) * mouse_sensitivity)
			rotate(up_dir, deg_to_rad(-event.screen_relative.x) * mouse_sensitivity)
		else:
			rotation.y += deg_to_rad(-event.screen_relative.x) * mouse_sensitivity
			
			var final_x_rotation = camera_gymbal.rotation.x + deg_to_rad(-event.screen_relative.y) * mouse_sensitivity
			if final_x_rotation > deg_to_rad(min_head_angle) and final_x_rotation < deg_to_rad(max_head_angle):
				camera_gymbal.rotation.x = final_x_rotation
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.is_pressed() and e.button_index == MOUSE_BUTTON_LEFT and can_shoot:
			can_shoot = false
			shoot_timer.start()
			shooting.emit(global_position, shoot_reference.global_position - global_position)
		elif e.is_pressed() and e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			position_offset.position.z = clampf(position_offset.position.z + zoom_force, 0.0, zoom_limit)
		elif e.is_pressed() and e.button_index == MOUSE_BUTTON_WHEEL_UP:
			position_offset.position.z = clampf(position_offset.position.z - zoom_force, 0.0, zoom_limit)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		has_landed = true
	else:
		if !is_coyote_time and has_landed:
			is_coyote_time = true
			has_landed = false
			coyote_timer.start()
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(&"move_jump") and (is_on_floor() or is_coyote_time) and !is_in_gravity:
		velocity.y = jump_velocity
	
	if Input.is_action_pressed(&"rotate_clockwise") and is_in_gravity:
		rotation.z -= delta / 2
	if Input.is_action_pressed(&"rotate_counter_clockwise") and is_in_gravity:
		rotation.z += delta / 2

	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if input_dir == Vector2.ZERO:
		is_moving = false
	else:
		is_moving = true
	
	if Input.is_action_pressed(&"move_sprint") and !is_in_gravity:
		additional_speed = move_toward(additional_speed, sprint_speed, delta * acceleration / 2)
	elif is_on_floor():
		additional_speed = move_toward(additional_speed, 0.0, delta * acceleration / 2)
	
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		if is_in_gravity:
			velocity = velocity.move_toward(direction * max_speed, delta * acceleration * gravity_control)
		else:
			var new_velocity: Vector2 = Vector2(velocity.x, velocity.z)
			var new_direction: Vector2 = Vector2(direction.x, direction.z)
			if is_on_floor():
				new_velocity = new_velocity.move_toward(new_direction * (max_speed + additional_speed), delta * acceleration)
			else:
				new_velocity = new_velocity.move_toward(new_direction * (max_speed + additional_speed), delta * acceleration * air_control)
			velocity.x = new_velocity.x
			velocity.z = new_velocity.y
	else:
		if is_in_gravity:
			velocity = velocity.move_toward(Vector3.ZERO, delta * acceleration * gravity_control)
		else:
			var new_velocity: Vector2 = Vector2(velocity.x, velocity.z)
			if is_on_floor():
				new_velocity = new_velocity.move_toward(Vector2.ZERO, delta * acceleration * floor_friction)
			else:
				new_velocity = new_velocity.move_toward(Vector2.ZERO, delta * acceleration * air_friction)
			velocity.x = new_velocity.x
			velocity.z = new_velocity.y

	var col := move_and_slide()
	if col and is_in_gravity:
		velocity = velocity.bounce(get_last_slide_collision().get_normal()) * bounce_factor


func toggle_gravity(on: bool) -> void:
	if on:
		get_tree().create_tween().tween_property(self, "rotation:x", camera_gymbal.rotation.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(camera_gymbal, "rotation:x", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	else:
		get_tree().create_tween().tween_property(camera_gymbal, "rotation:x", rotation.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(self, "rotation:x", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(self, "rotation:z", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func reset() -> void:
	velocity = Vector3.ZERO
	global_position = checkpoint


func _on_coyote_timer_timeout() -> void:
	is_coyote_time = false


func _on_shoot_timer_timeout() -> void:
	can_shoot = true
