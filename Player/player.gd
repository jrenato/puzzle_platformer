class_name Player extends CharacterBody2D

@export var player_camera: PackedScene
@export var camera_height = 126

@export var player_sprite: AnimatedSprite2D

@export var movement_speed: int = 300
@export var gravity: int = 30
@export var jump_strength: int = 600
@export var max_jumps: int = 1

@onready var initial_sprite_scale: Vector2 = player_sprite.scale

var owner_id: int = 1
var jump_count: int = 0
var camera_instance: Camera2D
var state: PlayerState = PlayerState.IDLE

enum PlayerState {
	IDLE,
	WALKING,
	JUMP_STARTED,
	JUMPING,
	DOUBLE_JUMPING,
	FALLING
}

func _enter_tree() -> void:
	player_sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

	owner_id = name.to_int()
	set_multiplayer_authority(owner_id)

	if owner_id != multiplayer.get_unique_id():
		return

	setup_up_camera()


func _process(delta: float) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	if owner_id != multiplayer.get_unique_id():
		return

	update_camera_position()


func _physics_process(delta: float):
	if multiplayer.multiplayer_peer == null:
		return
	if owner_id != multiplayer.get_unique_id():
		return

	# Get player input
	var horizontal_input: float = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)

	# Apply velocity
	velocity.x = horizontal_input * movement_speed
	velocity.y += gravity

	handle_movement_state()

	move_and_slide()

	face_movement_direction(horizontal_input)


func setup_up_camera() -> void:
	camera_instance = player_camera.instantiate()
	camera_instance.global_position.y = camera_height
	get_tree().current_scene.add_child.call_deferred(camera_instance)


func update_camera_position() -> void:
	camera_instance.global_position.x = global_position.x


func handle_movement_state() -> void:
	# Decide state
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = PlayerState.JUMP_STARTED
	elif is_on_floor() and is_zero_approx(velocity.x):
		state = PlayerState.IDLE
	elif is_on_floor() and not is_zero_approx(velocity.x):
		state = PlayerState.WALKING
	else:
		state = PlayerState.JUMPING

	if velocity.y > 0.0 and not is_on_floor():
		if Input.is_action_just_pressed("jump"):
			state = PlayerState.DOUBLE_JUMPING
		else:
			state = PlayerState.FALLING

	# Process state
	match state:
		PlayerState.IDLE:
			player_sprite.play("idle")
			jump_count = 0
		PlayerState.WALKING:
			player_sprite.play("walk")
			jump_count = 0
		PlayerState.JUMP_STARTED:
			player_sprite.play("jump_start")
			jump_count += 1
			velocity.y = -jump_strength
		PlayerState.DOUBLE_JUMPING:
			player_sprite.play("double_jump_start")
			jump_count += 1
			if jump_count <= max_jumps:
				velocity.y = -jump_strength
		PlayerState.FALLING:
			player_sprite.play("fall")

	# Jump cancelling
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y = 0.0


func face_movement_direction(horizontal_input: float) -> void:
	# Update player sprite flip
	if not is_zero_approx(horizontal_input):
		if horizontal_input < 0:
			player_sprite.scale = Vector2(-initial_sprite_scale.x, initial_sprite_scale.y)

		if horizontal_input > 0:
			player_sprite.scale = initial_sprite_scale


func _on_animated_sprite_2d_animation_finished() -> void:
	if state == PlayerState.JUMPING:
		player_sprite.play("jump")
