class_name DefendTemplate extends AbilityTemplate
## Template for generating defend abilities

func generate_ability(_user = null) -> AbilityResource:
    var ability := DefendAbility.new()
    ability.ability_name = "Defend"
    ability.description = "Take a defensive stance"
    ability.priority = 5
    return ability
