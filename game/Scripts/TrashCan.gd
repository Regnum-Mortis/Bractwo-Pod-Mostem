extends Area2D

var rng = RandomNumberGenerator.new()
var trash_random = RandomNumberGenerator.new()
var player_in_range = false
@onready var search_ui = get_node("../UI_Player/SearchUI")
@onready var bar = search_ui.get_node("searchbar")
@onready var choice_ui = get_node("../UI_Player/ChoiceUI")

@export var district = "residential"

# Tylko pule łupu – dane itemów są teraz w .tres, nie w items.json
var loot_pools = {}

var wait_time = 12.0
var progress = 0.0
var search_locked = false


func _process(delta):
	if player_in_range:
		if not search_locked:
			if player_in_range == true && Input.is_action_pressed("interact"):
				search_ui.visible = true
				if OS.is_debug_build():
					progress += (100.0 / wait_time) * delta * 10
				else:
					progress += (100.0 / wait_time) * delta
				
				if progress > 100.0:
					progress = 100.0
					search_locked = true
					
					var roll = rng.randi_range(1, 10)
					if roll > 4:
						var pool = loot_pools.get(district, [])
						var options = pick_unique_weight(pool, 3)
						if choice_ui:
							# ChoiceUi sam ładuje .tres – nie potrzebujemy przekazywać items dict
							choice_ui.show_options(options)
						print("Propozycje z ", district, ":", options)
					else:
						print("Szukanie nie udało się!")
						var players: Array = get_tree().get_nodes_in_group("player")
						if players.size() == 0:
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
	else:
		progress = 0.0
		bar.value = 0.0


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		choice_ui.hide_options()
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


func _ready():
	rng.randomize()
	trash_random.randomize()

	# Tylko loot_pools.json – dane itemów są w .tres
	loot_pools = load_json("res://Data/loot_pools.json")

	if choice_ui and not choice_ui.is_connected("chosen", Callable(self, "_on_choice_chosen")):
		choice_ui.connect("chosen", Callable(self, "_on_choice_chosen"))

	print("loot_pools keys:", loot_pools.keys())


func pick_unique_weight(pool: Array, count: int) -> Array:
	var bag = []
	for e in pool:
		var id = String(e.get("id", ""))
		var w = int(e.get("weight", 1))
		if id == "" or w <= 0:
			continue
		# Pomiń itemy bez pliku .tres (np. knife jeśli brak)
		if not ResourceLoader.exists("res://inventory/items/%s.tres" % id):
			print("WARN: brak .tres dla id=", id, " – pomijam z puli")
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
	var res_path = "res://inventory/items/%s.tres" % id
	if not ResourceLoader.exists(res_path):
		print("Brak pliku: ", res_path)
		return

	var item_res: InventoryItem = ResourceLoader.load(res_path)
	print("Wybrałeś: ", item_res.name)

	var players: Array = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		print("Nie znaleziono gracza")
		return
	var player = players[0]

	var inv = player.get("inventory")
	if inv == null:
		print("Gracz nie ma ekwipunku")
		return

	var added = inv.insert(item_res)
	if added:
		print("Dodano ", item_res.name, " do ekwipunku")
	else:
		print("Brak miejsca w ekwipunku!")
