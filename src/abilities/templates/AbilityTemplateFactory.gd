class_name AbilityTemplateFactory extends RefCounted
## Factory for creating pre-configured ability templates for enemy generation

## Create a basic attack template
static func create_basic_attack() -> BasicAttackTemplate:
    return BasicAttackTemplate.new()

## Create a basic strike template
static func create_basic_strike(level: int) -> BasicStrikeTemplate:
    var template := BasicStrikeTemplate.new()
    return template.configure(level)

## Create an elemental strike template
static func create_elemental_strike(element: EnemyTemplate.ElementAffinity, level: int) -> ElementalStrikeTemplate:
    var template := ElementalStrikeTemplate.new()
    return template.configure(element, level)

## Create a breath attack template
static func create_breath_attack(element: EnemyTemplate.ElementAffinity, level: int) -> BreathAttackTemplate:
    var template := BreathAttackTemplate.new()
    return template.configure(element, level)

## Create a poison attack template
static func create_poison_attack(level: int) -> PoisonAttackTemplate:
    var template := PoisonAttackTemplate.new()
    return template.configure(level)

## Create a defend template
static func create_defend() -> DefendTemplate:
    return DefendTemplate.new()
