extends CharacterBody2D

class_name Enemy

enum EnemyType {AGGRESSIVE, NEUTRAL}
enum State {IDLE, CHASE, COMBAT, HIT, DEAD}


@export var enemy_type: EnemyType = EnemyType.AGGRESSIVE
@export var enemy_name: String = "Chuligán"
@export var move_speed: float = 200.0
@export var detection_range: float = 150.0  # zasięg widzenia
@export var attack_range: float = 30.0 
@export var health: float = 100.0
@export var weapon: String = ''

var state: State = State.IDLE
var target: Node2D = null # gracz potem

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var player_detection: Area2D = $PlayerDetection

func _ready() -> void:
	
	
	if enemy_type == EnemyType.NEUTRAL:
		state = State.IDLE


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			
			idle()
		State.CHASE:
			
			chase()
		State.COMBAT:
			pass  # walką zarządza FightingScene
		State.DEAD:
			pass


func idle() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	
	
func chase() -> void:
	if target == null:
		state = State.IDLE
		return
	var dist = global_position.distance_to(target.global_position)
	
	if dist <= attack_range:
		start_combat()
		return
	
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()


func take_damage(amount: float) -> void:
	state = State.HIT
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	state = State.DEAD
	queue_free()
	
# ========== WYKRYCIE GRACZA ==========
func _on_player_detection_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	target = body

	if enemy_type == EnemyType.AGGRESSIVE:
		state = State.CHASE


func _on_player_detection_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	#if state == State.CHASE:
		#state = State.IDLE
	#target = null

func start_combat():
	if state == State.COMBAT:
		return
	state = State.COMBAT
	target.can_move = false
	TransitionToCombat.start_combat(self, target)
