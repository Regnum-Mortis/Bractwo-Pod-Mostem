extends Control

var inventory: Inventory = null
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
var active_slot_with_drop = null

var is_open: bool = false

func _ready() -> void:
	close()


func update_slots():
	if inventory == null:
		return

	# Inventory keeps its items in `slots: Array[inventorySlot]`.
	var items_arr = inventory.get("slots")
	if items_arr == null:
		items_arr = inventory.get("items")
	if items_arr == null:
		return

	for i in range(min(items_arr.size(), slots.size())):
		slots[i].update(items_arr[i])
	
func _process(_delta) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if is_open:
			close()
		else:
			open()
	
func open() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var p = _get_player_node()
	if inventory == null:
		if p and p.get("inventory") != null:
			inventory = p.get("inventory")
	
	if inventory and inventory.has_signal("updated"):
		if not inventory.updated.is_connected(update_slots):
			inventory.updated.connect(update_slots)
	
	update_slots()
	
	is_open = true
	visible = true
	# notify player to block movement while inventory is open
	if p:
		if p.has_method("set_inventory_opened"):
			p.set_inventory_opened(true)
		elif p.has_method("set_can_move"):
			p.call("set_can_move", false)
		else:
			# fallback: try to set property if exists
			if p.has_method("set"):
				p.set("can_move", false)

	
	
func close() -> void:
	is_open = false
	visible = false
	# notify player to restore movement
	
	if active_slot_with_drop:
		active_slot_with_drop.hide_drop_button()
		active_slot_with_drop = null
	if inventory and inventory.updated.is_connected(update_slots):
		inventory.updated.disconnect(update_slots)
	
	var p = _get_player_node()
	if p:
		if p.has_method("set_inventory_opened"):
			p.set_inventory_opened(false)
		elif p.has_method("set_can_move"):
			p.call("set_can_move", true)
		else:
			if p.has_method("set"):
				p.set("can_move", true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _get_player_node() -> Node:
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func on_slot_clicked(clicked_slot):
	print("funkcja on_slot_clicked")
	if active_slot_with_drop!= null and active_slot_with_drop != clicked_slot:
		active_slot_with_drop.hide_drop_button()
		
	if clicked_slot.check_visibility():
		print("xd")
		clicked_slot.hide_drop_button()
		active_slot_with_drop = null
	else:
		print("wykonalo sie")
		clicked_slot.show_drop_button()
		active_slot_with_drop = clicked_slot
