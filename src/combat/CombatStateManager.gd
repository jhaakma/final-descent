class_name CombatStateManager extends RefCounted
## Manages combat state transitions with clear round/turn semantics
## ROUND = Complete cycle where both player and enemy have acted
## TURN = Individual actor's action within a round

signal combat_started(context: CombatContext)
signal player_turn_started(context: CombatContext)
signal enemy_turn_started(context: CombatContext)
signal round_ended(context: CombatContext)
signal combat_ended(context: CombatContext, victory: bool)


enum PlayerAction {
    ATTACK,
    DEFEND,
    FLEE,
    ITEM_USE,
    SKIP_TURN
}

var context: CombatContext
var round_number: int = 1

func _init(combat_context: CombatContext) -> void:
    context = combat_context

func start_combat() -> void:
    round_number = 1
    combat_started.emit(context)

    # Process ROUND_START effects for new round
    _process_round_start_effects()

    # Always start with player turn - they just skip if they failed to avoid
    transition_to_player_turn()

func transition_to_player_turn() -> void:
    player_turn_started.emit(context)

func transition_to_enemy_turn() -> void:
    enemy_turn_started.emit(context)

func end_player_turn() -> void:
    """Call this when the player has finished their turn"""
    # Check for combat end first
    if _check_combat_end_conditions():
        return
    transition_to_enemy_turn()

func end_enemy_turn() -> void:
    """Call this when the enemy has finished their turn"""
    # Check for combat end first
    if _check_combat_end_conditions():
        return
    transition_to_round_end()


func transition_to_round_end() -> void:
    # Process ROUND_END status effects once per round
    _process_round_end_effects()

    round_ended.emit(context)

    # Check for combat end, otherwise start next round
    if not _check_combat_end_conditions():
        _start_next_round()

func _start_next_round() -> void:
    """Start a new round after the previous one has ended"""
    round_number += 1
    context.increment_turn()  # This tracks overall game turns

    # Process ROUND_START effects for new round
    _process_round_start_effects()

    # Always start with player turn (they can skip if needed)
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

    context.end_combat()

    # Trigger UI update via event bus after processing combat end effects
    UIEvents.player_stats_changed.emit()

    combat_ended.emit(context, victory)


func get_current_round() -> int:
    return round_number


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

    var result: ActionResult

    match action:
        PlayerAction.ATTACK:
            result = PlayerActionExecutor.execute_attack(context)
        PlayerAction.DEFEND:
            result = PlayerActionExecutor.execute_defend(context)
        PlayerAction.FLEE:
            result = PlayerActionExecutor.execute_flee(context)
        PlayerAction.ITEM_USE:
            result = PlayerActionExecutor.execute_item_use(context)
        PlayerAction.SKIP_TURN:
            result = ActionResult.create_skip_turn()
        _:
            result = ActionResult.new()  # Default fallback


    _process_turn_start_effects(context.enemy)
    return result
