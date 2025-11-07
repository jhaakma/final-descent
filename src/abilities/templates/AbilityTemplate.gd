class_name AbilityTemplate extends Resource
## Base interface for ability templates that generate AbilityResource instances
## Templates allow dynamic ability generation based on the user's stats and properties

## Generate an ability instance for the given user
## Override this method in subclasses to implement specific generation logic
## The user parameter is optional and can be null or any type that has relevant properties
func generate_ability(_user: EnemyResource = null) -> AbilityResource:
    push_error("AbilityTemplate.generate_ability() must be overridden in subclasses")
    return null
