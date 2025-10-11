class_name LootPick extends Resource

@export var loot_table: Array[Item] = []
@export var count: int = 1
@export var chance_none: float = 0.0
@export var pick_method: LootPickMethod.PickMethod = LootPickMethod.PickMethod.RANDOM
@export var floor_min: int = 0

var resolved_items: Array[ItemStack] = []

func _get_none() -> bool:
    return loot_table.is_empty() or (chance_none > 0.0 and GameState.rng.randf() < chance_none)

func resolve_items() -> Array[ItemStack]:
    resolved_items.clear()
    if _get_none():
        print("No items resolved due to chance or empty loot table.")
        return resolved_items
    var current_floor := GameState.current_floor
    if current_floor < floor_min:
        print("Current floor %d is below minimum floor %d for this loot pick." % [current_floor, floor_min])
        return resolved_items
    var pick_func := LootPickMethod.pick_methods[pick_method]
    return pick_func.call(loot_table, count)
