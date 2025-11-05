class_name PlayerActionExecutor extends RefCounted
## Executes player combat actions (attack, defend, flee)
## Separates "what happens" from "when it happens" (state management)

## Execute a player attack action
static func execute_attack(context: CombatContext) -> ActionResult:
	var total_dmg: int = context.player.get_total_attack_power()
	var player_damage_type: DamageType.Type = context.player.get_attack_damage_type()
	var final_damage: int = context.enemy.calculate_incoming_damage(total_dmg, player_damage_type)
	context.enemy.take_damage(final_damage)

	var weapon_instance := context.player.get_equipped_weapon_instance()
	var weapon_name: String = weapon_instance.item.name if weapon_instance else ""

	# Log the attack
	if weapon_name != "":
		LogManager.log_event("{You} {action} {enemy:%s} with %s for {damage:%d}!" % [context.enemy.get_name(), weapon_name, final_damage], {"target": context.player, "damage_type": player_damage_type, "action": ["strike", "strikes"]})
	else:
		LogManager.log_event("{You} {action} {enemy:%s} for {damage:%d}!" % [context.enemy.get_name(), final_damage], {"target": context.player, "damage_type": player_damage_type, "action": ["attack", "attacks"]})

	if weapon_instance:
		# Check if weapon has special attack effects
		var weapon := weapon_instance.item as Weapon
		weapon.on_attack_hit(context.enemy)

	# Reduce weapon condition after logging the attack
	context.player.reduce_weapon_condition()

	return ActionResult.create_attack_result(final_damage)

## Execute a player defend action
static func execute_defend(context: CombatContext) -> ActionResult:
	# Use the shared defend ability for consistency
	var defend_ability := DefendAbility.new()
	var instance := AbilityInstance.new(defend_ability)
	instance.execute(context.player)

	return ActionResult.create_defend_result()

## Execute a player flee action
static func execute_flee(context: CombatContext) -> ActionResult:
	var success: bool = randf() < context.enemy_resource.avoid_chance

	if success:
		LogManager.log_event("{You} flee successfully!", {"target": context.player})
		return ActionResult.create_flee_success()
	else:
		LogManager.log_event("{You} fail to flee!", {"target": context.player})
		return ActionResult.create_flee_failure()

## Execute item use action
static func execute_item_use(_context: CombatContext) -> ActionResult:
	# Item usage is handled externally (through inventory system)
	# This action type just confirms that the player's turn was consumed
	# The actual item effect has already been applied when this is called
	return ActionResult.create_item_use_result()
