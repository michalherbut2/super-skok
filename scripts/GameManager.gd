# GameManager.gd
extends Node

# PRZENOSIMY ENUM TUTAJ - to jest teraz globalna definicja
# WALK = 0, FLY = 1, CLIMB = 2, SWIM = 3, SLIDE = 4
enum MovementMode { WALK, FLY, CLIMB, SWIM, SLIDE }

# Lista wszystkich trybów (dla menu)
var all_modes = [
	MovementMode.WALK,
	MovementMode.FLY,
	MovementMode.CLIMB,
	MovementMode.SWIM,
	MovementMode.SLIDE
]
# Nazwy trybów (dla menu)
var all_mode_names = ["Chodzenie", "Latanie", "Wspinaczka", "Pływanie", "Ślizg"]


# Dwa wybrane tryby przez gracza
var selected_modes : Array = [MovementMode.WALK, MovementMode.FLY] # Domyślne na start

# Aktualnie "aktywny" tryb z tych dwóch
var current_mode : MovementMode = MovementMode.WALK


# Menu (lub Domek) wywoła tę funkcję, by zapisać wybór gracza
func set_selected_modes(mode1: MovementMode, mode2: MovementMode):
	selected_modes = [mode1, mode2]
	# Ustaw pierwszy wybrany jako domyślnie aktywny
	current_mode = selected_modes[0]
	print("GameManager: Zapisano nowe tryby: ", selected_modes)


# Gracz (Player) wywoła tę funkcję, by przełączyć między dwoma trybami
func switch_mode():
	if selected_modes.size() < 2:
		return # Zabezpieczenie, jeśli nie ma co przełączać

	if current_mode == selected_modes[0]:
		current_mode = selected_modes[1]
	else:
		current_mode = selected_modes[0]
	
	print("GameManager: Przełączono tryb na: ", MovementMode.keys()[current_mode])
