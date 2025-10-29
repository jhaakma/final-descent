class_name LootPickMethod extends Resource

enum PickMethod {
    RANDOM,
    ALL
}

## Helper function to resolve either an Item or ItemGenerator to an actual Item
static func _resolve_source_to_item(source: Resource) -> Item:
    if source is Item:
        return source as Item
    elif source is ItemGenerator:
        return (source as ItemGenerator).generate_item()
    else:
        push_error("Invalid source type in loot table: %s" % source.get_class())
        return null

static var pick_methods: Dictionary[PickMethod, Callable] = {
    PickMethod.RANDOM: func(sources: Array, count: int) -> Array[ItemStack]:
        var resolved_items: Array[ItemStack] = []
        if sources.size() == 0:
            return resolved_items
        if count > 0 and sources.size() == 1:
            var item: Item = LootPickMethod._resolve_source_to_item(sources[0])
            if item != null:
                resolved_items.append(ItemStack.new(item, 1))
            return resolved_items

        print("Picking %d random items from loot sources." % count)
        var available_sources := sources.duplicate()
        for i in count:
            if available_sources.is_empty():
                break
            var index := GameState.rng.randi_range(0, available_sources.size() - 1)
            var item: Item = LootPickMethod._resolve_source_to_item(available_sources[index])
            if item != null:
                resolved_items.append(ItemStack.new(item, 1))
            available_sources.remove_at(index)
        return resolved_items,
    PickMethod.ALL: func(sources: Array, count: int) -> Array[ItemStack]:
        print("Picking all items from loot sources.")
        var resolved_items: Array[ItemStack] = []
        for source: Resource in sources:
            var item: Item = LootPickMethod._resolve_source_to_item(source)
            if item != null:
                resolved_items.append(ItemStack.new(item, count))
        return resolved_items
}