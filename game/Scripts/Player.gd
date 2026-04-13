extends CharacterBody2D

@export var speed: int = 200
@export var sprint_speed: int = 300 
@export var health: int = 500
@export var hunger: int = 300
@export var can_move: bool = true
@onready var hunger_bar: Node = get_node("../UI_Player/HungerBar")
@onready var health_bar: Node = get_node("../UI_Player/HealthBar")

@onready var cam: Camera2D = $Camera2D

@export var zoom_normal := Vector2(1.85, 1.85)
@export var zoom_sprint := Vector2(1.75, 1.75)
@export var zoom_speed := 8.0

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
		if hunger > 0:
			sprinting = true
			current_speed = sprint_speed
		else:
			print("jestes na to zbyt glodny")
		
	velocity = input_direction * current_speed

func _physics_process(_delta):
	if can_move:
		get_handle_input()
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		
	var target_zoom = zoom_sprint if sprinting else zoom_normal
	cam.zoom = cam.zoom.lerp(target_zoom, zoom_speed * _delta)
	
func _process(_delta: float) -> void:
	pass


func _on_hunger_timer_timeout():
	if sprinting:
		if hunger > 0:
			hunger -= 10
	
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


# Zjada przedmiot – przywraca głód, usuwa z ekwipunku.
# Wywoływane przez inventory_ui_slot po kliknięciu USE.
func consume_item(item: InventoryItem) -> void:
	if item == null or not item.consumable:
		return

	var restore := int(item.hunger_restore)
	hunger = min(hunger + restore, 300)
	hunger_bar.value = hunger

	inventory.remove(item, 1)

	print("Zjadłeś: ", item.name, " | Głód +", restore, " → ", hunger)


func set_inventory_opened(opened: bool) -> void:
	can_move = not opened
