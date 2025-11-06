@tool
class_name Weapon extends Equippable

signal attack_hit(target: CombatEntity)

@export var damage: int = 3
@export var damage_type: DamageType.Type = DamageType.Type.BLUNT

var _base_damage: int = 0
var _base_condition: int = 0

func _init() -> void:
    name = "Weapon"
    _base_name = ""  # Explicitly initialize base name

func get_category() -> Item.ItemCategory:
    return Item.ItemCategory.WEAPON

func get_equip_slot() -> Equippable.EquipSlot:
    return Equippable.EquipSlot.WEAPON

func is_valid_enchantment(enchant: Enchantment) -> bool:
    # Weapons can only have on-strike enchantments
    return enchant is OnStrikeEnchantment

func _on_use(item_data: ItemData) -> bool:
    return GameState.player.equip_weapon(ItemInstance.new(self, item_data, 1))

func on_attack_hit(_target: CombatEntity) -> void:
    attack_hit.emit(_target)

## Override to apply modifier stat changes to weapon
func _apply_modifier_to_stats() -> void:
    super._apply_modifier_to_stats()

    if not modifier:
        return

    # Store base values if not already stored
    if _base_damage == 0:
        _base_damage = damage
    if _base_condition == 0:
        _base_condition = condition

    # Apply modifier bonuses to stats
    damage = int(_base_damage * modifier.damage_modifier)
    var new_condition: int = int(_base_condition * modifier.condition_modifier)

    # If condition changed, we need to scale current_condition proportionally for equipped items
    # This is handled in the apply_modifier method of Equippable
    condition = new_condition

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    var info: Array[AdditionalTooltipInfoData] = super.get_additional_tooltip_info()

    var damage_info := AdditionalTooltipInfoData.new()
    var damage_type_name := DamageType.get_type_name(damage_type)
    var damage_type_color := DamageType.get_type_color(damage_type)
    damage_info.text = "⚔️ Damage: %d (%s)" % [damage, damage_type_name]
    damage_info.color = damage_type_color
    info.insert(0, damage_info)  # Insert at beginning so damage shows before modifier/enchantment

    return info

func get_base_inventory_color() -> Color:
    return Color("#a56868ff")
