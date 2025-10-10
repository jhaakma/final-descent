class_name LootPickMethod extends Resource

enum PickMethod {
    RANDOM,
    ALL
}

static var pick_methods: Dictionary[PickMethod, Callable] = {
    PickMethod.RANDOM: func(loot_table: Array[Item], count: int) -> Array[Item]:
        var resolved_items: Array[Item] = []
        if loot_table.size() == 0:
            return resolved_items
        if count > 0 and loot_table.size() == 1:
            resolved_items.append(loot_table[0])
            return resolved_items

        print("Picking %d random items from loot table." % count)
        var available_items := loot_table.duplicate()
        for i in count:
            if available_items.is_empty():
                break
            var index := GameState.rng.randi_range(0, available_items.size() - 1)
            resolved_items.append(available_items[index])
            available_items.remove_at(index)
        return resolved_items,
    PickMethod.ALL: func(loot_table: Array[Item], _count: int) -> Array[Item]:
        print("Picking all items from loot table.")
        return loot_table.duplicate()
}
