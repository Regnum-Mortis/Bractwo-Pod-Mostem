extends CharacterBody2D

@export var speed = 300
@export var health = 500
@export var hunger = 100
@onready var hunger_bar = get_node("../UI_Player/HungerBar")
@onready var health_bar = get_node("../UI_Player/HealthBar")

func get_handle_input():
	var input_direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	velocity = input_direction *speed
func _physics_process(_delta):
	get_handle_input()
	move_and_slide()
	z_index = int(global_position.y)


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
