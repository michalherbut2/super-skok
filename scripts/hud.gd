# HUD.gd
extends CanvasLayer

@onready var mode_label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer_Mode/LabelMode
@onready var mode_icon = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer_Mode/IconMode
@onready var coin_label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer_Coins/LabelCoin

# Słownik ikon (jeśli używasz Labeli z emoji jako ikon)
var mode_icons = {
	GameManager.MovementMode.WALK: "🏃‍♂️",
	GameManager.MovementMode.FLY: "🎈",
	GameManager.MovementMode.CLIMB: "🧗",
	GameManager.MovementMode.SWIM: "🏊",
	GameManager.MovementMode.SLIDE: "🧊"
}

func _ready():
	# 1. Policz monety na starcie poziomu
	# Musimy poczekać ułamek sekundy, aż cała mapa się załaduje
	await get_tree().process_frame
	GameManager.reset_coins()
	
	# 2. Podłącz się pod sygnał zmiany monet
	GameManager.coins_updated.connect(_on_coins_updated)
	
	# 3. Odśwież tryb na start
	update_mode_display()

func _process(delta):
	# Sprawdzamy czy tryb się zmienił (prosty sposób)
	# Można to też zrobić na sygnałach, ale w _process jest łatwiej na początek
	update_mode_display()

func update_mode_display():
	var current = GameManager.current_mode
	var mode_name = GameManager.all_mode_names[current]
	
	mode_label.text = mode_name
	
	# Jeśli używasz Labela jako ikony:
	if mode_icon is Label:
		mode_icon.text = mode_icons.get(current, "❓")
	
	# Opcjonalnie: Zmień kolor tekstu w zależności od trybu
	match current:
		GameManager.MovementMode.FLY: mode_label.modulate = Color.SKY_BLUE
		GameManager.MovementMode.CLIMB: mode_label.modulate = Color.SADDLE_BROWN
		GameManager.MovementMode.SWIM: mode_label.modulate = Color.AQUA
		_: mode_label.modulate = Color.WHITE

func _on_coins_updated(collected, total):
	# Formatowanie tekstu: "3 / 10"
	coin_label.text = str(collected) + " / " + str(total)
	
	# --- EFEKT "JUICE" (SOCZYSTOŚĆ) ---
	# Powiększ tekst na chwilę, gdy zbierzesz monetę (prosta animacja)
	var tween = create_tween()
	coin_label.scale = Vector2(1.5, 1.5) # Powiększ
	tween.tween_property(coin_label, "scale", Vector2(1.0, 1.0), 0.2) # Wróć do normy
