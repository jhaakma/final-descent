class_name InlineCombat extends InlineContentBase
## Displays combat interface directly in the room container
## Uses simplified combat system with CombatStateManager and CombatUI

signal combat_resolved(victory: bool)
signal combat_fled()
signal loot_collected()
signal turn_ended()

# Preload the CombatUI class
const CombatUIClass = preload("res://src/combat/ui/CombatUI.gd")

@onready var label: Label = %EnemyLabel
@onready var resistance_label: RichTextLabel = %EnemyResistances
@onready var weakness_label: RichTextLabel = %EnemyWeaknesses
@onready var stats_label: RichTextLabel = %EnemyStats
@onready var you_bar: ProgressBar = %PlayerHP
@onready var foe_bar: ProgressBar = %EnemyHP
@onready var attack_btn: Button = %AttackBtn
@onready var defend_btn: Button = %DefendBtn
@onready var flee_btn: Button = %FleeBtn

# Combat system components
var combat_context: CombatContext
var state_manager: CombatStateManager
var combat_ui: CombatUIClass

var enemy_resource: EnemyResource
var enemy_first: bool = false
var avoid_failure: bool = false

static func get_scene() -> PackedScene:
    return load("uid://jne75qvyltc6") as PackedScene  # Will need to create this scene

func set_enemy(enemy_res: EnemyResource) -> void:
    enemy_resource = enemy_res
    # Initialize combat if we're ready
    if is_inside_tree():
        _initialize_combat()

func set_enemy_first(value: bool) -> void:
    enemy_first = value

func set_avoid_failure(value: bool) -> void:
    avoid_failure = value

func _ready() -> void:
    # Initialize combat if enemy resource is already set
    if enemy_resource:
        _initialize_combat()

func _initialize_combat() -> void:
    if not enemy_resource:
        return

    # Wait for nodes to be ready if needed
    if not label:
        await ready

    # Create new SOLID combat system components
    var current_enemy := Enemy.new(enemy_resource)
    combat_context = CombatContext.new(GameState.player, current_enemy, enemy_resource)
    combat_context.enemy_first = enemy_first

    # Initialize state manager
    state_manager = CombatStateManager.new(combat_context)

    # Initialize UI component
    combat_ui = CombatUIClass.new()
    _setup_combat_ui()

    # Connect state manager signals
    _connect_state_manager_signals()

    # Register combat state with GameState
    GameState.start_combat(current_enemy)

    LogManager.log_event("Encounter: {enemy:%s} (HP %d)" % [current_enemy.get_name(), current_enemy.get_max_hp()])

    # Initialize combat display
    combat_ui.initialize_combat_display(combat_context)

    # Handle enemy first mechanics
    if enemy_first:
        _handle_enemy_first_attack()
    else:
        # Start normal combat
        state_manager.start_combat()

func _setup_combat_ui() -> void:
    # Set up UI references for CombatUI component
    var ui_refs := {
        "label": label,
        "resistance_label": resistance_label,
        "weakness_label": weakness_label,
        "stats_label": stats_label,
        "you_bar": you_bar,
        "foe_bar": foe_bar,
        "attack_btn": attack_btn,
        "defend_btn": defend_btn,
        "flee_btn": flee_btn
    }
    combat_ui.setup_ui_references(ui_refs)

    # Connect UI signals to our handlers
    combat_ui.attack_requested.connect(_on_attack)
    combat_ui.defend_requested.connect(_on_defend)
    combat_ui.flee_requested.connect(_on_flee)

func _connect_state_manager_signals() -> void:
    state_manager.combat_started.connect(_on_combat_started)
    state_manager.player_turn_started.connect(_on_player_turn_started)
    state_manager.enemy_turn_started.connect(_on_enemy_turn_started)
    state_manager.round_ended.connect(_on_round_ended)
    state_manager.combat_ended.connect(_on_combat_ended)

func _handle_enemy_first_attack() -> void:
    # Disable buttons during the surprise attack
    combat_ui.disable_actions()

    if avoid_failure:
        LogManager.log_event("{You} fail to avoid!", {"target": GameState.player})
        LogManager.log_event("The {enemy:%s} strikes first!" % combat_context.enemy.get_name())
    else:
        LogManager.log_event("The {enemy:%s} strikes first!" % combat_context.enemy.get_name())

    # Add a small delay before the enemy attack
    get_tree().create_timer(0.5).timeout.connect(func()->void:
        # Start combat with enemy turn
        state_manager.start_combat()
    )

# Signal handlers for state manager
func _on_combat_started(_context: CombatContext) -> void:
    # Combat has started, UI is already initialized
    pass

func _on_player_turn_started(_context: CombatContext) -> void:
    # Enable player actions and update UI
    combat_ui.update_display()
    combat_ui.enable_actions()

func _on_enemy_turn_started(_context: CombatContext) -> void:
    # Disable player actions, update UI, and process enemy turn
    combat_ui.update_display()
    combat_ui.disable_actions()
    _process_enemy_turn()

func _on_round_ended(_context: CombatContext) -> void:
    # Round has ended, update UI and emit signal for room updates
    combat_ui.update_display()
    turn_ended.emit()

func _on_combat_ended(_context: CombatContext, victory: bool) -> void:
    # Combat is over
    # Note: CombatManager already emits UIEvents.player_stats_changed after processing
    # combat end effects, so UI will update automatically via event bus
    combat_resolved.emit(victory)
    if not victory:
        content_resolved.emit()

func _process_enemy_turn() -> void:
    # Check if enemy should skip their turn
    if combat_context.enemy.should_skip_turn():
        LogManager.log_event("{enemy:%s} is stunned and skips their turn!" % combat_context.enemy.get_name())
        # End enemy's turn (will be handled by the round system)
        state_manager.end_current_turn()
        return

    # Process enemy status effects at start of their turn
    # Note: Status effects are now processed by CombatStateManager at proper timing phases

    if combat_context.enemy.is_alive():
        # Execute enemy action
        combat_context.enemy.perform_action()
        # End enemy's turn
        state_manager.end_current_turn()

# Combat action handlers (called by CombatUI)
func _on_attack() -> void:
    var result := state_manager.execute_player_action(CombatStateManager.PlayerAction.ATTACK)
    _handle_action_result(result)

func _on_defend() -> void:
    var result := state_manager.execute_player_action(CombatStateManager.PlayerAction.DEFEND)
    _handle_action_result(result)

func _on_flee() -> void:
    var result := state_manager.execute_player_action(CombatStateManager.PlayerAction.FLEE)
    _handle_action_result(result)

func _handle_action_result(result: ActionResult) -> void:
    match result.action_type:
        ActionResult.ActionType.FLEE when result.combat_fled:
            combat_fled.emit()
            content_resolved.emit()
        _:
            # For all other actions, continue to turn end
            state_manager.end_current_turn()

func handle_item_used() -> void:
    """Handle when an item is used during combat - treat as player action"""
    # Process the item usage as a player action (consumes the turn)
    var result := state_manager.execute_player_action(CombatStateManager.PlayerAction.ITEM_USE)
    _handle_action_result(result)

func show_content() -> void:
    super.show_content()
    # UI will be updated by state changes

func cleanup() -> void:
    super.cleanup()
    # Clean up combat state when combat is destroyed
    GameState.end_combat()

func show_loot_screen(loot_data: LootComponent.LootResult) -> void:
    # Replace combat content with loot content
    if room_screen:
        var inline_loot := (load("res://src/ui/components/InlineLoot.tscn") as PackedScene).instantiate() as InlineLoot
        inline_loot.show_loot(loot_data, "You search the remains and find:")

        # Replace current content with loot content
        room_screen.show_inline_content(inline_loot)

        # Connect loot collected signal
        inline_loot.loot_collected.connect(func()->void:
            loot_collected.emit()
        )
