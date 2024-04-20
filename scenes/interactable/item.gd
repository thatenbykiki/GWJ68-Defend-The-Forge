extends CharacterBody2D

@onready var main = get_node("/root/Main")
@onready var player = get_node("/root/Main/Player")

@export var is_floating := true
@export var healing_amount : int

var item_type : int # 0: coin, 1: health

var coin_icon = preload("res://assets/icons/Honey_Fungus.png")
var health_icon = preload("res://assets/icons/health_icon.png")

var textures = [coin_icon, health_icon]

var tween
var spawn
var distance
var duration

func _ready():
	$Sprite2D.texture = textures[item_type]
	set_tween()


func _physics_process(delta):
	if !is_floating:
		update_tween()
		tween.stop()
		var dir = (player.position - position)
		var speed = 30
		dir = dir.normalized()
		velocity = dir * speed
		move_and_slide()
	if is_floating:
		update_tween()
		tween.play()
	


func update_tween():
	spawn = position
	distance = position + Vector2(0.0, 4.0)


func set_tween():
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	spawn = position
	distance = position + Vector2(0.0, 4.0)
	duration = 1.2
	tween.tween_property(self, "position", distance, duration)
	tween.tween_property(self, "position", spawn, duration)
	tween.set_loops()


func floating_animation():
	pass


func _on_pickup_area_entered(area):
	if item_type == 0:
		main.coins += 1
	elif item_type == 1:
		player.heal_item()
		$SFX_PickupHeart.play()
	queue_free()
