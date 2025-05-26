extends Node3D

const CAN = preload("res://Junk/Can/can.tscn")
const BALL = preload("res://Junk/Ball/ball.tscn")
const CUBE = preload("res://Junk/Cube/cube.tscn")
const PELLET = preload("res://Pellet/pellet.tscn")

@onready var player: Player = $Player

@onready var junk: Node3D = $Junk
@onready var pellets: Node3D = $Pellets

@export var amount_of_cans: int = 0
@export var amount_of_balls: int = 0
@export var amount_of_cubes: int = 0

@onready var ray1: RayCast3D = $Node3D/RayCast3D
@onready var ray2: RayCast3D = $Node3D/RayCast3D2

func _ready() -> void:
	
	ray2.target_position = ray2.target_position.rotated(ray2.target_position.cross(ray1.target_position).normalized(), deg_to_rad(45))
	
	for i in amount_of_cans:
		var can: = CAN.instantiate()
		junk.add_child(can)
		can.position.x = randf_range(-25.0, 25.0)
		can.position.z = randf_range(-25.0, 25.0)
	for i in amount_of_balls:
		var ball: = BALL.instantiate()
		junk.add_child(ball)
		ball.position.x = randf_range(-25.0, 25.0)
		ball.position.z = randf_range(-25.0, 25.0)
	for i in amount_of_cubes:
		var cube: = CUBE.instantiate()
		junk.add_child(cube)
		cube.position.x = randf_range(-25.0, 25.0)
		cube.position.z = randf_range(-25.0, 25.0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		quit_game()


func _process(_delta: float) -> void:
	pass


func quit_game():
	get_tree().quit()


func _on_player_shooting(pos: Vector3, direction: Vector3) -> void:
	var pellet := PELLET.instantiate()
	pellets.add_child(pellet)
	pellet.global_position = pos
	pellet.apply_impulse(direction * pellet.force)
