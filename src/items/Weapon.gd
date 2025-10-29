@tool
class_name Weapon extends Equippable

signal attack_hit(target: CombatEntity)

@export var damage: int = 3
@export var damage_type: DamageType.Type = DamageType.Type.BLUNT

func _init() -> void:
    name = "Weapon"

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

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    var info: Array[AdditionalTooltipInfoData] = super.get_additional_tooltip_info()

    var damage_info := AdditionalTooltipInfoData.new()
    var damage_type_name := DamageType.get_type_name(damage_type)
    var damage_type_color := DamageType.get_type_color(damage_type)
    damage_info.text = "⚔️ Damage: %d (%s)" % [damage, damage_type_name]
    damage_info.color = damage_type_color
    info.insert(0, damage_info)  # Insert at beginning so damage shows before enchantment

    return info

func get_base_inventory_color() -> Color:
    return Color("#a56868ff")