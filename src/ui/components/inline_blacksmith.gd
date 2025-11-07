class_name InlineBlacksmith extends InlineContentBase

## Inline blacksmith component for equipment repair and upgrade services
## Displays services directly in the room container

signal blacksmith_closed()

@onready var greeting_label: Label = %GreetingLabel
@onready var player_gold_label: Label = %PlayerGoldLabel
@onready var service_tabs: TabContainer = %ServiceTabs
@onready var repair_list: VBoxContainer = %RepairList
@onready var upgrade_list: VBoxContainer = %UpgradeList
@onready var close_btn: Button = %CloseBtn

var inventory_row_scene: PackedScene = InventoryRow.get_scene()
var blacksmith_room: BlacksmithRoomResource = null
var greeting_text: String = "Welcome to the Forge!"

static func get_scene() -> PackedScene:
    return load("res://src/ui/components/InlineBlacksmith.tscn") as PackedScene

func _ready() -> void:
    close_btn.pressed.connect(_on_close_blacksmith)
    # Update gold display when stats change
    GameState.stats_changed.connect(_update_gold_display)
    GameState.player.inventory_changed.connect(_update_displays)

func show_blacksmith(room: BlacksmithRoomResource, greeting: String) -> void:
    # Wait for _ready if nodes aren't available yet
    if not greeting_label:
        await ready

    blacksmith_room = room
    greeting_text = greeting
    greeting_label.text = greeting_text
    _update()

func show_content() -> void:
    super.show_content()
    # Refresh the blacksmith display when shown
    _update()

func _update() -> void:
    _update_gold_display()
    _setup_repair_tab()
    _setup_upgrade_tab()

func _update_gold_display() -> void:
    if player_gold_label:
        player_gold_label.text = "Your Gold: %d" % GameState.player.gold

func _update_displays() -> void:
    _setup_repair_tab()
    _setup_upgrade_tab()

func get_equipment() -> Array[ItemInstance]:
    var equipment: Array[ItemInstance] = []
    var inventory_items: Array[ItemInstance] = GameState.player.get_item_tiles()

    for item_instance in inventory_items:
       if item_instance.item is Equippable:
            equipment.append(item_instance)

    return equipment

func _setup_repair_tab() -> void:
    # Clear existing items
    for child in repair_list.get_children():
        child.queue_free()

    var equipment := get_equipment()

    if equipment.is_empty():
        var no_items_label: Label = Label.new()
        no_items_label.text = "No equipment to repair."
        repair_list.add_child(no_items_label)
        return

    # Filter to only items that need repair
    var items_needing_repair: Array[ItemInstance] = []
    for item_instance in equipment:
        if item_instance.item_data and item_instance.item_data.current_condition < (item_instance.item as Equippable).get_max_condition():
            items_needing_repair.append(item_instance)

    if items_needing_repair.is_empty():
        var no_items_label: Label = Label.new()
        no_items_label.text = "All equipment is in perfect condition."
        repair_list.add_child(no_items_label)
        return

    # Add each item that needs repair
    for item_instance in items_needing_repair:
        var item_row: InventoryRow = inventory_row_scene.instantiate()
        item_row.setup_for_blacksmith(item_instance, InventoryRow.DisplayMode.BLACKSMITH_REPAIR, blacksmith_room)
        item_row.item_repaired.connect(_on_repair_item)
        repair_list.add_child(item_row)

func _setup_upgrade_tab() -> void:
    # Clear existing items
    for child in upgrade_list.get_children():
        child.queue_free()

    # Get all equipped items
    var equipment := get_equipment()

    if equipment.is_empty():
        var no_items_label: Label = Label.new()
        no_items_label.text = "No equipment to upgrade."
        upgrade_list.add_child(no_items_label)
        return

    # Filter to only items that can be upgraded AND have valid modifiers available
    var upgradeable_items: Array[ItemInstance] = []
    for item_instance in equipment:
        var item: Equippable = item_instance.item as Equippable
        if item.can_have_modifier():
            # Check if any modifiers can apply to this item
            var has_valid_modifier: bool = false
            for mod in blacksmith_room.available_modifiers:
                if mod.can_apply_to(item):
                    has_valid_modifier = true
                    break
            if has_valid_modifier:
                upgradeable_items.append(item_instance)

    if upgradeable_items.is_empty():
        var no_items_label: Label = Label.new()
        no_items_label.text = "All equipment is already upgraded."
        upgrade_list.add_child(no_items_label)
        return

    # Add info label about upgrades
    var info_label := Label.new()
    info_label.text = "Apply a random modifier to equipment (cost: %d gold)" % blacksmith_room.upgrade_cost
    info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    upgrade_list.add_child(info_label)

    var separator := HSeparator.new()
    separator.modulate = Color(1, 1, 1, 0.3)
    upgrade_list.add_child(separator)

    # Add each upgradeable item
    for item_instance in upgradeable_items:
        var item_row: InventoryRow = inventory_row_scene.instantiate()
        item_row.setup_for_blacksmith(item_instance, InventoryRow.DisplayMode.BLACKSMITH_UPGRADE, blacksmith_room)
        item_row.item_upgraded.connect(_on_upgrade_item)
        upgrade_list.add_child(item_row)

func _on_repair_item(item_instance: ItemInstance) -> void:
    if blacksmith_room.repair_item(item_instance):
        _update()

func _on_upgrade_item(item_instance: ItemInstance) -> void:
    if blacksmith_room.upgrade_item(item_instance):
        _update()

func _on_close_blacksmith() -> void:
    emit_signal("blacksmith_closed")
    emit_signal("content_resolved")  # Mark content as resolved when closing
