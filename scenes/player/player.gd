extends CharacterBody2D

signal swing_sword

@export var is_controller : bool

@onready var main = get_node("/root/Main")
#@onready var ability = get_node("/root/Main/HUD/Ability")
@onready var boss = get_node("/root/Main/ForgeGolem")

@onready var sprite = $AnimatedSprite2D
@onready var weapPivot = $WeaponPivot
@onready var weapPos = $WeaponPivot/AttackArea/WeapPosition
@onready var atkArea = $WeaponPivot/AttackArea
@onready var swordSprite = $WeaponPivot/SwordSprite
@onready var atkTimer = $Timers/AttackTimer
@onready var abilityTimer = $Timers/AbilityTimer
@onready var cdTimer = $Timers/CooldownTimer

var speed := 50.0
var dmg_rate := 35.0
var health := 100.0

const BASE_HEALTH := 100.0
const BASE_SPEED := 50.0
const BASE_DAMAGE := 35.0
var max_health = BASE_HEALTH

var anim_state : String

var can_relic : bool
var relic_on_cd : bool

var is_attacking : bool
var can_attack := true
var spawn_point : Vector2
var angle

var cur_atk : float
var cur_speed : float
var cur_health : int


func _ready():
	#boss.melee.connect(on_boss_melee)
	#spawn_point = Vector2(480, -90) #Playground spawnpoint
	spawn_point = Vector2(480, 270)
	reset()
	$Ability.show()

func on_boss_melee():
	print("HIT BY BOSS")

func _physics_process(_delta):
	get_input()
	sprite.play()
	update_anims()
	move_and_slide()
	#position = position.clamp(Vector2.ZERO, get_viewport_rect().size)


func reset():
	dmg_rate = BASE_DAMAGE
	speed = BASE_SPEED
	health = BASE_HEALTH
	relic_on_cd = false
	can_relic = true
	cdTimer.stop()
	abilityTimer.stop()
	$Ability.text = "RELIC CHARGED!"
	position = spawn_point
	sprite.play("idle1")

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		is_controller = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		is_controller = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func get_input():
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var aim_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	var mouse_pos = get_local_mouse_position()
	var sword_pos = weapPivot.rotation
	
	if !is_controller:
		angle = snappedf(mouse_pos.angle(), PI / 2) / (PI / 2)
		angle = wrapi(int(angle), 0, 4)
	else: 
		angle = snappedf(sword_pos, PI / 2) / (PI / 2)
		angle = wrapi(int(angle), 0, 4)
		
	if aim_dir != Vector2.ZERO:
		weapPivot.rotation = lerp_angle(rotation, aim_dir.angle(), 1)
	elif is_controller == false:
		weapPivot.rotation = lerpf(rotation, mouse_pos.angle(), 1)
	velocity = move_dir.clamp(Vector2(-1, -1), Vector2(1, 1)).normalized() * speed
	
	if Input.is_action_pressed("attack"):
		if can_attack:
			swing_sword.emit()
			attack()
	
	if Input.is_action_just_pressed("heal"):
		if main.coins > 0 && health != max_health:
			main.coins -= 1
			heal_item()
		if main.coins <= 0:
			pass
			# denied sfx
	
	if Input.is_action_just_pressed("use_relic"):
		if !relic_on_cd && can_relic:
			print("USED RELIC")
			relic_ability(main.chosen_relic)
			can_relic = false


func relic_ability(relic):
	match relic:
		0:
			$Ability.text = "INVULNERABLE!"
			health = 1000
		1:
			$Ability.text = "TRIPLE DAMAGE!"
			cur_atk = dmg_rate
			dmg_rate *= 3.0
		2:
			$Ability.text = "FAST AS F*!"
			cur_speed = speed
			speed *= 2
	$Ability.show()
	$HaloAnim.show()
	$HaloAnim.play()
	abilityTimer.start(5)


func speed_upgrade():
	speed *= 1.15
	print(speed)


func damage_upgrade():
	dmg_rate *= 1.15
	print(dmg_rate)


func heal_item():
	$SFX/HealItem.play()
	print("before heal: " + str(health))
	health += (max_health * 0.20)
	if health > max_health:
		health = max_health
	print("after heal: " + str(health))

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


func update_anims():
	if velocity.length() != 0 && anim_state != "hit":
		anim_state = "walk"
	elif velocity.length() == 0:
		anim_state = "idle"
	
	sprite.animation = anim_state + str(angle)


func _on_atktimer_timeout():
	is_attacking = false
	can_attack = true
	swordSprite.play("idle")


func _on_mob_spawner_hit_p():
	pass


func _on_anim_timer_timeout():
	anim_state = "run"


func _on_ability_timer_timeout():
	match main.chosen_relic:
		0:
			health = max_health
		1:
			dmg_rate = cur_atk
		2:
			speed = cur_speed
	$Ability.hide()
	$HaloAnim.hide()
	$HaloAnim.stop()
	relic_on_cd = true
	cdTimer.start(8)


func _on_cooldown_timer_timeout():
	relic_on_cd = false
	can_relic = true
	$SFX/RelicReady.play()
	$Ability.text = "RELIC CHARGED!"
	$Ability.show()
