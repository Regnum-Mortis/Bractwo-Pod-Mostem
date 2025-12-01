extends Area2D

var rng = RandomNumberGenerator.new()
var trash_random = RandomNumberGenerator.new()
var player_in_range = false
@onready var search_ui = get_node("../UI_Player/SearchUI")
@onready var bar = search_ui.get_node("searchbar")
@onready var choice_ui = get_node("../UI_Player/ChoiceUI")

@export var district = "residential"

var items = {}
var loot_pools = {}

var wait_time = 12.0
var progress = 0.0
var search_locked = false


func _process(delta):
	#z_index = int(global_position.y)
	if player_in_range:
		if not search_locked:
			if player_in_range == true && Input.is_action_pressed("interact"):
				search_ui.visible = true
				progress += (100.0 / wait_time) * delta
				
				if progress > 100.0:
					progress = 100.0
					search_locked = true
					
					var roll = rng.randi_range(1, 10)
					if roll > 4:
						var pool = loot_pools.get(district, [])
						var options = pick_unique_weight(pool, 3)
						if choice_ui:
							choice_ui.show_options(options, items)
						print("Propozycje z ", district, ":", options)
					else:
						print("Szukanie nie udane!")
						var players: Array = get_tree().get_nodes_in_group("player")
						if players.size() == 0:
							print("No player found to give item to")
							return
						var player = players[0]
						player.health -= 10

											
			else:
				if progress > 0.0:
					progress -= (100.0 / wait_time) * delta
					if progress < 0.0:
						progress = 0.0
		if bar:
			bar.value = progress
		if progress >= 100.0 and not search_locked:
			search_locked = true
			print("Skonczyles szukac")
			
	else:
		progress = 0.0
		bar.value = 0.0


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		search_locked = false
		if search_ui:
			search_ui.visible = false
			if bar:
				bar.value = 0
				
				
func _reset_search_ui():
	progress = 0.0
	if bar:
		bar.value = 0.0
	if search_ui:
		search_ui.visible = false
		
		
func load_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	return JSON.parse_string(file.get_as_text())
	
	
#o tym nie rozmawiamy ( ochujtuzapierdala )
func _ready():
	rng.randomize()
	trash_random.randomize()
	items = load_json("res://Data/items.json")
	loot_pools = load_json("res://Data/loot_pools.json")
	if typeof(items) == TYPE_ARRAY:
		var d = {}
		for e in items:
			if e.has("id"):
				d[e.id] = e
		items = d
		
	if choice_ui and not choice_ui.is_connected("chosen", Callable(self, "_on_choice_chosen")):
		choice_ui.connect("chosen", Callable(self, "_on_choice_chosen"))
	
	print("items typeof:", typeof(items), " size:", items.size())
	print("loot_pools typeof:", typeof(loot_pools), " keys:", loot_pools.keys())
	
	#funkcja losuje itemy z jsona i zwraca tablice.
func pick_unique_weight(pool: Array, count: int) -> Array:
	var bag = []
	for e in pool:
		#e - entry || w - weight
		var id = String(e.get("id", ""))
		var w = int(e.get("weight", 1))
		if id == "" or w <= 0:
			continue
		for i in range(w):
			bag.append(id)
	if bag.is_empty():
		return []
	bag.shuffle()
	
	var result = []
	var seen = {}
	for id in bag:
		if not seen.has(id):
			seen[id] = true
			result.append(id)
			if result.size() == count:
				break
				
	return result

func _on_choice_chosen(id: String):
	var def = items.get(id, {})
	print("Wybrałeś:", def.get("name", id))

	# Attempt to load the InventoryItem resource for the chosen id.
	var res_path = "res://inventory/items/%s.tres" % id
	var item_res: Resource = null
	if ResourceLoader.exists(res_path):
		item_res = ResourceLoader.load(res_path)
	else:
		print("Item resource not found at", res_path)
		return

	# Find the player node (assumes player is in group "player").
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		print("No player found to give item to")
		return
	var player = players[0]

	# Ensure player has an inventory resource (safe access)
	var inv = null
	# Use `get` to safely read the property if available on the object
	if player:
		inv = player.get("inventory")
	if inv == null:
		print("Player inventory is null or missing")
		return

	# Place the item into the first empty slot, otherwise append.
	# Use Inventory methods to add the item (handles slots/amounts internally)
	var added = false
	if inv.has_method("add_item_resource"):
		added = inv.add_item_resource(res_path)
	elif inv.has_method("insert"):
		added = inv.insert(item_res)
	else:
		print("Inventory resource has no insert/add method")
		added = false
	if added:
		print("Added", id, "to player inventory")
	else:
		print("Failed to add", id, "to player inventory")

	# Try to update player's inventory UI if it exists as a child named "Inventory_UI".
	if player.has_node("Inventory_UI"):
		var ui = player.get_node("Inventory_UI")
		if ui and ui.has_method("update_slots"):
			ui.update_slots()
