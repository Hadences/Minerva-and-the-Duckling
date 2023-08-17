extends Control
class_name StatueHealth

func updateHealth(health : int):
	$TextureProgressBar.value = health

func updateMaxHealth(maxHealth : int):
	$TextureProgressBar.max_value = maxHealth
