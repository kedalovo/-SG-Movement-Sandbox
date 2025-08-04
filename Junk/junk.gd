extends RigidBody3D


class_name Junk


@onready var audio: AudioStreamPlayer3D = $Audio


func _ready() -> void:
	audio.pitch_scale = (randf() - 0.5) / 5.0 + 1.0


func play_sound() -> void:
	audio.play()


func _on_body_entered(body: Node) -> void:
	if body is not Player:
		play_sound()
