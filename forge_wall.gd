extends CharacterBody2D

@onready var player = get_node("/root/Main/Player")
@onready var healthbar = $HealthBar

var health := 100
var is_in_range : bool

var armor_rate := 22

# ROUND BASED HEALTH?


# Called when the node enters the scene tree for the first time.
func _ready():
	player.swing_sword.connect(_check_hit)
	healthbar.value = health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print("range: " + str(is_in_range))
	if health <= 0:
		pass
		#die()
			#removes collision
			#hides self
			#send signal to main


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
