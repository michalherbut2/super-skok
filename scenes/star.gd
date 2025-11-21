# Star.gd
extends Area2D

# Upewnij się, że masz scenę Level_2 zapisaną pod tą ścieżką!
var next_level_path = "res://scenes/level_1.tscn"

func _on_body_entered(body):
	# Sprawdź, czy to gracz
	if body.is_in_group("player"):
		# Sprawdź, ile monet zostało na mapie
		var remaining_coins = get_tree().get_nodes_in_group("coins")
		
		if remaining_coins.size() == 0:
			# --- WSZYSTKO ZEBRANE ---
			print("Brawo! Wszystkie monety zebrane. Przechodzę dalej.")
			call_deferred("_change_level")
		else:
			# --- CZEGOŚ BRAKUJE ---
			print("Drzwi zamknięte! Pozostało monet: ", remaining_coins.size())
			# Tutaj możesz wyświetlić dymek z tekstem nad gwiazdką, np. "Zbierz resztę monet!"

func _change_level():
	get_tree().change_scene_to_file(next_level_path)
