extends CharacterBody2D

@onready var main = get_node("/root/Main")
@onready var player = get_node("/root/Main/Player")
@onready var sprite = $AnimatedSprite2D
@onready var loot_spawn = $LootPivot/LootSpawn

var item_scene = preload("res://scenes/interactable/item.tscn")

signal hit_player
signal got_hit
signal died

const BASE_SPEED = 20

var is_in_range : bool
var player_in_range : bool
var entered : bool
var alive : bool
var speed := 40
var dir : Vector2

var health := 100

func _ready():
	player.swing_sword.connect(_check_hit)
	alive = true
	sprite.play("run")
	
	#var screen_rect = get_viewport_rect()
	#entered = false
	#
	#var dist = screen_rect.get_center() - position
	#
	#if abs(dist.x) > abs(dist.y):
		#dir.x = dist.x
		#dir.y = 0
	#else:
		#dir.x = 0
		#dir.y = dist.y

func _debug():
	print("IN RANGE ? " + str(is_in_range))

func _physics_process(delta):
	#if entered:
		#dir = (player.position - position)
	dir = (player.position - position)
	dir = dir.normalized()
	velocity = dir * speed
	move_and_slide()
	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0


func _check_hit():
	if is_in_range:
		take_damage(player.dmg_rate)
		play_hit_animation()
		print("HIT!")


func get_stunned():
	pass


func take_damage(dmg_amount):
	if health <= 0:
		die()
	else:
		$LootPivot.rotation_degrees = randf_range(-180.0, 180.0)
		loot_spawn.rotation_degrees = $LootPivot.rotation
		health -= dmg_amount


func play_hit_animation():
	$SFX/Hit.play()
	sprite.play("hit")
	speed = 0
	$HitTimer.start(.5)


func die():
	main.mobs_killed += 1
	# TODO: death_anim()
	var i = randi_range(0, 99)
	if i >= 14:
		spawn_loot()
	queue_free()


func spawn_loot():
	var loot = item_scene.instantiate()
	loot.item_type = 0
	loot.position = position
	#loot.scale = Vector2(2, 2)
	loot.add_to_group("items")
	main.add_child(loot)
	print("DROPPED LOOT")


func _on_enter_timer_timeout():
	entered = true


func _on_hurtbox_area_entered(area):
	if area.is_in_group("melee"):
		is_in_range = true
	if area.is_in_group("player"):
		player_in_range = true
		hit_player.emit()
		print("PLAYER IN RANGE")


func _on_hurtbox_area_exited(area):
	if area.is_in_group("melee"):
		is_in_range = false


func _on_hit_timer_timeout():
	speed = BASE_SPEED
	sprite.play("run")
