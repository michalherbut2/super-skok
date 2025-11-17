# Star.gd
extends Area2D

# Upewnij się, że masz scenę Level_2 zapisaną pod tą ścieżką!
var next_level_path = "res://scenes/level_1.tscn"

func _on_body_entered(body):
	# Sprawdź, czy to gracz
	if body.is_in_group("player"):
		print("Przechodzę do następnego poziomu!")
		
		# Opcjonalnie: Zapisz grę lub stan w GameManager
		# ...
		
		# Załaduj następny poziom
		get_tree().change_scene_to_file(next_level_path)
