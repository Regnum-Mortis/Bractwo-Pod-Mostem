extends Panel


@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_label: Label = $CenterContainer/Panel/Label
@onready var DropScene: Node2D = $przycisk
@onready var DropButton: TextureButton = $przycisk/DropButton
@onready var ItemButton: TextureButton = $CenterContainer/Panel/ItemButton
var current_slot_data: inventorySlot
var Index: int = -1




func update(slot: inventorySlot):
	current_slot_data = slot # Zapamiętujemy dane slotu
	
	if slot == null or slot.item == null:
		item_visual.visible = false
		amount_label.visible = false
	else:
		ItemButton.disabled = false
		item_visual.visible = true
		amount_label.visible = true
		item_visual.texture = slot.item.texture
		amount_label.text = str(slot.amount)


func _on_item_button_pressed() -> void:
	var ui_parent = _find_inventory_ui()
	print(ui_parent)
	if current_slot_data and current_slot_data.item:
		var inventory = ui_parent.inventory
		Index = inventory.slots.find(current_slot_data)
		ui_parent.on_slot_clicked(self)
		
		
		#print("indeks tego slutu w tablicy to: ", Index)
		#print("Kliknięto przedmiot: ", current_slot_data.item.name)
		#print("Cały ekwipunek posiada ", inventory.slots.size(), " slotów.")


func _on_drop_button_pressed() -> void:
	var inventory = _find_inventory_ui()
	current_slot_data.item = null
	current_slot_data.amount = 0
	inventory.update_slots()
	print("clicked")
	hide_drop_button()

	


func hide_drop_button():
	DropScene.visible = false

func show_drop_button():
	DropScene.visible = true
	
func _find_inventory_ui():
	var node = get_parent()
	while node != null:
		if node.has_method("update_slots"):
			return node
		node = node.get_parent()
	return node


func check_visibility():
	return DropScene.visible
