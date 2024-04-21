class_name EnemyWanderState
extends State

@export var actor : Enemy
@export var animator : AnimatedSprite2D
@export var l_o_s : RayCast2D

signal found_target


func _ready():
	set_physics_process(false)


func _enter_state():
	set_physics_process(true)
	animator.play("IDLE")
	if actor.velocity == Vector2.ZERO:
		actor.velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * actor.max_speed


func _exit_state():
	set_physics_process(false)


func _physics_process(delta):
	animator.scale.x = sign(actor.velocity.x)
	if animator.scale.x == 0.0:
		animator.scale.x = 1.0
	
	actor.velocity = actor.velocity.move_toward(actor.velocity.normalized() * actor.max_speed, actor.acceleration * delta)
	var collision = actor.move_and_collide(actor.velocity * delta)
	if collision:
		var bounce_velocity = actor.velocity.bounce(collision.get_normal())
		actor.velocity = bounce_velocity
	
	if !l_o_s.is_colliding():
		found_target.emit()
