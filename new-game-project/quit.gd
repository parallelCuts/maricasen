extends Button
@onready var sfx = $AudioStreamPlayer

func _on_button_up() -> void:
	sfx.play(0.0)

func _on_audio_stream_player_finished() -> void:
	get_tree().quit(0)
