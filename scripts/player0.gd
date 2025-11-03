extends CharacterBody2D

enum MovementMode { WALK, FLY, CLIMB, SWIM, SLIDE }
var available_modes : Array = []   # w domu wybierzesz 2 tryby
var current_mode : int             # aktualnie wybrany tryb

@export var speed = 300
@export var gravity = 30
@export var jump_force = 300
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
	print("wszedł")

func _on_body_exited(_body: Node2D):
	on_ladder = false
	print("wyszedł")

# aktualny tryb sterowania
#var current_mode := "normal"
#var available_modes = ["normal", "gravity", "swim", "wall_jump", "balloon"]

#func _input(event):
	#if event.is_action_pressed("switch_mode"):
		#if available_modes.size() >= 2:
			#var idx = available_modes.find(current_mode)
			#current_mode = available_modes[(idx + 1) % available_modes.size()]
			#_update_hud()

func _update_hud():
	#$CanvasLayer/Label.text = "Tryb: %s" % MovementMode.keys()[current_mode]
	$HUD/Control/Label.text = "Tryb: %s" % MovementMode.keys()[current_mode]


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
		1:
			_normal_mode(delta)
		2:
			_swim_mode(delta)
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
