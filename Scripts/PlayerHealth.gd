extends Control

class_name PlayerHealth

func updateHealth(health : int):
	$TextureProgressBar.value = health
	$Label.text = str(health) + "/" + str($TextureProgressBar.max_value)

func updateMaxHealth(maxHealth : int):
	$TextureProgressBar.max_value = maxHealth
