class_name EnemyChaseState
extends State

@export var actor : CharacterBody2D
@export var animator : AnimatedSprite2D
@export var l_o_s : RayCast2D

@onready var player = get_node("/root/Main/Player")

signal lost_target
signal target_in_range

func _ready():
	set_physics_process(false)


func _enter_state():
	set_physics_process(true)
	animator.play("IDLE")


func _exit_state():
	set_physics_process(false)


func _process(delta):
	#var direction = Vector2.ZERO.direction_to(actor.get_local_mouse_position())
	var direction = -1.0 * (actor.position - player.position)
	animator.scale.x = sign(actor.velocity.x)
	
	if animator.scale.x == 0.0:
		animator.scale.x = 1.0
	actor.velocity = actor.velocity.move_toward(direction * actor.max_speed, actor.acceleration * delta)
	actor.move_and_slide()
	
	if l_o_s.is_colliding():
		lost_target.emit()


func _on_melee_range_body_entered(body):
	target_in_range.emit()
