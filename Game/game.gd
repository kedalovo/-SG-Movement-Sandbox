extends Node3D

@onready var label: Label = $"UI Viewport/SubViewport/UI/VBoxContainer/Label"
@onready var label_2: Label = $"UI Viewport/SubViewport/UI/VBoxContainer/Label2"
@onready var label_3: Label = $"UI Viewport/SubViewport/UI/VBoxContainer/Label3"

@onready var player: Player = $Player

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		quit_game()


func _process(_delta: float) -> void:
	pass


func quit_game():
	get_tree().quit()
