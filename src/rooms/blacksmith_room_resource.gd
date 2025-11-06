class_name BlacksmithRoomResource extends RoomResource

@export var repair_cost_per_condition: int = 2  # Gold cost per condition point to repair
@export var upgrade_cost: int = 50  # Fixed gold cost to apply a random modifier
@export var available_modifiers: Array[EquipmentModifier] = []  # Pool of modifiers that can be applied

func is_cleared_by_default() -> bool:
    return true

func build_actions(actions_grid: GridContainer, room_screen: RoomScreen) -> void:
    var talk_action := RoomAction.new("Talk to the Blacksmith")
    talk_action.is_enabled = true
    talk_action.perform_action = _on_talk_to_blacksmith

    add_action_button(actions_grid, room_screen, talk_action)

func _on_talk_to_blacksmith(room_screen: RoomScreen) -> void:
    # Show the inline blacksmith
    var blacksmith_scene: PackedScene = load("res://src/ui/components/InlineBlacksmith.tscn")
    var inline_blacksmith: Control = blacksmith_scene.instantiate()
    inline_blacksmith.call("show_blacksmith", self, title)

    # Show the inline blacksmith content
    room_screen.show_inline_content(inline_blacksmith)

    # Connect the blacksmith closed signal to allow leaving the room
    if inline_blacksmith.has_signal("blacksmith_closed"):
        inline_blacksmith.connect("blacksmith_closed", _on_blacksmith_closed.bind(room_screen))

func _on_blacksmith_closed(_room_screen: RoomScreen) -> void:
    # Player can continue after using blacksmith services
    pass

## Calculate repair cost for an item
func calculate_repair_cost(item: Equippable, item_data: ItemData) -> int:
    if not item_data:
        return 0

    var max_condition: int = item.get_max_condition()
    var current_condition: int = item_data.current_condition
    var missing_condition: int = max_condition - current_condition

    return missing_condition * repair_cost_per_condition

## Repair an item to full condition
func repair_item(item_instance: ItemInstance) -> bool:
    if not item_instance.item_data:
        return false

    var item: Equippable = item_instance.item as Equippable
    if not item:
        return false

    var cost: int = calculate_repair_cost(item, item_instance.item_data)

    if not GameState.player.has_gold(cost):
        return false

    GameState.player.add_gold(-cost)
    item_instance.item_data.current_condition = item.get_max_condition()

    LogManager.log_event("Repaired %s to full condition for %d gold" % [item.name, cost])

    # Emit inventory changed to update UI
    GameState.player.emit_signal("inventory_changed")

    return true

## Apply a random modifier to an item
func upgrade_item(item_instance: ItemInstance) -> bool:
    var item: Equippable = item_instance.item as Equippable
    if not item:
        return false

    # Check if item can have a modifier
    if not item.can_have_modifier():
        LogManager.log_event("%s already has a modifier applied" % item.name)
        return false

    # Check if player has enough gold
    if not GameState.player.has_gold(upgrade_cost):
        LogManager.log_event("Not enough gold to upgrade (need %d gold)" % upgrade_cost)
        return false

    # Filter available modifiers to only those that can be applied to this item
    var valid_modifiers: Array[EquipmentModifier] = []
    for mod in available_modifiers:
        if mod.can_apply_to(item):
            valid_modifiers.append(mod)

    if valid_modifiers.is_empty():
        LogManager.log_event("No modifiers available for %s" % item.name)
        return false

    # Select a random valid modifier
    var chosen_modifier: EquipmentModifier = valid_modifiers[GameState.rng.randi_range(0, valid_modifiers.size() - 1)]

    # Store old max condition before applying modifier
    var old_max_condition: int = item.get_max_condition()
    var old_current_condition: int = 0
    if item_instance.item_data:
        old_current_condition = item_instance.item_data.current_condition

    # Apply the modifier
    if item.apply_modifier(chosen_modifier):
        GameState.player.add_gold(-upgrade_cost)

        # If item has ItemData and condition changed, scale current_condition proportionally
        if item_instance.item_data and old_max_condition > 0:
            var new_max_condition: int = item.get_max_condition()
            if new_max_condition != old_max_condition:
                # Scale current condition proportionally
                var condition_ratio: float = float(old_current_condition) / float(old_max_condition)
                item_instance.item_data.current_condition = int(new_max_condition * condition_ratio)

        LogManager.log_event("Applied %s modifier to %s for %d gold" % [chosen_modifier.modifier_name, item.name, upgrade_cost])

        # Emit inventory changed to update UI
        GameState.player.emit_signal("inventory_changed")

        return true

    return false
