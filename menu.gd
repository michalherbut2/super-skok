# Menu.gd
extends Control #, jeśli to scena UI

@export var is_main_menu : bool = false # Domyślnie jest to menu "w domku"

# NIE POTRZEBUJEMY JUŻ 'available_modes', 'mode_names' ani 'player_node_path'
# Wszystko pobierzemy z GameManager!

var selected_slots = [null, null] # To jest OK, to lokalny stan menu

@onready var buttons = $VBoxContainer.get_children()
@onready var slot_labels = [$HBoxContainer/Label, $HBoxContainer/Label2]
@onready var start_button = $ButtonStart
# @export var player_node_path : NodePath  <- USUŃ TO

func _ready():
	# Podłącz sygnały i ustaw tekst przycisków z GameManager
	for i in range(buttons.size()):
		if i < GameManager.all_mode_names.size():
			buttons[i].text = GameManager.all_mode_names[i]
			buttons[i].pressed.connect(_on_button_pressed.bind(i))
		else:
			buttons[i].visible = false # Ukryj dodatkowe przyciski, jeśli jest ich za dużo

	start_button.pressed.connect(_on_start_pressed)
	_update_slots()

func _on_start_pressed():
	# 1. Sprawdź, czy wybrano DWA tryby
	if selected_slots[0] == null or selected_slots[1] == null:
		print("Wybierz dwa tryby!")
		# Tutaj możesz dodać jakiś Label, który mówi graczowi, że musi wybrać 2 tryby
		return # Przerwij funkcję, jeśli nie wybrano dwóch

	# 2. Zapisz wybrane tryby do GameManager
	GameManager.set_selected_modes(selected_slots[0], selected_slots[1])

	# 3. ZDECYDUJ, CO ZROBIĆ DALEJ (TO JEST NOWA CZĘŚĆ)
	if is_main_menu:
		# ----- JESTEŚMY W MAIN MENU -----
		# Zmień scenę na pierwszy poziom
		# Upewnij się, że ścieżka do Level_0 jest poprawna!
		var error = get_tree().change_scene_to_file("res://scenes/level_0.tscn")
		
		if error != OK:
			print("Błąd podczas ładowania sceny Level_0: ", error)
	
	else:
		# ----- JESTEŚMY W DOMKU NA POZIOMIE -----
		# Ukryj menu i odpauzuj grę
		visible = false
		get_tree().paused = false
		
		# Znajdź gracza i zaktualizuj jego HUD
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player._update_hud()


func _on_button_pressed(index):
	# Pobierz tryb (enum) z GameManager
	var mode = GameManager.all_modes[index]
	
	# Logika wyboru jest OK, ale upewnij się, że działa na ENUM
	var found_slot = -1
	for i in range(selected_slots.size()):
		if selected_slots[i] == mode:
			found_slot = i
			break

	if found_slot != -1:
		selected_slots[found_slot] = null
	else:
		for i in range(selected_slots.size()):
			if selected_slots[i] == null:
				selected_slots[i] = mode
				break

	_update_slots()

func _update_slots():
	for i in range(slot_labels.size()):
		if selected_slots[i] != null:
			# Użyj nazwy z GameManager
			slot_labels[i].text = GameManager.all_mode_names[selected_slots[i]]
		else:
			slot_labels[i].text = "(pusty)"
