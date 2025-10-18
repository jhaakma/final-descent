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

    display_text = "[color=%s]%s[/color]" % [color, condition.name]

    print("Initializing StatusRow with status effect: %s" % display_text)

    status_text.text = display_text

    var description := str(effect.get_description())
    # status_value.text = "[color=%s]%s[/color]" % [color, description]
    status_value.text = description

    print("StatusRow text set, visible: %s, size: %s" % [visible, size])
