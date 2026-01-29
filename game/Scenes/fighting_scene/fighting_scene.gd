extends Node2D

@onready var player_hp: ProgressBar = $PlayerHp
@onready var player_hunger: ProgressBar = $PlayerHunger
@onready var enemy_hp: ProgressBar = $EnemyHp
@onready var qte_label: Label = $QteLabel
@onready var combo_label: Label = $ComboLabel

const PLAYER_DMG = 5
const PLAYER_RESISTANCE = 0.05
const ENEMY_DMG = 5
const ENEMY_RESISTANCE = 0.05

# ========== QTE SYSTEM ==========
var qte_active: bool = false
var qte_timer: float = 0.0
var next_qte_cooldown: float = 0.0
var qte_cooldown: float = 0.0  # NOWE! blokuje spam

var qte_attack_keys: Dictionary = {
	"A": "qte_a", "S": "qte_s", "D": "qte_d", "W": "qte_w",
	"↑": "qte_up", "↓": "qte_down", "←": "qte_left", "→": "qte_right"
}

var qte_target_key_internal: String = ""
var qte_target_key_display: String = ""

var combo_multiplier: float = 1.0
var enemy_stun: float = 0.0

func _ready():
	player_hp.value = 100
	player_hunger.value = 100
	enemy_hp.value = 100
	update_ui()

func _process(delta):
	if enemy_stun > 0:
		enemy_stun -= delta
		combo_label.text = "STUN: %.1fs" % enemy_stun
		return
	
	next_qte_cooldown -= delta
	qte_cooldown -= delta
	
	if not qte_active and randf() < delta * 0.3 and qte_cooldown <= 0:
		start_player_attack_qte()
	
	if qte_active:
		qte_timer -= delta
		qte_label.text = qte_target_key_display + "\n%.1fs ⏳" % qte_timer
		
		if qte_timer <= 0:
			qte_miss()
	
	update_ui()
	
	# Koniec gry
	if player_hp.value <= 0: print("💀 GRACZ PRZEGRANY")
	if enemy_hp.value <= 0: print("✅ WRÓG POKONANY")

func _input(event):
	if not qte_active: return
	
	if event.is_action_pressed(qte_target_key_internal):
		if qte_target_key_internal == "ui_accept":
			qte_perfect_break_defense()
		else:
			qte_perfect_attack()

# ========== QTE ATAK ==========
func start_player_attack_qte():
	qte_active = true
	qte_timer = randf_range(0.6, 1.1)
	
	var keys = qte_attack_keys.keys()
	var random_key = keys[randi() % keys.size()]
	
	qte_target_key_display = random_key
	qte_target_key_internal = qte_attack_keys[random_key]
	
	print("⚔️ ATAK: ", qte_target_key_display)

# ========== QTE PRZEŁAM OBRONY ==========
func start_enemy_defense_qte():
	qte_active = true
	qte_timer = 0.8
	qte_target_key_display = "SPACJA"
	qte_target_key_internal = "ui_accept"
	print("🛡️ PRZEŁAM: SPACJA!")

# ========== PERFECT ATAK ==========
func qte_perfect_attack():
	qte_active = false
	combo_multiplier += 0.1
	
	var damage = PLAYER_DMG * combo_multiplier * (1 - ENEMY_RESISTANCE)
	enemy_hp.value -= damage
	enemy_stun = 1.0
	
	qte_cooldown = 1.5  # 
	print("🎯 PERFECT ATAK! ", damage, "dmg (x%.1f)" % combo_multiplier)
	
	start_enemy_defense_qte()

# ========== PRZEŁAM OBRONY ==========
func qte_perfect_break_defense():
	qte_active = false
	var bonus_damage = PLAYER_DMG * 0.5
	enemy_hp.value -= bonus_damage
	qte_cooldown = 2.0 
	print("🔥 PRZEŁAM OBRONY! +%.1f dmg" % bonus_damage)

# ========== MISS ==========
func qte_miss():
	qte_active = false
	combo_multiplier = 1.0
	next_qte_cooldown = 2.0
	
	# WRÓG KONTRA!
	if randf() < 0.4:
		var enemy_dmg = ENEMY_DMG * (1 - PLAYER_RESISTANCE)
		player_hp.value -= enemy_dmg
		print("⚔️ WRÓG KONTRA! %.1f dmg" % enemy_dmg)
	
	print("❌ MISS! +2s kara")

# ========== UI ==========
func update_ui():
	combo_label.text = "Combo: x%.1f" % combo_multiplier
	player_hp.value = clamp(player_hp.value, 0, 100)
	enemy_hp.value = clamp(enemy_hp.value, 0, 100)
