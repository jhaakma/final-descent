
## StatusCondition
## A resource representing a status condition that can be applied to entities.
class_name StatusCondition extends Resource

enum SourceType {
    CONSUMABLE,     # From potions, scrolls, etc. - should not stack
    EQUIPMENT,      # From equipped items - should allow stacking
    SPELL,          # From spell casting - should allow stacking
    ABILITY         # From creature abilities - should allow stacking
}

@export var name: String = "Buff" # Name of the status condition
@export var status_effect: StatusEffect = null  # The status effect to apply
## When enabled, the log will show the ability name rather than the status name when it is first applied
@export var log_ability_name: bool = false
## Source type determines stacking behavior
@export var source_type: SourceType = SourceType.CONSUMABLE
## For equipment effects: reference count for stacking
@export var equipment_stack_count: int = 0

func make_unique() -> StatusCondition:
    return self.duplicate(true)

func get_log_name() -> String:
    return name if log_ability_name else status_effect.get_effect_name()

## Increment equipment stack count
func add_equipment_stack() -> void:
    if source_type == SourceType.EQUIPMENT:
        equipment_stack_count += 1

## Decrement equipment stack count and return true if should be removed entirely
func remove_equipment_stack() -> bool:
    if source_type == SourceType.EQUIPMENT and equipment_stack_count > 0:
        equipment_stack_count -= 1
        return equipment_stack_count <= 0  # Return true if no stacks left
    return false

## Check if this condition has any active equipment stacks
func has_equipment_stacks() -> bool:
    return source_type == SourceType.EQUIPMENT and equipment_stack_count > 0

## Create a Condition that represents the given StatusEffect
static func from_status_effect(_status_effect: StatusEffect) -> StatusCondition:
    var condition := StatusCondition.new()
    condition.name = _status_effect.get_effect_name()
    condition.status_effect = _status_effect
    return condition

## Create a Condition for equipment-based effects with reference counting
static func from_equipment_effect(_status_effect: StatusEffect) -> StatusCondition:
    var condition := StatusCondition.new()
    condition.name = _status_effect.get_effect_name()
    condition.status_effect = _status_effect
    condition.source_type = SourceType.EQUIPMENT
    condition.equipment_stack_count = 1
    return condition

