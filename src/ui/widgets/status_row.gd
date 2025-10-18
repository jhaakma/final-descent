class_name StatusRow extends Control

@onready var status_text: RichTextLabel = %StatusText
@onready var status_value: RichTextLabel = %StatusValue

static func get_scene() -> PackedScene:
    return preload("uid://cfnfquwrmhs5x") as PackedScene

func _ready() -> void:
    # Configure RichTextLabel properties for proper display
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
        display_text = "[color=%s]%s (%d turns)[/color]" % [color, condition.name, timed_effect.get_remaining_turns()]
    else:
        display_text = "[color=%s]%s[/color]" % [color, condition.name]

    print("Initializing StatusRow with status effect: %s" % display_text)

    status_text.text = display_text
    tooltip_text = effect.get_description()
    print("StatusRow text set, visible: %s, size: %s" % [visible, size])
