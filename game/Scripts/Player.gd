extends CharacterBody2D

@export var speed: int = 300
@export var sprint_speed: int = 400
@export var health: int = 500
@export var hunger: int = 300
@export var can_move: bool = true
@onready var hunger_bar: Node = get_node("../UI_Player/HungerBar")
@onready var health_bar: Node = get_node("../UI_Player/HealthBar")

@onready var cam: Camera2D = $Camera2D

@export var zoom_normal := Vector2(1.85, 1.85)
@export var zoom_sprint := Vector2(1.75, 1.75)   # im mniejsze, tym bliżej
@export var zoom_speed := 8.0                    # szybkość 

var sprinting = false


@export var inventory: Inventory

func get_handle_input():
	if not can_move:
		velocity = Vector2.ZERO
		return
		
	var input_direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	
	var current_speed = speed
	
	sprinting = false
	
	if Input.is_action_pressed("shift_sprint"):
		if hunger >0:
			sprinting = true;
			current_speed = sprint_speed
		else:
			print("jestes na to zbyt glodny ")
		
	
	
	velocity = input_direction *current_speed
func _physics_process(_delta):
	if can_move:
		get_handle_input()
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	#z_index = int(global_position.y)
	
	var target_zoom = zoom_sprint if sprinting else zoom_normal
	cam.zoom = cam.zoom.lerp(target_zoom, zoom_speed * _delta)
	
func _process(_delta: float) -> void:
		pass
	

func _on_hunger_timer_timeout():
	if sprinting:
		if hunger >0: 
			hunger -= 10 
	
	print("Hunger:", hunger)
	print("Health:", health)
	
	hunger = max(hunger, 0)
	health = max(health, 0)
	
	hunger_bar.value = hunger
	health_bar.value = health

func _ready():
	print("Grupy gracza:", get_groups())
	
	
func collect(item):
	var cost = 50

	if hunger >= cost:
		hunger -= cost
	else:
		var missing = cost - hunger  
		hunger = 0
		health -= missing 
	
	inventory.insert(item)
# Called by UI or other systems to indicate the inventory UI is open/closed.
# When inventory is open we prevent movement; when closed we restore movement.
func set_inventory_opened(opened: bool) -> void:
		can_move = not opened
		
