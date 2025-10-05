class_name StatusRow extends RichTextLabel

func _ready() -> void:
	# Configure RichTextLabel properties for proper display
	bbcode_enabled = true
	fit_content = true
	scroll_active = false
	# Set a reasonable size
	custom_minimum_size = Vector2(200, 20)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

# Initialize the StatusRow with either a Buff or StatusEffect
func initialize_with_buff(buff: Buff) -> void:
	var color = Buff.EffectColorMap[buff.effect_color]
	var display_text = "[color=%s]%s (%d turns)[/color]" % [color, buff.name, buff.remaining_duration]
	print("Initializing StatusRow with buff: %s" % display_text)

	bbcode_enabled = true
	clear()
	append_text(display_text)
	tooltip_text = buff.description
	print("StatusRow text set, visible: %s, size: %s" % [visible, size])

# Initialize the StatusRow with a StatusEffect
func initialize_with_status_effect(effect: StatusEffect) -> void:
	var color = StatusEffect.EffectColorMap[effect.effect_color]
	var display_text: String

	if effect is TimedEffect:
		display_text = "[color=%s]%s (%d turns)[/color]" % [color, effect.effect_name, effect.remaining_turns]
	else:
		display_text = "[color=%s]%s[/color]" % [color, effect.effect_name]

	print("Initializing StatusRow with status effect: %s" % display_text)

	bbcode_enabled = true
	clear()
	append_text(display_text)
	tooltip_text = effect.get_description()
	print("StatusRow text set, visible: %s, size: %s" % [visible, size])