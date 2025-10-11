class_name StatusRow extends RichTextLabel

func _ready() -> void:
    # Configure RichTextLabel properties for proper display
    bbcode_enabled = true
    fit_content = true
    scroll_active = false
    # Set a reasonable size
    custom_minimum_size = Vector2(200, 20)
    size_flags_horizontal = Control.SIZE_EXPAND_FILL

# Initialize the StatusRow with a StatusEffect
func initialize_with_status_effect(effect: StatusEffect) -> void:
    var color: String = StatusEffect.EffectTypeMap[effect.get_effect_type()]
    var display_text: String

    if effect is TimedEffect:
        var timed_effect := effect as TimedEffect
        display_text = "[color=%s]%s (%d turns)[/color]" % [color, effect.get_effect_name(), timed_effect.remaining_turns]
    else:
        display_text = "[color=%s]%s[/color]" % [color, effect.get_effect_name()]

    print("Initializing StatusRow with status effect: %s" % display_text)

    bbcode_enabled = true
    clear()
    append_text(display_text)
    tooltip_text = effect.get_description()
    print("StatusRow text set, visible: %s, size: %s" % [visible, size])
