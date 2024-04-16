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
var camera_instance


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
	# Get movement state
	var is_falling: bool = velocity.y > 0.0 and not is_on_floor()
	var is_jumping: bool = Input.is_action_just_pressed("jump") and is_on_floor()
	var is_double_jumping: bool = Input.is_action_just_pressed("jump") and is_falling
	var is_jumping_cancelled: bool = Input.is_action_just_released("jump") and velocity.y < 0.0
	var is_idle: bool = is_on_floor() and is_zero_approx(velocity.x) 
	var is_walking: bool = is_on_floor() and not is_zero_approx(velocity.x)

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

	# Adjust jump count and velocity
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


func face_movement_direction(horizontal_input: float) -> void:
	# Update player sprite flip
	if not is_zero_approx(horizontal_input):
		if horizontal_input < 0:
			player_sprite.scale = Vector2(-initial_sprite_scale.x, initial_sprite_scale.y)

		if horizontal_input > 0:
			player_sprite.scale = initial_sprite_scale


func _on_animated_sprite_2d_animation_finished() -> void:
	player_sprite.play("jump")
