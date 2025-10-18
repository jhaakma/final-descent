## Base class for all runes - provides enchantment capabilities
class_name Rune extends Item

func get_category() -> Item.ItemCategory:
    return Item.ItemCategory.MISC

func get_consumable() -> bool:
    return true  # Runes are consumable

## Override in subclasses to return the specific enchantment
func get_enchantment() -> Enchantment:
    push_error("Rune.get_enchantment() must be overridden in subclasses")
    return null

## Override in subclasses to implement specific enchantment logic
func _on_use(_item_data: ItemData) -> bool:
    push_error("Rune._on_use() must be overridden in subclasses")
    return false

## Override in subclasses to provide appropriate tooltip information
func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    var enchantment := get_enchantment()
    if not enchantment:
        return []
    var info := AdditionalTooltipInfoData.new()
    info.text = "🔮 %s: %s" % [get_rune_type_name(), enchantment.get_description()]
    info.color = Color(0.8, 0.6, 1.0)
    return [info]

## Override in subclasses to provide the rune type name for tooltips
func get_rune_type_name() -> String:
    return "Enchant"

func get_inventory_color() -> Color:
    return Color("#ff94abff")