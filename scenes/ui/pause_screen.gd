extends CanvasLayer

var game_paused := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if Input.is_action_just_pressed("pause") && !game_paused:
		#game_paused = true
	#elif Input.is_action_just_pressed("pause") && game_paused:
		#game_paused = false
	#
	#match game_paused:
		#true:
			#get_tree().paused = true
			#show()
		#false:
			#hide()
			#get_tree().paused = false
		