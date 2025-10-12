class_name StatusRow extends RichTextLabel

func _ready() -> void:
    # Configure RichTextLabel properties for proper display
    bbcode_enabled = true
    fit_content = true
    scroll_active = false
    # Set a reasonable size
    custom_minimum_size = Vector2(200, 20)
    size_flags_horizontal = Control.SIZE_EXPAND_FILL

# Initialize the StatusRow with a StatusCondition
func initialize_with_condition(condition: StatusCondition) -> void:
    var effect := condition.status_effect
    var color: String = StatusEffect.EffectTypeMap[effect.get_effect_type()]
    var display_text: String

    if effect is TimedEffect:
        var timed_effect := effect as TimedEffect
        var stacks_text := ""
        if timed_effect.get_max_stacks() > 1:
            stacks_text = "x%d " % timed_effect.stack_durations.size()
        display_text = "[color=%s]%s %s(%d turns)[/color]" % [color, condition.name, stacks_text, timed_effect.get_remaining_turns()]
    else:
        display_text = "[color=%s]%s[/color]" % [color, condition.name]

    print("Initializing StatusRow with status effect: %s" % display_text)

    bbcode_enabled = true
    clear()
    append_text(display_text)
    tooltip_text = effect.get_description()
    print("StatusRow text set, visible: %s, size: %s" % [visible, size])
