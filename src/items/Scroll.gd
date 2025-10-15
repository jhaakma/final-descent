class_name Scroll extends Item

@export var spell: Spell
@export var requires_target: bool = false

func _get_name() -> String:
    if spell:
        return "Scroll of %s" % spell.spell_name
    return "Blank Scroll"

func get_category() -> Item.ItemCategory:
    return Item.ItemCategory.SCROLL

func get_consumable() -> bool:
    return true

func _on_use(_item_data: ItemData) -> bool:
    if not spell or not spell is Spell:
        LogManager.log_message("The scroll appears to be blank...")
        return false

    var spell_cast := spell.duplicate() as Spell
    spell_cast.spell_name = name

    # Check if this is a TARGET spell and we're not in combat
    if spell_cast.get_target_type() == Spell.SpellTarget.TARGET and requires_target:
        if not GameState.is_in_combat:
            LogManager.log_message("This spell can only be used in combat!")
            return false

    # Get the player as the caster
    var caster: CombatEntity = GameState.player

    if not spell_cast.can_cast(caster):
        LogManager.log_message("You cannot cast this spell right now.")
        return false

    # Determine the target based on spell requirements and combat state
    var target: CombatEntity = null

    match spell_cast.get_target_type():
        Spell.SpellTarget.SELF:
            target = caster
        Spell.SpellTarget.TARGET:
            if requires_target and GameState.is_in_combat:
                # In combat, target the enemy
                target = GameState.get_current_enemy()
                if not target:
                    LogManager.log_message("No valid target available.")
                    return false
            else:
                # Outside combat or self-beneficial spell, target self
                target = caster
        Spell.SpellTarget.BOTH:
            target = caster  # Spell will handle both caster and target

    # Cast the spell
    spell_cast.cast(caster, target)
    return true

func get_description() -> String:
    if spell and spell is Spell:
        var spell_cast := spell as Spell
        return "A magical scroll containing the spell '%s'.\n\n%s" % [spell_cast.spell_name, spell_cast.get_description()]
    else:
        return "A blank magical scroll."

func get_additional_tooltip_info() -> Array[AdditionalTooltipInfoData]:
    if not spell or not spell is Spell:
        return []

    var spell_cast := spell as Spell
    var info_array: Array[AdditionalTooltipInfoData] = []

    # Add spell information
    var spell_info := AdditionalTooltipInfoData.new()
    spell_info.text = "✨ Spell: %s" % spell_cast.spell_name
    spell_info.color = Color(0.8, 0.6, 1.0)  # Purple for magic
    info_array.append(spell_info)

    # Add target type information
    var target_info := AdditionalTooltipInfoData.new()
    var target_text: String
    match spell_cast.get_target_type():
        Spell.SpellTarget.SELF:
            target_text = "🎯 Targets: Self"
        Spell.SpellTarget.TARGET:
            target_text = "🎯 Targets: Other"
        Spell.SpellTarget.BOTH:
            target_text = "🎯 Targets: Self and Other"
        _:
            target_text = "🎯 Targets: Unknown"

    target_info.text = target_text
    target_info.color = Color(0.7, 0.9, 1.0)  # Light blue for targeting
    info_array.append(target_info)

    # Add mana cost if applicable
    if spell_cast.get_mana_cost() > 0:
        var mana_info := AdditionalTooltipInfoData.new()
        mana_info.text = "💙 Mana Cost: %d" % spell_cast.get_mana_cost()
        mana_info.color = Color(0.4, 0.6, 1.0)  # Blue for mana
        info_array.append(mana_info)

    return info_array

func get_inventory_color() -> Color:
    # Purple tint for scrolls to distinguish them
    return Color(0.9, 0.7, 1.0)
