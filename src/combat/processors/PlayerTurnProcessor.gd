class_name PlayerTurnProcessor extends TurnProcessor
## Handles player turn logic: attack, defend, flee actions
## Extracted from InlineCombat to follow single responsibility principle

enum PlayerAction {
    ATTACK,
    DEFEND,
    FLEE,
    ITEM_USE
}

## Process player action and return the result
func execute_action(action: PlayerAction, context: CombatContext) -> ActionResult:
    # Process player status effects at start of turn
    _process_start_of_player_turn_effects(context)

    var result: ActionResult

    match action:
        PlayerAction.ATTACK:
            result = _execute_attack(context)
        PlayerAction.DEFEND:
            result = _execute_defend(context)
        PlayerAction.FLEE:
            result = _execute_flee(context)
        PlayerAction.ITEM_USE:
            result = _execute_item_use(context)
        _:
            result = ActionResult.new()  # Default fallback

    # Emit action result for UI updates
    turn_action_executed.emit(result)

    return result

func _execute_attack(context: CombatContext) -> ActionResult:
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

func _execute_defend(context: CombatContext) -> ActionResult:
    # Use the shared defend ability for consistency
    var defend_ability := DefendAbility.new()
    var instance := AbilityInstance.new(defend_ability)
    instance.execute(context.player)

    return ActionResult.create_defend_result()

func _execute_flee(context: CombatContext) -> ActionResult:
    var success: bool = randf() < context.enemy_resource.avoid_chance

    if success:
        LogManager.log_event("{You} flee successfully!", {"target": context.player})
        return ActionResult.create_flee_success()
    else:
        LogManager.log_event("{You} fail to flee!", {"target": context.player})
        return ActionResult.create_flee_failure()

func _execute_item_use(_context: CombatContext) -> ActionResult:
    # Item usage is handled externally (through inventory system)
    # This action type just confirms that the player's turn was consumed
    # The actual item effect has already been applied when this is called
    return ActionResult.create_item_use_result()

func _process_start_of_player_turn_effects(_context: CombatContext) -> void:
    # Process player status effects at the START of their turn
    # This ensures effects remain visible throughout the enemy turn
    # Note: Status effects are now processed by CombatStateManager at proper timing phases
    pass

## Override base class method - players can always process their turn
func can_process_turn(context: CombatContext) -> bool:
    return context.is_player_alive() and not context.player.should_skip_turn()

## Not needed for player turns as they're immediate
func process_turn(_context: CombatContext) -> void:
    # Player turns are handled via execute_action calls from UI
    # This method exists to satisfy the base class interface
    pass
