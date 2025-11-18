extends Area2D

func _ready():
	# Podłącz sygnał wejścia ciała (jeśli nie robisz tego w edytorze)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Sprawdź, czy to gracz
	if body.is_in_group("player"):
		print("Gracz wypadł z mapy! Restart poziomu.")
		
		# Bezpieczne przeładowanie sceny (Call Deferred jest bezpieczniejsze dla fizyki)
		call_deferred("_reload_level")

func _reload_level():
	get_tree().reload_current_scene()
