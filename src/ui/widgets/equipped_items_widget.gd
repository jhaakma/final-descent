class_name EquippedItemsWidget extends VBoxContainer

@onready var equipped_label: Label = %EquippedLabel
@onready var equipped_items_container: VBoxContainer = %EquippedItemsContainer

func _ready() -> void:
    # Connect to player signals to update when equipment changes
    if GameState.player:
        GameState.player.inventory_changed.connect(_on_equipment_changed)

    _update_equipped_display()

func _on_equipment_changed() -> void:
    _update_equipped_display()

func _update_equipped_display() -> void:
    if not is_inside_tree():
        return

    # Clear existing displays
    for child in equipped_items_container.get_children():
        child.queue_free()

    if not GameState.player:
        return

    var equipped_items := GameState.player.get_all_equipped_items()

    if equipped_items.is_empty():
        # Show "None equipped" message
        var empty_label := Label.new()
        empty_label.text = "None equipped"
        empty_label.add_theme_color_override("font_color", Color.GRAY)
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        equipped_items_container.add_child(empty_label)
        return

    # Display each equipped item using InventoryRow
    for item_instance: ItemInstance in equipped_items:
        var item_row := _create_equipped_item_row(item_instance)
        equipped_items_container.add_child(item_row)

func _create_equipped_item_row(item_instance: ItemInstance) -> Control:
    # Create a container for slot label + inventory row
    var container := HBoxContainer.new()

    # # Slot label
    # var slot_label := Label.new()
    # if item_instance.item is Equippable:
    #     var equippable: Equippable = item_instance.item as Equippable
    #     slot_label.text = equippable.get_equip_slot_name() + ":"
    # else:
    #     slot_label.text = "Weapon:"  # Legacy weapon
    # slot_label.custom_minimum_size.x = 80
    # slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    # container.add_child(slot_label)

    # Create InventoryRow for the item in EQUIPPED mode
    var inventory_row := InventoryRow.get_scene().instantiate() as InventoryRow
    inventory_row.setup_with_mode(item_instance, InventoryRow.DisplayMode.EQUIPPED, false)
    inventory_row.item_used.connect(_on_item_used)
    container.add_child(inventory_row)

    # Set size flags so the inventory row expands
    inventory_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    return container

func _on_item_used(item_instance: ItemInstance) -> void:
    # InventoryRow will show "Unequip" for equipped items
    # When clicked, it emits item_used, so we unequip the item directly
    if item_instance and item_instance.item:
        if item_instance.item is Equippable:
            var equippable: Equippable = item_instance.item as Equippable
            GameState.player.unequip_item(equippable.get_equip_slot())
        elif item_instance.item is Weapon:
            # Legacy weapon handling
            GameState.player.unequip_weapon()
