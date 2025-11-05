
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
@export var status_effect: StatusEffect = null  # The immutable status effect resource
## When enabled, the log will show the ability name rather than the status name when it is first applied
@export var log_ability_name: bool = false
## Source type determines stacking behavior
@export var source_type: SourceType = SourceType.CONSUMABLE
## For equipment effects: reference count for stacking
@export var equipment_stack_count: int = 0

# Runtime instance data (not exported, created when applied)
var effect_instance: EffectInstance = null

func make_unique() -> StatusCondition:
    # No longer duplicate the effect - keep it immutable
    var new_condition := StatusCondition.new()
    new_condition.name = name
    new_condition.status_effect = status_effect  # Reference, not duplicate
    new_condition.log_ability_name = log_ability_name
    new_condition.source_type = source_type
    new_condition.equipment_stack_count = equipment_stack_count
    # Create a new instance for this condition
    new_condition.effect_instance = EffectInstance.new(status_effect)
    return new_condition

func get_log_name() -> String:
    return name if log_ability_name else status_effect.get_effect_name()

## Get the description for this condition with runtime data
func get_description() -> String:
    if status_effect is TimedEffect and effect_instance:
        return (status_effect as TimedEffect).get_description_with_instance(effect_instance)
    return status_effect.get_description()

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

