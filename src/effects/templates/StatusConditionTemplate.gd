class_name StatusConditionTemplate extends Resource
## Base class for status condition templates that generate StatusCondition instances
## based on entity properties (like level).

## Generate a StatusCondition instance
## @param user: Any object with relevant properties (e.g., get_level())
## @returns: A generated StatusCondition instance
func generate_condition(_user: CombatEntity) -> StatusCondition:
    push_error("StatusConditionTemplate.generate_condition() must be overridden in subclasses")
    return null
