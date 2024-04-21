extends CharacterBody2D

@onready var player = get_node("/root/Main/Player")
@onready var main = get_node("/root/Main")
@onready var healthbar = $HealthBar

var health := 100
var is_in_range : bool
var armor_rate := 22

const BASE_HEALTH = 100.0

signal wall_destroyed


func _ready():
	player.swing_sword.connect(_check_hit)
	health = BASE_HEALTH
	healthbar.value = health
	#$CollisionShape2D2.set_deferred("disabled", false)
	#show()


func _process(_delta):
	#print("range: " + str(is_in_range))
	_update_healthbar()
	if health <= 0:
		wall_destroyed.emit()
		die()


func die():
	main.stop_waves()
	queue_free()
	#$CollisionShape2D2.set_deferred("disabled", true)
	#hide()

func _check_hit():
	if is_in_range:
		take_damage(player.dmg_rate / armor_rate)
		#print("wall health: " + str(health))


func take_damage(dmg_rate):
	health -= dmg_rate
	_update_healthbar()


func _update_healthbar():
	healthbar.value = health


func _on_hurtbox_area_entered(area):
	if area.is_in_group("melee"):
		is_in_range = true


func _on_hurtbox_area_exited(area):
	if area.is_in_group("melee"):
		is_in_range = false
