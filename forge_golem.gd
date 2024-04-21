class_name Enemy
extends CharacterBody2D

@onready var FSM = $FiniteStateMachine
@onready var enemy_wander_state = $FiniteStateMachine/EnemyWanderState
@onready var enemy_chase_state = $FiniteStateMachine/EnemyChaseState
@onready var enemy_melee_state = $FiniteStateMachine/EnemyMeleeState
@onready var l_o_s = $RayCast2D

@onready var player = get_node("/root/Main/Player")

@export var max_speed := 40
@export var acceleration := 50
@export var health := 150.0
@export var dmg_rate := 25
@export var armor_rate := 24
@export var healthbar : TextureProgressBar

const BASE_HEALTH = 150.0
var player_in_range : bool
var can_be_hit := false

signal melee

func _ready():
	enemy_wander_state.found_target.connect(FSM.change_state.bind(enemy_chase_state))
	enemy_chase_state.lost_target.connect(FSM.change_state.bind(enemy_wander_state))
	enemy_chase_state.target_in_range.connect(FSM.change_state.bind(enemy_melee_state))
	enemy_melee_state.target_out_of_range.connect(FSM.change_state.bind(enemy_wander_state))
	enemy_melee_state.try_attack.connect(_check_in_range)
	player.swing_sword.connect(_check_is_hit)
	
	health = BASE_HEALTH
	
	healthbar.value = health
	healthbar.max_value = health


func _physics_process(delta):
	l_o_s.target_position = player.position - position


func _on_melee_range_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true


func _on_melee_range_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false


func _check_in_range():
	if player_in_range:
		melee_attack()


func _check_is_hit():
	if can_be_hit:
		take_damage(player.dmg_rate)
		print("PLAYER HIT BOSS")


func take_damage(dmg_amount):
	health -= (dmg_amount / armor_rate)
	healthbar.value = health
	if health <= 0:
		queue_free()


func melee_attack():
	$Timers/SwingTimer.start(.75)
	velocity = Vector2.ZERO



func _on_hurtbox_area_entered(area):
	# if sword is in hurtbox, self can take damage
	if area.is_in_group("melee"):
		can_be_hit = true
		print("PLAYER CAN HIT BOSS")


func _on_hurtbox_area_exited(area):
	if area.is_in_group("melee"):
		can_be_hit = false
		print("PLAYER CAN - NOT - HIT BOSS")


func _on_swing_timer_timeout():
	if player_in_range:
		player.health -= dmg_rate
		_check_in_range()
		print("BOSS HIT PLAYER")
	else:
		print("BOSS - MISSED - PLAYER")
