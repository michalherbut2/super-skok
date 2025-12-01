# Player.gd
extends CharacterBody2D

@export var hud_node_path : NodePath

@export var speed = 300
@export var gravity = 30
@export var jump_force = 450
@export var max_fall_speed = 1000

# parametry do trybu "pływanie"
@export var swim_speed = 150
@export var swim_up_force = 150
@export var max_air = 3.0 # sekundy pod wodą
var air_timer = 0.0

const CLIMB_SPEED = 200.0
var on_ladder: bool
var cllimbing: bool

func _on_body_entered(_body: Node2D):
	on_ladder = true
	print("wszedł w drabinę")

func _on_body_exited(_body: Node2D):
	on_ladder = false
	print("wyszedł w drabinę")

# Dodaj _ready, aby zaktualizować HUD na starcie poziomu
func _ready():
	_update_hud()

func _update_hud():
	# Czytamy globalny stan z GameManager
	var mode_name = GameManager.all_mode_names[GameManager.current_mode]
	# NOWA, BEZPIECZNA LOGIKA:
	if hud_node_path.is_empty():
		print("Ścieżka do HUD nie jest ustawiona w Player!")
		return

	var hud_node = get_node_or_null(hud_node_path)
	if hud_node:
		var hud_label = hud_node.get_node_or_null("Control/Label")
		if hud_label:
			hud_label.text = "Tryb: %s" % mode_name
		else:
			print("Nie znaleziono etykiety 'Control/Label' wewnątrz HUD!")
	else:
		print("Nie znaleziono węzła HUD na podanej ścieżce!")


func _physics_process(delta: float) -> void:
	# Zmiana trybu (teraz wywołuje funkcję w GameManager)
	if Input.is_action_just_pressed("switch_mode"):
		GameManager.switch_mode()
		_update_hud() # Zaktualizuj HUD po przełączeniu

	# MATCH STATEMENT TERAZ CZYTA Z GAMEMANAGER
	# Musisz użyć pełnej ścieżki do enum: GameManager.MovementMode.NAZWA
	match GameManager.current_mode:
		GameManager.MovementMode.WALK:
			_normal_mode(delta)
		GameManager.MovementMode.FLY:
			_balloon_mode(delta) # Zakładam, że FLY to balon
		GameManager.MovementMode.CLIMB:
			_climb_mode(delta) # Zrób nową funkcję dla wspinaczki
		GameManager.MovementMode.SWIM:
			_swim_mode(delta)
		GameManager.MovementMode.SLIDE:
			_gravity_mode(delta) # Zakładam, że SLIDE to grawitacja

# ⬅️➡️ Podstawowy ruch
func _normal_mode(delta):
	if !is_on_floor():
		velocity.y = min(velocity.y + gravity, max_fall_speed)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed
	move_and_slide()

# 🌀 Zmiana grawitacji
func _gravity_mode(delta):
	if Input.is_action_just_pressed("jump"):
		gravity = -gravity
		jump_force = -jump_force
	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed
	velocity.y = clamp(velocity.y + gravity, -max_fall_speed, max_fall_speed)
	move_and_slide()

# 🏊 wspinanie
#func _climb_mode(delta):
	#var grounded = is_on_floor()
	#if on_ladder:
		#var dir_x = Input.get_axis("move_left", "move_right")
		#var dir_y = Input.get_axis("move_up", "move_down")
		#if dir_y:
			#print("velocity.y: ", velocity.y, ", dir_y: ", dir_y, ", CLIMB_SPEED: ", CLIMB_SPEED)
			#velocity.y = dir_y * CLIMB_SPEED
			#cllimbing = not grounded
		#else:
			#velocity.y =move_toward(velocity.y, 0, CLIMB_SPEED)
			#if grounded: cllimbing = false
		##if cllimbing:
			##if dir_y
	#elif not grounded:
		#velocity += get_gravity()*delta
		##velocity.x = dir_x * swim_speed
		##velocity.y = dir_y * swim_speed
	#move_and_slide()
#
	## ograniczenie czasu pod wodą
	#if is_in_water():
		#air_timer += delta
		#if air_timer >= max_air:
			#print("💀 Topisz się!")
	#else:
		#air_timer = 0.0

func _climb_mode(delta):
	# Stała siła tarcia/hamowania w powietrzu (jak szybko tracisz prędkość)
	const AIR_FRICTION = 500.0 

	if on_ladder:
		# --- JESTEŚMY NA DRABINIE ---
		# Grawitacja nie działa, masz pełną kontrolę
		
		# Pobierz kierunek wspinaczki (góra/dół)
		var dir_y = Input.get_axis("move_up", "move_down")
		velocity.y = dir_y * CLIMB_SPEED
		
		# Pobierz kierunek wspinaczki (lewo/prawo)
		var dir_x = Input.get_axis("move_left", "move_right")
		velocity.x = dir_x * CLIMB_SPEED
		
	else:
		# --- NIE JESTEŚMY NA DRABINIE ---
		# W tym trybie nie można chodzić ani skakać. Gracz po prostu spada.
		
		# Zastosuj normalnie grawitację
		velocity.y = min(velocity.y + gravity, max_fall_speed)
		
		# Wytracaj prędkość poziomą (hamowanie w powietrzu)
		# Gracz nie ma kontroli nad ruchem lewo/prawo, gdy spada
		velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)

	# Wywołaj move_and_slide() RAZ na końcu funkcji, po całej logice
	move_and_slide()

# 🏊 Pływanie
func _swim_mode(delta):
	var grounded = is_on_floor()
	if on_ladder:
		var dir_x = Input.get_axis("move_left", "move_right")
		var dir_y = Input.get_axis("move_up", "move_down")
		if dir_y:
			print("velocity.y: ", velocity.y, ", dir_y: ", dir_y, ", CLIMB_SPEED: ", CLIMB_SPEED)
			velocity.y = dir_y * CLIMB_SPEED
			cllimbing = not grounded
		else:
			velocity.y =move_toward(velocity.y, 0, CLIMB_SPEED)
			if grounded: cllimbing = false
		#if cllimbing:
			#if dir_y
	elif not grounded:
		velocity += get_gravity()*delta
		#velocity.x = dir_x * swim_speed
		#velocity.y = dir_y * swim_speed
	move_and_slide()

	# ograniczenie czasu pod wodą
	if is_in_water():
		air_timer += delta
		if air_timer >= max_air:
			print("💀 Topisz się!")
	else:
		air_timer = 0.0

# 🕷️ Skakun (wall jump)
func _wall_jump_mode(delta):
	var dir = Input.get_axis("move_left", "move_right")
	if !is_on_floor():
		velocity.y += gravity
	if Input.is_action_just_pressed("jump") and is_on_wall():
		velocity.y = -jump_force
		velocity.x = -dir * speed * 1.5
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	velocity.x = dir * speed
	move_and_slide()

# 🎈 Balon (unoszenie się)
func _balloon_mode(delta):
	velocity.y = -gravity * 0.5  # powolne unoszenie
	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = lerp(velocity.x, dir * speed * 0.4, 0.1)
	move_and_slide()

# opcjonalne – możesz podpiąć czujnik wody przez CollisionLayer lub Area2D
func is_in_water() -> bool:
	# Na razie "fałszywa" funkcja – zawsze zwraca false,
	# ale możesz ją podpiąć do obszaru "wody"
	return false

func _update_coin_counter():
	# Pobierz liczbę monet z grupy
	var coins_left = get_tree().get_nodes_in_group("coins").size()
	
	# Znajdź Label w HUD (dostosuj ścieżkę do swojego HUD)
	# Załóżmy, że masz w HUD nowy Label o nazwie "CoinLabel"
	var coin_label = get_node_or_null(hud_node_path).get_node_or_null("Control/CoinLabel")
	
	if coin_label:
		coin_label.text = "Monety do zebrania: " + str(coins_left)

# I wywołuj to w _physics_process lub po zebraniu monety
