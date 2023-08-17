extends CanvasLayer
class_name GameHUD

func sendMessage(str : String):
	$Message.text = str
	$AnimationPlayer.stop()
	$AnimationPlayer.play("text")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.stop()

func updateWave(val : int):
	$WaveText.text = "Wave " + str(val)
