extends Node2D

@onready var player = get_node("/root/Main/Player")
@onready var playerHealthbar = get_node("/root/Main/Player/HealthBar")
@onready var playerAnimTimer = get_node("/root/Main/Player/Timers/AnimTimer")
@onready var mobMgr = get_node("/root/Main/MobSpawner")

@onready var atk_stat = get_node("/root/Main/HUD/Stats/Attack")
@onready var spd_stat = get_node("/root/Main/HUD/Stats/Speed")
@onready var coin_count = get_node("/root/Main/HUD/MushCoins/CoinCount")
@onready var wave_count = get_node("/root/Main/HUD/WaveCounter")
@onready var relic_sprite = get_node("/root/Main/HUD/RelicSprite")

@onready var heart3 = get_node("/root/Main/HUD/HeartContainer/Heart3")
@onready var heart2 = get_node("/root/Main/HUD/HeartContainer/Heart2")
@onready var heart1 = get_node("/root/Main/HUD/HeartContainer/Heart1")
@onready var heart0 = get_node("/root/Main/HUD/HeartContainer/Heart0")

@onready var playerHitSFX = get_node("/root/Main/Player/SFX/PlayerHit")
@onready var bgmToggle = get_node("/root/Main/PauseScreen/Panel/BGMToggle")

var sword_icon = preload("res://assets/icons/Sword_Icon.png")
var shield_icon = preload("res://assets/icons/Shield_Icon.png")
var boots_icon = preload("res://assets/icons/Boots_Icon.png")

var music_on : bool

var mob_dmg_rate := 20.0
var max_mobs : int
var mobs_killed := 0
var coins : int
var wave : int
var chosen_relic : int # 0: Obelisk, 1: Zweihander, 2: Lava Boots
var relic_selected := false
var chosen_upgrade : int # 0: Damage, 1: Speed, 3: INVALID

func _ready():
	$GameOver/Button.pressed.connect(new_game)
	$UpgradeOptions/Panel/DamageUp.pressed.connect(damage_upgrade)
	$UpgradeOptions/Panel/SpeedUp.pressed.connect(speed_upgrade)
	$UpgradeOptions/Panel/NextWave.pressed.connect(next_wave_start)
	$RelicSelect/Boots.pressed.connect(boots_relic)
	$RelicSelect/Zweihander.pressed.connect(sword_relic)
	$RelicSelect/Obelisk.pressed.connect(shield_relic)
	$PauseScreen/Panel/BGMToggle.toggled.connect(toggle_bgm)
	$PauseScreen/Panel/Resume.pressed.connect(resume_game)
	$Controls/Panel/Button.pressed.connect(game_start)
	
	$BGM.playing = true
	music_on = true
	player.reset()	
	show_start_menu()

func _process(_delta):
	update_ui()
	loop_bgm()
	if is_wave_completed():
		get_tree().paused = true
		wave += 1
		mobs_killed = 0
		max_mobs += 1
		mobMgr.mobs_spawned = 0
		$UpgradeOptions.show()
		$UpgradeOptions/Panel/DamageUp.grab_focus()
		
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		$PauseScreen.show()
		$PauseScreen/Panel/Resume.grab_focus()


func get_menus():
	pass


func show_start_menu():
	get_tree().paused = true
	$Controls.show()
	$Controls/Panel/Button.grab_focus()


func game_start():
	$Controls.hide()
	new_game()
	relic_select()


func toggle_bgm(toggled):
	if toggled:
		$BGM.playing = true
		music_on = true
	if !toggled:
		$BGM.playing = false
		music_on = false

func loop_bgm():
	if music_on && !$BGM.playing:
		$BGM.play()
	else:
		pass


func resume_game():
	$PauseScreen.hide()
	get_tree().paused = false


func new_game():
	get_tree().paused = false
	chosen_relic = 3
	relic_selected = false
	coins = 0
	wave = 1
	max_mobs = 3
	mobs_killed = 0
	player.reset()
	reset()


func reset():
	mobMgr.mobs_spawned = 0
	chosen_upgrade = 3
	$UpgradeOptions.hide()
	$GameOver.hide()
	get_tree().paused = false
	if !relic_selected:
		relic_select()


func next_wave_start():
	if chosen_upgrade == 3:
		$SFX_Denied.play()
	elif chosen_upgrade == 0:
		player.dmg_rate *= 1.15
		$UpgradeOptions.hide()
		$WaveOverTimer.start()
	else:
		player.speed *= 1.15
		$UpgradeOptions.hide()
		$WaveOverTimer.start()
	print("dmg: " + str(player.dmg_rate))
	print("spd: " + str(player.speed))



func relic_select():
	get_tree().paused = true
	$RelicSelect/Boots.grab_focus()
	$RelicSelect.show()


func boots_relic():
	$SFX_Confirm.play()
	relic_selected = true
	player.speed *= 1.5
	player.health = 75
	player.max_health = 100
	chosen_relic = 2
	relic_sprite.texture = boots_icon
	playerHealthbar.max_value = 100
	$RelicSelect.hide()
	get_tree().paused = false


func sword_relic():
	$SFX_Confirm.play()
	relic_selected = true
	player.dmg_rate *= 1.5
	player.speed /= 1.25
	player.max_health = 100
	chosen_relic = 1
	relic_sprite.texture = sword_icon
	playerHealthbar.max_value = 100
	$RelicSelect.hide()
	get_tree().paused = false


func shield_relic():
	$SFX_Confirm.play()
	relic_selected = true
	player.health = 200
	player.max_health = 200
	player.dmg_rate /= 1.25
	chosen_relic = 0
	relic_sprite.texture = shield_icon
	playerHealthbar.max_value = 200
	$RelicSelect.hide()
	get_tree().paused = false

func damage_upgrade():
	print("DAMAGE UPGRADE CHOSEN")
	chosen_upgrade = 0


func speed_upgrade():
	print("SPEED UPGRADE CHOSEN")
	chosen_upgrade = 1


func is_wave_completed():
	var all_killed = true
	if mobs_killed == max_mobs:
		return all_killed
	else:
		return false


func game_over():
	#SFX_GAMEOVER
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("items", "queue_free")
	$GameOver/WavesLabel.text = "WAVES SURVIVED: " + str(wave - 1)
	get_tree().paused = true
	$GameOver.show()
	$GameOver/Button.grab_focus()


func update_ui():
	var atkRounded = round(player.dmg_rate)
	var spdRounded = round(player.speed)
	coin_count.text = str(coins)
	wave_count.text = "WAVE " + str(wave)
	atk_stat.text = "ATTACK: " + str(atkRounded)
	spd_stat.text = " SPEED: " + str(spdRounded)
	update_health()


func _change_heart_frames():
	if player.max_health == 8:
		match player.health:
			8:
				heart3.frame = 0
				heart2.frame = 0
				heart1.frame = 0
				heart0.frame = 0
			7:
				heart3.frame = 1
				heart2.frame = 0
				heart1.frame = 0
				heart0.frame = 0
			6:
				heart3.frame = 2
				heart2.frame = 0
				heart1.frame = 0
				heart0.frame = 0
			5:
				heart3.frame = 2
				heart2.frame = 1
				heart1.frame = 0
				heart0.frame = 0
			4:
				heart3.frame = 2
				heart2.frame = 2
				heart1.frame = 0
				heart0.frame = 0
			3:
				heart3.frame = 2
				heart2.frame = 2
				heart1.frame = 1
				heart0.frame = 0
			2:
				heart3.frame = 2
				heart2.frame = 2
				heart1.frame = 2
				heart0.frame = 0
			1:
				heart3.frame = 2
				heart2.frame = 2
				heart1.frame = 2
				heart0.frame = 1
			0:
				heart3.frame = 2
				heart2.frame = 2
				heart1.frame = 2
				heart0.frame = 2
				game_over()
	else:
		match player.health:
			4:
				heart3.frame = 0
				heart2.frame = 0
				heart1.frame = 0
				heart0.frame = 0
			3:
				heart3.frame = 2
				heart2.frame = 0
				heart1.frame = 0
				heart0.frame = 0
			2:
				heart3.frame = 2
				heart2.frame = 2
				heart1.frame = 0
				heart0.frame = 0
			1:
				heart3.frame = 2
				heart2.frame = 2
				heart1.frame = 2
				heart0.frame = 0
			0:
				heart3.frame = 2
				heart2.frame = 2
				heart1.frame = 2
				heart0.frame = 2
				game_over()


func update_health():
	playerHealthbar.value = player.health
	if player.health <= 0:
		game_over()


func _on_mob_spawner_hit_p():
	var r = randi_range(0, 99)
	if r >= 50:
		player.health -= mob_dmg_rate
		playerHitSFX.play()
		player.anim_state = "hit"
		playerAnimTimer.start(.6)


func _on_wave_over_timer_timeout():
	reset()


func _on_game_reset_timer_timeout():
	new_game()
