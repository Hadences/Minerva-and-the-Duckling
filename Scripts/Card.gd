extends TextureButton
class_name Card

signal cardPressed

enum CardType {
	ATTACK_SPEED,
	REGENERATION,
	THROW_SPEED,
	MONEY_RATE,
	PIERCABLE,
	TRIPLE_THROW,
	INCREASE_SPEAR_DAMAGE,
	INCREASE_THROWSPEAR_DAMAGE,
}

var cardTypes : Array[CardType] = [
	CardType.ATTACK_SPEED,
	CardType.REGENERATION,
	CardType.THROW_SPEED,
	CardType.MONEY_RATE
]

@export var piercable_card_chance : int = 5
@export var triple_throw_chance : int = 4
@export var increase_spear_damage_chance : int = 6
@export var increase_throw_spear_chance : int = 3


var prismatic_card = preload("res://Assets/prismatic_card.png")
var prismatic_card_hover = preload("res://Assets/prismatic_card_hover.png")

@onready var costLabel = $Cost/Label
@onready var description = $Description
@onready var game : Game = get_tree().root.get_node('Game')
var cost : int = 0
var _percentageIncrease : float = 0

var CardPowerUp : CardType = CardType.ATTACK_SPEED

func _ready():
	CardPowerUp = cardTypes[randi_range(0,cardTypes.size()-1)]
	
	if CardPowerUp == CardType.ATTACK_SPEED:
		var val = randi_range(5,20)
		cost = val
		costLabel.text = str(val)
		_percentageIncrease = val - 2
		description.text = "Increases attack speed by " + str(_percentageIncrease) + "%"
	if CardPowerUp == CardType.REGENERATION:
		var val = randi_range(5,10)
		cost = val
		costLabel.text = str(val)
		_percentageIncrease = val - 2
		description.text = "Increases regeneration speed by " + str(_percentageIncrease) + "%"
	if CardPowerUp == CardType.THROW_SPEED:
		var val = randi_range(8,25)
		cost = val
		costLabel.text = str(val)
		_percentageIncrease = val - 2
		description.text = "Increases throw speed by " + str(_percentageIncrease) + "%"
	if CardPowerUp == CardType.MONEY_RATE:
		var val = randi_range(3,10)
		cost = val
		costLabel.text = str(val)
		_percentageIncrease = val - 2
		description.text = "Increases money rate by " + str(_percentageIncrease) + "%"

	if randi_range(0,100) <= piercable_card_chance && !game.getWorld().getPlayer().PIERCEABLE && !cardShowing(CardType.PIERCABLE):
		CardPowerUp = CardType.PIERCABLE
		var val = 24
		cost = val
		costLabel.text = str(val)
		description.text = "Makes your throwing spears piercable!"
		texture_normal = prismatic_card
		texture_hover = prismatic_card_hover
		return
	elif randi_range(0,100) <= triple_throw_chance && !game.getWorld().getPlayer().TRIPLE_THROW && !cardShowing(CardType.TRIPLE_THROW):
		CardPowerUp = CardType.TRIPLE_THROW
		var val = 40
		cost = val
		costLabel.text = str(val)
		description.text = "Throws three spears at a time!"
		texture_normal = prismatic_card
		texture_hover = prismatic_card_hover 
		return
		
	if randi_range(0,100) <= increase_spear_damage_chance:
		CardPowerUp = CardType.INCREASE_SPEAR_DAMAGE
		var val = randi_range(15,30)
		cost = val
		costLabel.text = str(val)
		_percentageIncrease = ceili(float(val)/2)
		description.text = "Increases spear damage by " + str(_percentageIncrease) + "%"
		texture_normal = prismatic_card
		texture_hover = prismatic_card_hover
	elif randi_range(0,100) <= increase_throw_spear_chance:
		CardPowerUp = CardType.INCREASE_THROWSPEAR_DAMAGE
		var val = randi_range(20,40)
		cost = val
		costLabel.text = str(val)
		_percentageIncrease = ceili(float(val) / 3)
		description.text = "Increases throwing spear damage by " + str(_percentageIncrease) + "%"
		texture_normal = prismatic_card
		texture_hover = prismatic_card_hover

func cardShowing(type : CardType) -> bool:
	var cards : Cards = game.getGameHUD().get_node("Cards")
	if cards.currentCards != null:
		for i in range(cards.currentCards.size()):
			if cards.currentCards[i] != null:
				if cards.currentCards[i].CardPowerUp == type:
					return true
		return false
	return false

func _on_pressed():
	if game != null:
		if game.currency < cost:
			return
		else:
			SoundPlayer.playSound(SoundPlayer.SOUNDS.SELECT_CARD,0.5,1)
			game.currency -= cost
			if game.currency <= 0:
				game.currency = 0
			if CardPowerUp == CardType.ATTACK_SPEED:
				var player := game.getWorld().getPlayer()
				player.setAttackSpeedCD(player.getAttackSpeedTime() - (player.getAttackSpeedTime() * _percentageIncrease/100))
			elif CardPowerUp == CardType.THROW_SPEED:
				var player := game.getWorld().getPlayer()
				player.setThrowSpeedCD(player.getThrowSpeedTime() - (player.getThrowSpeedTime() * _percentageIncrease/100))
			elif CardPowerUp == CardType.REGENERATION:
				game._setRegenSpeed(game._getRegenSpeed() - (game._getRegenSpeed() * _percentageIncrease/100))
			elif CardPowerUp == CardType.MONEY_RATE:
				game._setMoneyRate(game._getMoneyRate() - (game._getMoneyRate() * _percentageIncrease/100))
			elif CardPowerUp == CardType.PIERCABLE:
				var player := game.getWorld().getPlayer()
				player.PIERCEABLE = true
			elif CardPowerUp == CardType.TRIPLE_THROW:
				var player := game.getWorld().getPlayer()
				player.TRIPLE_THROW = true
			elif CardPowerUp == CardType.INCREASE_SPEAR_DAMAGE:
				var player := game.getWorld().getPlayer()
				print(str(int(float(player.getSpearDamage()) * (1+_percentageIncrease/100))))
				player.setSpearDamage(int(ceilf(float(player.getSpearDamage()) * (1+_percentageIncrease/100))))
			elif CardPowerUp == CardType.INCREASE_THROWSPEAR_DAMAGE:
				var player := game.getWorld().getPlayer()
				player.setThrowingSpearDamage(int(ceilf(float(player.getThrowingSpearDamage()) * (1+_percentageIncrease/100))))
			
		cardPressed.emit()
		queue_free()

func _playAnim():
	$AnimationPlayer.play("spawn")
