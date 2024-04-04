extends CharacterBody2D

@export var player_sprite: AnimatedSprite2D

@export var movement_speed: int = 300
@export var gravity: int = 30
@export var jump_strength: int = 600
@export var max_jumps: int = 1

@onready var initial_sprite_scale: Vector2 = player_sprite.scale

var jump_count: int = 0

func _ready() -> void:
	player_sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)


func _physics_process(delta: float):
	# Get player input
	var horizontal_input: float = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)

	# Apply velocity
	velocity.x = horizontal_input * movement_speed
	velocity.y += gravity

	# Check player state
	var is_falling: bool = velocity.y > 0.0 and not is_on_floor()
	var is_jumping: bool = Input.is_action_just_pressed("jump") and is_on_floor()
	var is_double_jumping: bool = Input.is_action_just_pressed("jump") and is_falling
	var is_jumping_cancelled: bool = Input.is_action_just_released("jump") and velocity.y < 0.0
	var is_idle: bool = is_on_floor() and is_zero_approx(horizontal_input) 
	var is_walking: bool = is_on_floor() and not is_zero_approx(horizontal_input)


	if is_jumping:
		jump_count += 1
		velocity.y = -jump_strength
	elif is_double_jumping:
		jump_count += 1
		if jump_count <= max_jumps:
			velocity.y = -jump_strength
	elif is_jumping_cancelled:
		velocity.y = 0.0
	elif is_on_floor():
		jump_count = 0

	# Apply movement
	move_and_slide()


	# Update player sprite animation
	if is_jumping:
		player_sprite.play("jump_start")
	elif is_double_jumping:
		player_sprite.play("double_jump_start")
	elif is_walking:
		player_sprite.play("walk")
	elif is_falling:
		player_sprite.play("fall")
	elif is_idle:
		player_sprite.play("idle")


	# Update player sprite flip
	if not is_zero_approx(horizontal_input):
		if horizontal_input < 0:
			player_sprite.scale = Vector2(-initial_sprite_scale.x, initial_sprite_scale.y)

		if horizontal_input > 0:
			player_sprite.scale = initial_sprite_scale


func _on_animated_sprite_2d_animation_finished() -> void:
	player_sprite.play("jump")
