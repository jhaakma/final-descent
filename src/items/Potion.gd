class_name ItemPotion extends Item

@export var status_effect: StatusEffect
@export var log_potion_name: bool = false

func get_category() -> Item.ItemCategory:
    return Item.ItemCategory.POTION

func get_consumable() -> bool:
    return true

func _on_use(_item_data: ItemData) -> bool:
    # Duplicate the effect to avoid modifying the original resource
    var condition := StatusCondition.new()
    condition.name = name
    condition.status_effect = status_effect.duplicate()
    condition.log_ability_name = log_potion_name
    return GameState.player.apply_status_condition(condition)

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    if not status_effect:
        return []
    var info := AdditionalTooltipInfoData.new()
    info.text = "✨ %s" % status_effect.get_base_description()

    info.color = Color(0.6, 1.0, 0.8)
    return [info]

func get_inventory_color() -> Color:
    return Color("#a9dfc4ff")