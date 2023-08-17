extends Node
class_name SoundManager

# Created by Sunpk, https://github.com/Hadences
#
# Because Godot currently has a bug where you cannot assign your objects in the inspector, you'll have to
# assign it through code.
#
# The process is very simple
# 1. add the sound name in the enum (what it would be identified as when you want to get that specific sound)
# 2. assign that sound name enum to the dictionary where the key is enum and the value is the AudioPlayer Node that
# 	 contains that sound - The AudioPlayer Node will be a child of the SoundManager Node
# 3. play the sound using the play sound method
# 4. to use it anywhere, add it to the autoload!
#
# See below for an example for Cannon Shoot Sound effect!
#
#
enum SOUNDS{
	#CANNON_SHOOT,
	CARD_SLIDE,
	ENEMY_DEATH,
	JUMP,
	SELECT_CARD,
	SPEAR_SWING,
	STATUE_BREAK,
	SWAP_ROLE,
	THROW_SPEAR,
	UI_CLICK,
	WAVE_START,
	HIT
}

@onready var soundEffects = {
	#SOUNDS.CANNON_SHOOT: $CANNON_SHOOT,
	SOUNDS.CARD_SLIDE: $CARD_SLIDE,
	SOUNDS.ENEMY_DEATH: $ENEMY_DEATH,
	SOUNDS.JUMP: $JUMP,
	SOUNDS.SELECT_CARD: $SELECT_CARD,
	SOUNDS.SPEAR_SWING: $SPEAR_SWING,
	SOUNDS.STATUE_BREAK: $STATUE_BREAK,
	SOUNDS.SWAP_ROLE: $SWAP_ROLE,
	SOUNDS.THROW_SPEAR: $THROW_SPEAR,
	SOUNDS.UI_CLICK: $UI_CLICK,
	SOUNDS.WAVE_START: $WAVE_START,
	SOUNDS.HIT : $HIT
}

func playSound(sound : SOUNDS, volume : float = 1, pitch : float = 1):
	if soundEffects.has(sound):
		var s : AudioStreamPlayer = soundEffects[sound]
		s.volume_db = volume
		s.pitch_scale = pitch
		s.play()
		


