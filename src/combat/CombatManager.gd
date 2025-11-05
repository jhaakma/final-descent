class_name CombatStateManager extends RefCounted
## Manages combat state transitions with clear round/turn semantics
## ROUND = Complete cycle where both player and enemy have acted
## TURN = Individual actor's action within a round

signal combat_started(context: CombatContext)
signal player_turn_started(context: CombatContext)
signal enemy_turn_started(context: CombatContext)
signal round_ended(context: CombatContext)
signal combat_ended(context: CombatContext, victory: bool)

enum State {
    COMBAT_START,
    PLAYER_TURN,
    ENEMY_TURN,
    ROUND_END,
    COMBAT_END
}

enum PlayerAction {
    ATTACK,
    DEFEND,
    FLEE,
    ITEM_USE,
    SKIP_TURN
}

var current_state: State = State.COMBAT_START
var context: CombatContext
var round_number: int = 1
var turns_this_round: int = 0  # Track how many actors have acted this round

func _init(combat_context: CombatContext) -> void:
    context = combat_context

func start_combat() -> void:
    current_state = State.COMBAT_START
    round_number = 1
    turns_this_round = 0
    combat_started.emit(context)

    # Process ROUND_START effects for new round
    _process_round_start_effects()

    # Determine who goes first
    if context.enemy_first:
        transition_to_enemy_turn()
    else:
        transition_to_player_turn()

func transition_to_player_turn() -> void:


    if _can_transition_to(State.PLAYER_TURN):
        current_state = State.PLAYER_TURN

        player_turn_started.emit(context)

func transition_to_enemy_turn() -> void:
    if _can_transition_to(State.ENEMY_TURN):
        current_state = State.ENEMY_TURN

        # Process TURN_START effects for the enemy immediately
        # (No UI delay for enemies - they act immediately)


        enemy_turn_started.emit(context)

func end_current_turn() -> void:
    """Call this when an actor has finished their turn"""
    turns_this_round += 1
    print("DEBUG: Turn ended, turns_this_round = ", turns_this_round)

    # Check for combat end first
    if _check_combat_end_conditions():
        return


    # If both actors have acted this round, end the round
    if turns_this_round >= 2:
        print("DEBUG: Round complete, transitioning to round end")
        transition_to_round_end()
    else:
        # Continue to next actor's turn
        if context.enemy.should_skip_turn():
            # Enemy skips, count as their turn and potentially end round
            turns_this_round += 1
            if turns_this_round >= 2:
                transition_to_round_end()
            else:
                # This shouldn't happen in a 2-actor system
                transition_to_player_turn()
        else:
            transition_to_enemy_turn()

func transition_to_round_end() -> void:
    if _can_transition_to(State.ROUND_END):
        current_state = State.ROUND_END

        # Process ROUND_END status effects once per round
        _process_round_end_effects()

        round_ended.emit(context)

        # Check for combat end, otherwise start next round
        if not _check_combat_end_conditions():
            _start_next_round()

func _start_next_round() -> void:
    """Start a new round after the previous one has ended"""
    round_number += 1
    turns_this_round = 0
    context.increment_turn()  # This tracks overall game turns

    # Process ROUND_START effects for new round
    _process_round_start_effects()

    # Determine who goes first this round (could add initiative system here)
    if context.enemy_first:
        transition_to_enemy_turn()
    else:
        transition_to_player_turn()



func _process_turn_start_effects(actor: CombatEntity) -> void:
    """Process effects that trigger at the start of an individual actor's turn"""
    if actor.is_alive():
        actor.process_status_effects_at_timing(EffectTiming.Type.TURN_START, round_number)

func _process_round_start_effects() -> void:
    """Process effects that trigger at the start of each round"""
    if context.player.is_alive():
        context.player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, round_number)
    if context.enemy.is_alive():
        context.enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, round_number)

func _process_round_end_effects() -> void:
    """Process effects that trigger at the end of each round (like poison damage)"""
    print("DEBUG: Processing round end effects for round ", round_number)
    if context.player.is_alive():
        print("DEBUG: Processing player ROUND_END effects")
        context.player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, round_number)
    if context.enemy.is_alive():
        print("DEBUG: Processing enemy ROUND_END effects")
        context.enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, round_number)

func end_combat(victory: bool) -> void:
    print("DEBUG: Combat ending - processing any remaining ROUND_END effects")

    # Process any remaining ROUND_END effects before combat ends
    if context.player.is_alive():
        print("DEBUG: Processing player final ROUND_END effects")
        context.player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, round_number)

    if context.enemy.is_alive():
        print("DEBUG: Processing enemy final ROUND_END effects")
        context.enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, round_number)

    current_state = State.COMBAT_END
    context.end_combat()

    # Trigger UI update via event bus after processing combat end effects
    UIEvents.player_stats_changed.emit()

    combat_ended.emit(context, victory)

func get_current_state() -> State:
    return current_state

func get_current_round() -> int:
    return round_number

func _can_transition_to(new_state: State) -> bool:
    # Validate state transitions
    match current_state:
        State.COMBAT_START:
            return new_state in [State.PLAYER_TURN, State.ENEMY_TURN]
        State.PLAYER_TURN:
            return new_state in [State.ENEMY_TURN, State.ROUND_END, State.COMBAT_END]
        State.ENEMY_TURN:
            return new_state in [State.PLAYER_TURN, State.ROUND_END, State.COMBAT_END]
        State.ROUND_END:
            return new_state in [State.PLAYER_TURN, State.ENEMY_TURN, State.COMBAT_END]
        State.COMBAT_END:
            return false  # Terminal state
    return false

func _check_combat_end_conditions() -> bool:
    if context.is_combat_over():
        var victory: bool = context.get_combat_winner() == "player"
        end_combat(victory)
        return true
    return false

## Execute player action and return the result
func execute_player_action(action: PlayerAction) -> ActionResult:
    # Process TURN_START effects when player clicks action, not when buttons are enabled
    # This gives player time to see their status effects before they expire
    _process_turn_start_effects(context.player)
    _process_turn_start_effects(context.enemy)

    var result: ActionResult

    match action:
        PlayerAction.ATTACK:
            result = _execute_attack()
        PlayerAction.DEFEND:
            result = _execute_defend()
        PlayerAction.FLEE:
            result = _execute_flee()
        PlayerAction.ITEM_USE:
            result = _execute_item_use()
        PlayerAction.SKIP_TURN:
            result = ActionResult.create_skip_turn()
        _:
            result = ActionResult.new()  # Default fallback

    return result

func _execute_attack() -> ActionResult:
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

func _execute_defend() -> ActionResult:
    # Use the shared defend ability for consistency
    var defend_ability := DefendAbility.new()
    var instance := AbilityInstance.new(defend_ability)
    instance.execute(context.player)

    return ActionResult.create_defend_result()

func _execute_flee() -> ActionResult:
    var success: bool = randf() < context.enemy_resource.avoid_chance

    if success:
        LogManager.log_event("{You} flee successfully!", {"target": context.player})
        return ActionResult.create_flee_success()
    else:
        LogManager.log_event("{You} fail to flee!", {"target": context.player})
        return ActionResult.create_flee_failure()

func _execute_item_use() -> ActionResult:
    # Item usage is handled externally (through inventory system)
    # This action type just confirms that the player's turn was consumed
    # The actual item effect has already been applied when this is called
    return ActionResult.create_item_use_result()
