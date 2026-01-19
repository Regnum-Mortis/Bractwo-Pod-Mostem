extends Resource

class_name Inventory

signal updated

@export var slots: Array[inventorySlot]

# Insert an InventoryItem resource into inventory.
# If an existing slot contains the same item, increase its amount (stacking).
# Otherwise place into the first empty slot. Returns `true` when placed, `false` on failure.
func insert(item: InventoryItem, amount: int = 1) -> bool:
	if item == null:
		return false
	# Try stacking into existing slot with same resource path
	for i in range(slots.size()):
		var s = slots[i]
		if s and s.item and s.item.resource_path == item.resource_path:
			s.amount = int(s.amount) + int(amount)
			updated.emit()
			return true
	# Find empty slot
	for i in range(slots.size()):
		var s = slots[i]
		if s == null or s.item == null:
			if s == null:
				# create a new slot resource if slot placeholder is null
				var slot_res = load("res://inventory_slot.gd").new()
				slot_res.item = item
				slot_res.amount = int(amount)
				slots[i] = slot_res
			else:
				s.item = item
				s.amount = int(amount)
			updated.emit()
			return true
	# No empty slot: fail
	return false


# Remove up to `amount` instances of `item` from inventory.
# Returns number actually removed.
func remove(item: InventoryItem, amount: int = 1) -> int:
	if item == null:
		return 0
	var to_remove = int(amount)
	for i in range(slots.size()):
		var s = slots[i]
		if s and s.item and s.item.resource_path == item.resource_path:
			var take = min(to_remove, int(s.amount))
			s.amount -= take
			to_remove -= take
			if s.amount <= 0:
				s.item = null
				s.amount = 0
			if to_remove <= 0:
				break
	updated.emit()
	return amount - to_remove


# Convenience: add item by resource path (e.g. "res://inventory/items/bread.tres")
func add_item_resource(res_path: String, amount: int = 1) -> bool:
	if not ResourceLoader.exists(res_path):
		return false
	var item_res = ResourceLoader.load(res_path)
	if item_res == null:
		return false
	return insert(item_res, amount)
