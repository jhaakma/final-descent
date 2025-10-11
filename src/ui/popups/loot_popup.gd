class_name LootPopup extends BasePopup
signal loot_collected()

enum LootContext {
    ENEMY_DEFEAT,
    CHEST_OPENING
}

@onready var loot_label: Label = %LootLabel
@onready var gold_label: Label = %GoldLabel
@onready var items_label: Label = %ItemsLabel
@onready var items_list: VBoxContainer = %ItemsList
@onready var no_loot_label: Label = %NoLootLabel
@onready var collect_btn: Button = %CollectBtn

var pending_loot_data: LootComponent.LootResult
var loot_already_collected: bool = false

static func get_scene() -> PackedScene:
    return load("uid://dqm2tfsxynhis") as PackedScene

func _ready() -> void:
    collect_btn.pressed.connect(_on_collect_loot)

    # Center the popup on screen
    _center_on_screen()

func show_loot(loot_data: LootComponent.LootResult, open_message: String) -> void:
    pending_loot_data = loot_data

    loot_label.text = open_message

    # Clear any existing item UI
    for child in items_list.get_children():
        child.queue_free()

    # Show/hide containers based on loot
    var has_any_loot := loot_data.gold_total > 0 or loot_data.items_gained.size() > 0

    if has_any_loot:
        no_loot_label.visible = false

        # Setup gold display
        if loot_data.gold_total > 0:
            gold_label.visible = true
            gold_label.text = "Gold: %d" % loot_data.gold_total
            gold_label.modulate = Color.GOLD
        else:
            gold_label.visible = false

        # Setup items display
        if loot_data.items_gained.size() > 0:
            items_label.visible = true
            items_label.modulate = Color.LIGHT_BLUE

            for stack in loot_data.items_gained:
                var item_label := Label.new()
                item_label.text = " • %s (x%d)" % [stack.item.name, stack.stack_count]
                item_label.modulate = Color.WHITE
                items_list.add_child(item_label)
        else:
            items_label.visible = false
    else:
        # No loot found
        gold_label.visible = false
        items_label.visible = false
        no_loot_label.visible = true


func _on_collect_loot() -> void:
    if loot_already_collected:
        return

    loot_already_collected = true

    # Apply the loot to game state
    _apply_loot_to_game_state(pending_loot_data)

    # Emit signal so room can mark as cleared
    emit_signal("loot_collected")

    # Close the popup
    queue_free()

func _on_popup_closed() -> void:
    # If the popup was closed without collecting loot, still apply it and clear the room
    if not loot_already_collected:
        loot_already_collected = true

        # Apply the loot to game state
        _apply_loot_to_game_state(pending_loot_data)

        # Emit signal so room can mark as cleared
        emit_signal("loot_collected")

# Apply loot to game state - works for both combat and chest contexts
func _apply_loot_to_game_state(loot_data: LootComponent.LootResult) -> void:
    # Add gold
    if loot_data.gold_total > 0:
        GameState.player.add_gold(loot_data.gold_total)

    # Add items
    if loot_data.items_gained.size() > 0:
        for item in loot_data.items_gained:
            for item_instance in item.get_item_tiles():
                GameState.player.add_items(item_instance)
