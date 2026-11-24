
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

const TURN_DELAY = 2.0 / 60.0
const IMPACT_DURATION = 5.0 / 60.0
const MIN_AIRTIME = 15.0 / 60.0

var turn_timer := 0.0
var impact_timer := 0.0
var airtime := 0.0


func play_animation(animation_name: StringName) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)


func _physics_process(delta: float) -> void:

	var was_on_floor := is_on_floor()

	# Gravity
	if not was_on_floor:
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and was_on_floor:
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		var new_direction: float = signf(direction)

		if sprite.scale.x != new_direction:
			sprite.scale.x = new_direction
			turn_timer = TURN_DELAY
			play_animation("turn")

		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			SPEED * 10.0 * delta
		)

	# Physics
	move_and_slide()

	var on_floor_now := is_on_floor()

	# Airborne
	if not on_floor_now:
		airtime += delta
		play_animation("jump")

	# Landing detection
	elif not was_on_floor:
		if airtime > MIN_AIRTIME:
			impact_timer = IMPACT_DURATION

		airtime = 0.0

	# Impact animation
	if impact_timer > 0.0:
		play_animation("impact")
		impact_timer = maxf(impact_timer - delta, 0.0)

	# Ground animations
	elif on_floor_now:
		if direction == 0:
			play_animation("_idle")
		elif turn_timer > 0.0:
			play_animation("turn")
			turn_timer = maxf(turn_timer - delta, 0.0)
		else:
			play_animation("walk")
