class_name EnemyMeleeState
extends State

@export var actor : CharacterBody2D
@export var animator : AnimatedSprite2D
@export var l_o_s : RayCast2D
@export var range : Area2D

#var target_in_range : bool

signal target_out_of_range
signal try_attack

func _ready():
	set_physics_process(false)


func _enter_state():
	set_physics_process(true)
	animator.play("MELEE")
	actor.velocity = Vector2.ZERO


func _exit_state():
	set_physics_process(false)


func _process(delta):

	pass


# If target is in melee range, attempt to attack
func _on_melee_range_body_entered(body):
	if body.is_in_group("player"):
		#target_in_range = true
		animator.play("MELEE")
		print("PLAYER IS IN RANGE")
		try_attack.emit()


func _on_melee_range_body_exited(body):
	if body.is_in_group("player"):
		#target_in_range = false
		target_out_of_range.emit()
