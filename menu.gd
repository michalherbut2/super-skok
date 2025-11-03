extends Node2D

# Lista dostępnych trybów
#var available_modes = ["Tryb 1", "Tryb 2", "Tryb 3", "Tryb 4", "Tryb 5"]
var available_modes = [1,2,3,4,5]

# Dwa sloty na wybrane opcje
var selected_slots = [null, null]

# Referencje do przycisków i slotów
@onready var buttons = $VBoxContainer.get_children()
@onready var slot_labels = $HBoxContainer.get_children()

@onready var start_button = $ButtonStart
@export var player_node_path : NodePath  # wskazanie węzła gracza

func _ready():
	# Podłącz sygnały przycisków
	for i in range(buttons.size()):
		buttons[i].text = str(available_modes[i])
		buttons[i].pressed.connect(Callable(self, "_on_button_pressed").bind(i))

	start_button.pressed.connect(_on_start_pressed)
	_update_slots()

func _on_start_pressed():
	# Pobranie referencji do gracza
	var player = get_node(player_node_path)
	if player == null:
		print("Błąd: nie znaleziono gracza!")
		return

	# Wpisz wybrane tryby do gracza
	player.available_modes.clear()
	for mode in selected_slots:
		if mode != null:
			player.available_modes.append(mode)

	# Ustaw pierwszy tryb jako aktualny
	if player.available_modes.size() > 0:
		player.current_mode = player.available_modes[0]

	print(player.current_mode)
	print(player.available_modes.size())
	# Ukryj menu
	visible = false

func _on_button_pressed(index):
	var mode = available_modes[index]
	
	# Sprawdź, czy tryb jest już w slotach
	var found_slot = -1
	for i in range(selected_slots.size()):
		if selected_slots[i] == mode:
			found_slot = i
			break

	if found_slot != -1:
		# Tryb jest już wybrany → usuń go
		selected_slots[found_slot] = null
	else:
		# Dodaj tryb do pierwszego wolnego slotu
		for i in range(selected_slots.size()):
			if selected_slots[i] == null:
				selected_slots[i] = mode
				break

	_update_slots()

func _update_slots():
	for i in range(slot_labels.size()):
		slot_labels[i].text = str(selected_slots[i]) if selected_slots[i] != null else "(pusty)"
