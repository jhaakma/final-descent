
## StatusCondition
## A resource representing a status condition that can be applied to entities.
class_name StatusCondition extends Resource

@export var name: String = "Buff" # Name of the status condition
@export var status_effect: StatusEffect = null  # The status effect to apply
## When enabled, the log will show the ability name rather than the status name when it is first applied
@export var log_ability_name: bool = false

func make_unique() -> StatusCondition:
    return self.duplicate(true)

func get_log_name() -> String:
    return name if log_ability_name else status_effect.get_effect_name()

## Create a Condition that represents the given StatusEffect
static func from_status_effect(_status_effect: StatusEffect) -> StatusCondition:
    var condition := StatusCondition.new()
    condition.name = _status_effect.get_effect_name()
    condition.status_effect = _status_effect
    return condition

