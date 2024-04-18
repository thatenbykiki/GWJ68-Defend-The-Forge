extends CharacterBody2D

signal swing_sword

@export var is_controller : bool

@onready var main = get_node("/root/Main")

@onready var sprite = $AnimatedSprite2D
@onready var weapPivot = $WeaponPivot
@onready var weapPos = $WeaponPivot/AttackArea/WeapPosition
@onready var atkArea = $WeaponPivot/AttackArea
@onready var swordSprite = $WeaponPivot/SwordSprite
@onready var atkTimer = $Timers/AttackTimer
@onready var dmgUpTimer = $Timers/DamageBuffTimer
@onready var spdUpTimer = $Timers/SpeedBoostTimer

var speed := 150.0
var dmg_rate := 20.0
var health := 4

const BASE_HEALTH = 4
const BASE_SPEED = 150
const BASE_DAMAGE = 25
var max_health = BASE_HEALTH

var is_attacking : bool
var can_attack := true
var spawn_point : Vector2
var angle

func _ready():
	spawn_point = get_viewport_rect().size / 2
	reset()


func _physics_process(_delta):
	get_input()
	sprite.play()
	move_and_slide()
	
	position = position.clamp(Vector2.ZERO, get_viewport_rect().size)


func reset():
	dmg_rate = BASE_DAMAGE
	speed = BASE_SPEED
	health = BASE_HEALTH
	position = spawn_point
	sprite.play("idle1")


func get_input():
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var aim_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	var mouse_pos = get_local_mouse_position()
	var sword_pos = weapPos.position
	angle = snappedf(mouse_pos.angle(), PI / 2) / (PI / 2)
	
	if !is_controller:
		angle = wrapi(int(angle), 0, 4)
	else: 
		angle = snappedf(sword_pos.angle(), PI / 2) / (PI / 2)
		angle = wrapi(int(angle), 0, 4)
		
	if aim_dir != Vector2.ZERO:
		weapPivot.rotation = lerp_angle(rotation, aim_dir.angle(), 1)
	elif main.is_controller == false:
		weapPivot.rotation = lerpf(rotation, mouse_pos.angle(), 1)
	velocity = move_dir.clamp(Vector2(-1, -1), Vector2(1, 1)).normalized() * speed
	
	if velocity.length() != 0:
		sprite.animation = "walk" + str(angle)
	else:
		sprite.animation = "idle" + str(angle)
	
	if Input.is_action_just_pressed("attack"):
		if can_attack:
			swing_sword.emit()
			attack()


func speed_upgrade():
	speed *= 1.15
	print(speed)


func damage_upgrade():
	dmg_rate *= 1.15
	print(dmg_rate)


func heal_item():
	health += 1


func attack():
	is_attacking = true
	can_attack = false
	atkTimer.start(.5)
	slash_sfx()
	swordSprite.play("swing")


func slash_sfx():
	var i = randi_range(0, 2)
	match i:
		0:
			$SFX/Slash.play()
		1:
			$SFX/Slash2.play()
		2:
			$SFX/Slash3.play()


func _on_atktimer_timeout():
	is_attacking = false
	can_attack = true
	swordSprite.play("idle")


func _on_mob_spawner_hit_p():
	sprite.animation = "hit" + str(angle)