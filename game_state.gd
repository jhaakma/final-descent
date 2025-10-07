# GameState.gd
extends Node

signal stats_changed
signal inventory_changed
signal run_ended(victory: bool)
signal buffs_changed
signal death_fade_start  # Forwarded from player when death fade should start

var current_floor: int = 1
var player: Player
var rng: RandomNumberGenerator

func _ready() -> void:
    rng = RandomNumberGenerator.new()
    rng.randomize()

    # Initialize player
    player = Player.new()
    # Connect player signals to forward them
    player.stats_changed.connect(func(): emit_signal("stats_changed"))
    player.inventory_changed.connect(func(): emit_signal("inventory_changed"))
    player.buffs_changed.connect(func(): emit_signal("buffs_changed"))
    # Connect death signals
    player.death_fade_start.connect(func(): emit_signal("death_fade_start"))
    player.death_with_delay.connect(func(): emit_signal("run_ended", false))

func reset_run() -> void:
    current_floor = 1
    player.reset()
    # Clear log history when starting a new run
    LogManager.clear_log_history()

func has_gold(amount: int) -> bool:
    return player.has_gold(amount)

func add_gold(amount: int) -> void:
    player.add_gold(amount)

func add_item(item: Item) -> void:
    player.add_item(item)

func remove_item(item: Item) -> void:
    player.remove_item(item)

func remove_item_instance(item: Item, item_data) -> bool:
    return player.remove_item_instance(item, item_data)

func heal(amount: int) -> void:
    player.heal(amount)

func take_damage(amount: int) -> void:
    var defense_bonus = player.get_total_defense_bonus()
    var reduced_damage = player.take_damage(amount)

    if defense_bonus > 0:
        LogManager.log_damage("Defense reduced damage by %d! (Took %d damage)" % [amount - reduced_damage, reduced_damage])

func next_floor() -> void:
    current_floor += 1

    # Process both buffs and status effects when entering a new room
    player.process_buff_turns()

    # Process status effects and apply their effects
    var status_results = process_player_status_effects()

    for result in status_results:
        if result.message != "":
            LogManager.log_message("Room transition: %s" % result.message)

    # Death from status effects is now handled by Player.take_damage signal
    emit_signal("stats_changed")

# Add a new buff to the player
func add_buff(buff: Buff) -> void:
    player.add_buff(buff)

# Remove a specific buff
func remove_buff(buff: Buff) -> void:
    player.remove_buff(buff)

# Get total attack bonus from all active buffs
func get_total_attack_bonus() -> int:
    return player.get_total_attack_bonus()

# Get total defense bonus from all active buffs
func get_total_defense_bonus() -> int:
    return player.get_total_defense_bonus()

# Process buff turns and remove expired ones (called during combat)
func process_buff_turns() -> void:
    var expired_buffs = player.process_buff_turns()
    for buff in expired_buffs:
        LogManager.log_warning("Buff expired: %s" % buff.name)

func equip_weapon(weapon: ItemWeapon) -> void:
    var previous_weapon = player.equipped_weapon
    player.equip_weapon(weapon)

    if previous_weapon:
        LogManager.log_equipment("Unequipped weapon: %s" % previous_weapon.name)

    LogManager.log_equipment("Equipped weapon: %s" % weapon.name)

func unequip_weapon() -> void:
    if player.equipped_weapon:
        LogManager.log_equipment("Unequipped weapon: %s" % player.equipped_weapon.name)
        player.unequip_weapon()

# Status effects convenience access
func apply_status_effect_to_player(effect: StatusEffect) -> void:
    player.apply_status_effect(effect)

func player_has_status_effect(effect_name: String) -> bool:
    return player.has_status_effect(effect_name)

func process_player_status_effects() -> Array[StatusEffectResult]:
    return player.process_status_effects()

func get_player_status_effect_description(effect_name: String) -> String:
    return player.get_status_effect_description(effect_name)

func remove_player_status_effect(effect_name: String) -> void:
    player.remove_status_effect(effect_name)

func clear_all_player_status_effects() -> void:
    player.clear_all_status_effects()

func get_player_status_effects_description() -> String:
    return player.get_status_effects_description()

func get_player_status_effects() -> Array[StatusEffect]:
    return player.get_all_status_effects()
