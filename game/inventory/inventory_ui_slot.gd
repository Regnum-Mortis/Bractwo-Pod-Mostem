extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_label: Label = $CenterContainer/Panel/Label
@onready var action_popup: Control = $przycisk
@onready var DropButton: Button = $przycisk/dropButton/DropButton
@onready var UseButton: Button = $przycisk/useButton/UseButton
@onready var UseLabel: Label = $przycisk/useButton/UseLabel
@onready var ItemButton: Button = $CenterContainer/Panel/ItemButton

var current_slot_data: inventorySlot
var Index: int = -1


func update(slot: inventorySlot):
	current_slot_data = slot

	if slot == null or slot.item == null:
		item_visual.visible = false
		amount_label.visible = false
		ItemButton.disabled = true
		tooltip_text = ""
	else:
		ItemButton.disabled = false
		item_visual.visible = true
		amount_label.visible = true
		item_visual.texture = slot.item.texture
		amount_label.text = str(slot.amount)
		tooltip_text = _build_tooltip(slot.item)


func _build_tooltip(item: InventoryItem) -> String:
	var lines: Array[String] = [item.name]

	match item.item_type:
		"food":    lines.append("Typ: jedzenie")
		"tool":    lines.append("Typ: narzędzie")
		"junk":    lines.append("Typ: złom")

	if item.hunger_restore > 0:
		lines.append("Głód: +" + str(int(item.hunger_restore)))
	if item.durability > 0:
		lines.append("Stan: " + str(int(item.durability)))
	if item.price > 0:
		lines.append("Cena: " + str(int(item.price)) + " zł")

	return "\n".join(lines)


func _on_item_button_pressed() -> void:
	if current_slot_data == null or current_slot_data.item == null:
		return

	var ui_parent = _find_inventory_ui()
	if ui_parent == null:
		return

	var inventory = ui_parent.inventory
	Index = inventory.slots.find(current_slot_data)

	# Pokaż przycisk USE tylko dla konsumabli
	$przycisk/useButton.visible = current_slot_data.item.consumable
	

	ui_parent.on_slot_clicked(self)


func _on_use_button_pressed() -> void:
	if current_slot_data == null or current_slot_data.item == null:
		return

	var players: Array = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	var player = players[0]
	if player.has_method("consume_item"):
		player.consume_item(current_slot_data.item)

	hide_drop_button()

	var inv_ui = _find_inventory_ui()
	if inv_ui:
		inv_ui.update_slots()


func _on_drop_button_pressed() -> void:
	if current_slot_data == null or current_slot_data.item == null:
		return

	var inv_ui = _find_inventory_ui()
	if inv_ui == null or inv_ui.inventory == null:
		return

	# Używamy inventory.remove() żeby poprawnie wyemitować sygnał updated
	inv_ui.inventory.remove(current_slot_data.item, current_slot_data.amount)

	hide_drop_button()
	inv_ui.update_slots()


func hide_drop_button():
	action_popup.visible = false


func show_drop_button():
	action_popup.visible = true


func check_visibility():
	return action_popup.visible


func _find_inventory_ui() -> Node:
	var node = get_parent()
	while node != null:
		if node.has_method("update_slots"):
			return node
		node = node.get_parent()
	return null
