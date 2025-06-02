extends Control


@onready var label: Label = $VBoxContainer/Label
@onready var label_2: Label = $VBoxContainer/Label2
@onready var label_3: Label = $VBoxContainer/Label3

@onready var game: Node3D = $SubViewportContainer/SubViewport/Game


func _process(_delta: float) -> void:
	label.text = str(game.player.rotation)
	label_2.text = str(game.player.shoot_reference.global_position)
