extends Node2D

@onready var main = get_node("/root/Main")
@export var mob_scale = Vector2(3.0, 3.0)

var mob_scene := preload("res://scenes/interactable/knight.tscn")
var spawn_points := []
var mobs_spawned : int

signal hit_p

func _ready():
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)

func _on_timer_timeout():
	if main.mobs_killed <= main.max_mobs - 1 && mobs_spawned != main.max_mobs:
		var spawn = spawn_points[randi() % spawn_points.size()]
		var mob = mob_scene.instantiate()
		mob.scale = mob_scale
		mob.position = spawn.position
		mob.hit_player.connect(hit)
		main.add_child(mob)
		mob.add_to_group("mobs")
		mobs_spawned += 1
	else:
		pass
	
	#var enemies = get_tree().get_nodes_in_group("mobs")
	#if enemies.size() < get_parent().max_mobs:
		#var spawn = spawn_points[randi() % spawn_points.size()]
		#var mob = mob_scene.instantiate()
		#mob.scale = mob_scale
		#mob.position = spawn.position
		#mob.hit_player.connect(hit)
		#main.add_child(mob)
		#mob.add_to_group("mobs")


func hit():
	hit_p.emit()
