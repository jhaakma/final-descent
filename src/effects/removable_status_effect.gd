class_name RemovableStatusEffect extends StatusEffect

# Base class for status effects that have removal lifecycle methods
# This provides a common interface for effects that need cleanup when removed

# Called when the effect is first applied to an entity
func on_applied(_target: CombatEntity) -> void:
    pass

# Called when the effect is removed from an entity
func on_removed(_target: CombatEntity) -> void:
    pass