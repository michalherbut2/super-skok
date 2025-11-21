# Coin.gd
extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Powiadom menedżera
		GameManager.collect_coin()
		
		# Opcjonalnie: Tu dodaj dźwięk zbierania ($AudioStreamPlayer.play())
		print("Moneta zebrana!")
		
		# Efekt dźwiękowy i usunięcie
		$AudioStreamPlayer2D.play()
		
		# Usuń monetę ze świata
		queue_free()
