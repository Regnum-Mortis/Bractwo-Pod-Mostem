extends Node2D

@onready var player_hp = $PlayerHp
@onready var player_hunger = $PlayerHunger
@onready var enemy_hp = $EnemyHp

const PLAYER_DMG = 5
const PLAYER_RESISTANCE = 0.05 #in percents <0;1>
const ENEMY_DMG = 5
const ENEMY_RESISTANCE = 0.05 #in percents <0;1>

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_hp.value = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(player_hp.value <=0):
		print("Gracz nie żyje")
	if(enemy_hp.value <= 0):
		print("Przeciwnik nie żyje")

func player_attack()->void:
	enemy_hp.value-= PLAYER_DMG * (1-ENEMY_RESISTANCE)
	
func enemy_attack()->void:
	player_hp.value-= ENEMY_DMG * (1-PLAYER_RESISTANCE)


func _on_player_attack_btn_pressed() -> void:
	player_attack()
