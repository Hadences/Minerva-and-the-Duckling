extends Control
class_name Cards
const CARD = preload("res://Scenes/Card.tscn")

var totalCards : int = 3
var currentCards : Array[Card] = [null, null, null]
@export var cardPos : Array[Control] = []

var ACTIVE : bool = false

func _process(delta):
	if ACTIVE:
		updateCards()

func updateCards():
	for i in range(totalCards):
		if currentCards[i] == null:
			SoundPlayer.playSound(SoundPlayer.SOUNDS.CARD_SLIDE,1,2)
			var cardSpawn : Card = CARD.instantiate()
			cardPos[i].add_child(cardSpawn)
			currentCards[i] = cardSpawn
			cardSpawn.global_position = cardPos[i].global_position
			cardSpawn._playAnim()
			pass
			#spawn logoc

func deleteCards():
	for i in range(totalCards):
		if currentCards[i] != null:
			currentCards[i].queue_free()
			currentCards[i] = null


func setActive(val : bool):
	ACTIVE = val
