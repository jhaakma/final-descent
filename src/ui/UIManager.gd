## Manages UI elements and popups for the game
class_name UIManager extends Node

static var instance: UIManager

const ITEM_SELECTION_POPUP_SCENE = preload("res://src/ui/widgets/ItemSelectionPopup.tscn")

func _ready() -> void:
    if instance:
        push_error("UIManager instance already exists!")
        queue_free()
        return
    instance = self

## Show a popup to select from available armor items for enchantment
func show_armor_selection_popup(available_armor: Array[ItemInstance], callback: Callable, cancel_callback: Callable = Callable()) -> void:
    var popup := ITEM_SELECTION_POPUP_SCENE.instantiate()

    # Connect signals first
    popup.connect("item_selected", callback)
    if cancel_callback.is_valid():
        popup.connect("cancelled", cancel_callback)
    else:
        popup.connect("cancelled", _on_popup_cancelled)

    # Use the existing PopupLayer from the main scene
    var main_scene := get_tree().current_scene
    if main_scene:
        var popup_layer := main_scene.get_node("PopupLayer")
        if popup_layer:
            popup_layer.add_child(popup)
            popup.set("visible", true)

            # Now setup the popup after it's in the tree
            popup.call("setup", "Select Armor to Enchant", available_armor)

## Show a popup to select from available equipped items for repair
func show_repair_selection_popup(available_items: Array[ItemInstance], callback: Callable, cancel_callback: Callable = Callable()) -> void:
    var popup := ITEM_SELECTION_POPUP_SCENE.instantiate()

    # Connect signals first
    popup.connect("item_selected", callback)
    if cancel_callback.is_valid():
        popup.connect("cancelled", cancel_callback)
    else:
        popup.connect("cancelled", _on_popup_cancelled)

    # Use the existing PopupLayer from the main scene
    var main_scene := get_tree().current_scene
    if main_scene:
        var popup_layer := main_scene.get_node("PopupLayer")
        if popup_layer:
            popup_layer.add_child(popup)
            popup.set("visible", true)

            # Now setup the popup after it's in the tree
            popup.call("setup", "Select Item to Repair", available_items)

func _on_popup_cancelled() -> void:
    # Handle popup cancellation if needed
    pass
