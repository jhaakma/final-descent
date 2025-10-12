class_name Enchantment extends Resource

func get_enchantment_name() -> String:
    print_debug("Enchantment.get_enchantment_name() should be overridden in subclasses.")
    return "Generic Enchantment"

func get_description() -> String:
    return "An enchantment that can be applied to items."

func initialise(_owner: Object) -> void:
    # This method can be overridden in subclasses if needed
    pass

func is_valid_owner(_owner: Object) -> bool:
    # This method can be overridden in subclasses to validate the owner
    return true