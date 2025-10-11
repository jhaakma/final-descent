class_name LootComponent extends Resource

@export var gold_min: int = 0
@export var gold_max: int = 0
@export var loot_table: Array[LootPick] = []

class LootResult:
    var gold_total: int = 0
    var items_gained: Array[ItemStack] = []

# Generate loot based on the configuration
func generate_loot() -> LootResult:
    var loot_result := LootResult.new()

    # Generate gold amount
    if gold_max > 0 and gold_max >= gold_min:
        var gold_amount := GameState.rng.randi_range(gold_min, gold_max)
        loot_result.gold_total += gold_amount

    # Process loot table
    for loot_pick in loot_table:
        var items := loot_pick.resolve_items()
        loot_result.items_gained += items

    return loot_result

func apply_gold(loot_result: LootResult) -> void:
    if loot_result.gold_total > 0:
        GameState.player.add_gold(loot_result.gold_total)
        LogManager.log_success("Received %d gold." % loot_result.gold_total)
