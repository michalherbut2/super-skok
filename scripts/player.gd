extends CharacterBody2D

@export var speed = 300
@export var gravity = 30
@export var jump_force = 300
@export var max_fall_speed = 1000

# parametry do trybu "pływanie"
@export var swim_speed = 150
@export var swim_up_force = 150
@export var max_air = 3.0 # sekundy pod wodą
var air_timer = 0.0

# aktualny tryb sterowania
var current_mode := "normal"
var available_modes = ["normal", "gravity", "swim", "wall_jump", "balloon"]

func _physics_process(delta: float) -> void:
	# zmiana trybu (np. klawiszem Tab)
	if Input.is_action_just_pressed("switch_mode"):
		var i = available_modes.find(current_mode)
		current_mode = available_modes[(i + 1) % available_modes.size()]
		print("Tryb:", current_mode)

	match current_mode:
		"normal":
			_normal_mode(delta)
		"gravity":
			_gravity_mode(delta)
		"swim":
			_swim_mode(delta)
		"wall_jump":
			_wall_jump_mode(delta)
		"balloon":
			_balloon_mode(delta)

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

# 🏊 Pływanie
func _swim_mode(delta):
	var dir_x = Input.get_axis("move_left", "move_right")
	var dir_y = Input.get_axis("move_up", "move_down")
	velocity.x = dir_x * swim_speed
	velocity.y = dir_y * swim_speed
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
