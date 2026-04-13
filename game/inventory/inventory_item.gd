extends Resource

class_name InventoryItem

@export var name: String = ""
@export var texture: Texture2D = null
@export var consumable: bool = false

# Typ przedmiotu: "food", "tool", "junk"
@export var item_type: String = ""

# Dane jedzenia (consumable == true)
@export var hunger_restore: float = 0.0

# Dane narzędzia
@export var durability: float = 0.0

# Dane handlowe
@export var price: float = 0.0
