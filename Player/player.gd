extends CharacterBody2D

@export var movement_speed: int = 300
@export var gravity: int = 30
@export var jump_strength: int = 600


func _physics_process(delta):
	var horizontal_input = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)

	velocity.x = horizontal_input * movement_speed
	velocity.y += gravity

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_strength

	move_and_slide()
