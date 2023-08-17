extends Node
class_name Game

enum PlayerMode {
	DUCK,
	STATUE,
}

@onready var currency : int = 0 
@onready var mode : PlayerMode = PlayerMode.DUCK
@export var switchModeInterval : int = 35
var _intervalTimer : float = 0

@export var mob_spawn_multiplier : float = 20

@export var health_increase_multiplier: float = 20 #TODO
@export var damage_increase_multiplier : float = 10 #TODO

@export var mob_spawn_count : int = 5
@export var max_spawn_interval : float = 1.5
@export var countdown : int = 3
static var wave : int = 0 #current wave
@onready var current_mobs_left : int = 0
@onready var mobs_to_spawn : int = 0
var _ctd : int  = 0
@export var MobTypes = [] #different types of mobs

@export var GiantSpawnChance : int = 15
@export var HellHoundSpawnChance : int = 75
@export var HarpySpawnChance : int = 20

@onready var SpawnPoint : Node2D = %MobSpawnPoint
@onready var world : World = %World

@onready var _healthIncrease : float = 1

var tensArray = []


var PIERCABLE_SPEARS : bool = false



func _ready():
	wave = 0
	$GameHUD.updateWave(wave)
	var x = -1
	for i in range(1000):
		x += 1
		if x == 10:
			tensArray.append(i)
			x = 0
	
	_initGame()

func _initGame():
	world.getPlayer().showIndicator()
	%GameHUD/AnimationPlayer2.play("show_duck")
	currency = 0
	_intervalTimer = switchModeInterval	
	%GameHUD.get_node('ImperialGold/Label').text = str(currency)
	%GameHUD.get_node('SwitchTimerLabel').text = "%.1f" % _intervalTimer
	#count down to 3 and start the game
	#3 2 1 start!
	unPauseGame()
	_ctd = countdown
	$GameHUD.sendMessage("Wave Starting in " + str(_ctd))
	$CountdownTimer.start()
	
	# spawn inital wave and start the timer - every 30 seconds start the next wave
	pass

func _spawnMobs():
	mobs_to_spawn = mob_spawn_count
	%MobSpawnPoint/MobSpawnTimer.start(randf_range(0.8,max_spawn_interval))


func getWorld() -> World:
	return %World

func getGameHUD() -> CanvasLayer:
	return %GameHUD


func _on_mob_spawn_timer_timeout():
	var harpy = MobTypes[2]
	var giant = MobTypes[1]
	var hellhound = MobTypes[0]
	var mob = hellhound
	
	if randi_range(0,100) <= HellHoundSpawnChance:
		mob = hellhound
	if randi_range(0,100) <= GiantSpawnChance:
		mob = giant
	if randi_range(0,100) <= HarpySpawnChance:
		mob = harpy

	
	mob = mob.instantiate()
	%World/Entities.add_child(mob)
	mob.position = SpawnPoint.position
	var HC : HealthComponent = mob.get_node('HealthComponent')
	HC.MAX_HEALTH = ceili(float(HC.MAX_HEALTH) * (1 + _healthIncrease/100))
	HC.health = HC.MAX_HEALTH
	mobs_to_spawn -= 1
	if mobs_to_spawn == 0:
		%MobSpawnPoint/MobSpawnTimer.stop()
	else:
		%MobSpawnPoint/MobSpawnTimer.stop()
		%MobSpawnPoint/MobSpawnTimer.start(randf_range(0.8,max_spawn_interval))


func _on_countdown_timer_timeout():
	_ctd -= 1
	if _ctd == 0:
		wave += 1
		$GameHUD.updateWave(wave)
		SoundPlayer.playSound(SoundPlayer.SOUNDS.WAVE_START,1,1.5)
		_spawnMobs()
		$CountdownTimer.stop()
		$WaveTimer.start()
		mob_spawn_count = ceili(float(mob_spawn_count)*(1 + mob_spawn_multiplier/100))
		$SwitchTimer.start()
		$CurrencyTimer.start()
		$RegenerationTimer.start()
		return
	$GameHUD.sendMessage("Wave Starting in " + str(_ctd))
	

func _on_wave_timer_timeout():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.WAVE_START,1,1.5)
	wave += 1
	$GameHUD.updateWave(wave)
	$GameHUD.sendMessage("Wave " + str(wave))
	mobs_to_spawn = mob_spawn_count
	_spawnMobs()
	if tensArray.has(wave):
		mob_spawn_count = ceili(float(mob_spawn_count*(1 + mob_spawn_multiplier/100)))*2
		_healthIncrease += 15
	else:
		mob_spawn_count = ceili(float(mob_spawn_count*(1 + mob_spawn_multiplier/100)))
	pass # Replace with function body.
	
func _switchRole(): #roles are switched
	SoundPlayer.playSound(SoundPlayer.SOUNDS.SWAP_ROLE,1,1)
	
	if mode == PlayerMode.DUCK:
		mode = PlayerMode.STATUE
		world.getStatue().showIndicator()
		world.getPlayer().hideIndicator()
		world.getPlayer()._autopilot = true
		var cardManager : Cards = $GameHUD/Cards
		cardManager.setActive(true)
		%GameHUD/AnimationPlayer2.play_backwards("show_duck")
		await %GameHUD/AnimationPlayer2.animation_finished
		%GameHUD/AnimationPlayer2.play("show_statue")
		
	elif mode == PlayerMode.STATUE:
		mode = PlayerMode.DUCK
		world.getStatue().hideIndicator()
		world.getPlayer().showIndicator()
		world.getPlayer()._autopilot = false
		var cardManager : Cards = $GameHUD/Cards
		cardManager.setActive(false)
		cardManager.deleteCards()
		%GameHUD/AnimationPlayer2.play_backwards("show_statue")
		await %GameHUD/AnimationPlayer2.animation_finished
		%GameHUD/AnimationPlayer2.play("show_duck")

func game_over():
	#TODO
	pauseGame()
	await get_tree().create_timer(0.5).timeout
	var scene : PackedScene = Scenes.game_over_scene
	SceneTransition.changeScene(scene)
	

func pauseGame():
	get_tree().paused = true

func unPauseGame():
	get_tree().paused = false

func _on_player_player_death_event():
	game_over()

func _on_statue_statue_death_event():
	game_over()

func _on_switch_timer_timeout():
	_intervalTimer -= 0.1
	%GameHUD.get_node('SwitchTimerLabel').text = "%.1f" % _intervalTimer
	if _intervalTimer <= 0:
		_switchRole()
		_intervalTimer = switchModeInterval


func _on_currency_timer_timeout():
	currency += 1
	%GameHUD.get_node('ImperialGold/Label').text = str(currency)


func _on_regeneration_timer_timeout():
	getWorld().getPlayer().healPlayer(2)
	getWorld().getStatue().healStatue(2)

func _setRegenSpeed(val : float):
	$RegenerationTimer.wait_time = val
	
func _getRegenSpeed():
	return $RegenerationTimer.wait_time
	
func _setMoneyRate(val : float):
	$CurrencyTimer.wait_time = val

func _getMoneyRate():
	return $CurrencyTimer.wait_time
