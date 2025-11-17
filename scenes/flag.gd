# Flag.gd (na węźle Area2D)
extends Node2D

var player_in_area = false
#@export var player_node_path : CharacterBody2D

#var menu_node = null

#func _ready():
	## Znajdź menu, gdy poziom się załaduje
	#await get_tree().create_timer(0.1) 
	#menu_node = get_node(player_node_path).
	#if menu_node == null:
		#print("Flaga nie może znaleźć Menu!")

func _on_body_entered(body):
	print("FLAGA szedł")
	if body.is_in_group("player"): # Pamiętaj, by gracz był w grupie "player"
		print("grupa")
		player_in_area = true
		
		## Otwórz menu od razu po wejściu, nie czekaj na klawisz
		#if menu_node and not menu_node.visible:
			#print("Otwieram menu zmiany trybów")
			#menu_node.visible = true
			#get_tree().paused = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false


func _unhandled_input(event):
	# Sprawdź, czy gracz jest w strefie i czy nacisnął klawisz
	if player_in_area and event.is_action_pressed("use"):
		
		# Sprawdź, czy menu istnieje i jest ukryte
		if $Menu and not $Menu.visible:
			print("Otwieram menu zmiany trybów")
			
			# Oznacz, że event został obsłużony (aby nic innego na niego nie reagowało)
			get_tree().get_root().set_input_as_handled()
			
			if $Menu.visible:
				# JEŚLI JEST WIDOCZNE: Ukryj je i odpauzuj grę
				print("Zamykam menu")
				$Menu.visible = false
				get_tree().paused = false
			else:
				# JEŚLI JEST UKRYTE: Pokaż je i zapauzuj grę
				print("Otwieram menu zmiany trybów")
				$Menu.visible = true
				get_tree().paused = true
