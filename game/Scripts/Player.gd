extends CharacterBody2D

@export var speed: int = 300
@export var health: int = 500
@export var hunger: int = 300
@export var can_move: bool = true
@onready var hunger_bar: Node = get_node("../UI_Player/HungerBar")
@onready var health_bar: Node = get_node("../UI_Player/HealthBar")


@export var inventory: Inventory

func get_handle_input():
	if not can_move:
		velocity = Vector2.ZERO
		return
		
	var input_direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	velocity = input_direction *speed
func _physics_process(_delta):
	if can_move:
		get_handle_input()
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	#z_index = int(global_position.y)

func _on_hunger_timer_timeout():
	if hunger >0:
		hunger -= 1
	else:
		if health > 0:
			health-=1
	print("Hunger:", hunger)
	print("Health:", health)
	
	hunger = max(hunger, 0)
	health = max(health, 0)
	
	hunger_bar.value = hunger
	health_bar.value = health

func _ready():
	print("Grupy gracza:", get_groups())


	
func collect(item):
		inventory.insert(item)
# Called by UI or other systems to indicate the inventory UI is open/closed.
# When inventory is open we prevent movement; when closed we restore movement.
func set_inventory_opened(opened: bool) -> void:
		can_move = not opened
