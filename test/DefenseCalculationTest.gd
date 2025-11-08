class_name DefenseCalculationTest extends BaseTest

var player: Player
var enemy: Enemy

func setup() -> void:
    player = Player.new()

    # Create a basic enemy with enemy resource
    var enemy_resource := EnemyResource.new()
    enemy_resource.name = "Test Enemy"
    enemy_resource.max_hp = 20
    enemy_resource.attack = 8
    enemy_resource.defense = 0
    enemy = Enemy.new(enemy_resource)

func teardown() -> void:
    player = null
    enemy = null

# Test that defense percentage is applied correctly (not twice)
func test_defense_percentage_single_application() -> bool:
    # Set up player with 10% base defense
    player.stats_component.defense = 10

    # Apply defend effect (+50% defense)
    var defend_effect := DefendEffect.new(50)
    player.apply_status_effect(defend_effect)

    # Verify total defense is 60%
    assert_equals(player.get_total_defense(), 60, "Total defense should be 60%")

    # Calculate incoming damage: 8 damage * (1 - 0.6) = 8 * 0.4 = 3.2 -> 3 (floor)
    var calculated_damage := player.calculate_incoming_damage(8)
    assert_equals(calculated_damage, 3, "Calculated damage should be 3 (8 * 0.4 = 3.2 -> floor to 3)")

    # Take the calculated damage - should NOT apply defense again
    var initial_hp := player.get_current_hp()
    player.take_damage(calculated_damage)
    var hp_after := player.get_current_hp()
    var actual_damage := initial_hp - hp_after

    assert_equals(actual_damage, 3, "Actual damage taken should be 3 (defense not applied twice)")

    return true

# Test enemy attack through AttackAbility
func test_enemy_attack_with_defense() -> bool:
    # Set up player with 10% base defense
    player.stats_component.defense = 10    # Apply defend effect (+50% defense)
    var defend_effect := DefendEffect.new(50)
    player.apply_status_effect(defend_effect)

    # Create attack ability for enemy
    var attack_ability := AttackAbility.new()
    attack_ability.base_damage = 0  # Will use enemy's attack power (8)
    attack_ability.damage_variance = 0  # No variance for predictable test

    var ability_instance := AbilityInstance.new(attack_ability)

    var initial_hp := player.get_current_hp()

    # Execute attack
    attack_ability.execute(ability_instance, enemy, player)

    var hp_after := player.get_current_hp()
    var actual_damage := initial_hp - hp_after

    # Expected: 8 * (1 - 0.6) = 3.2 -> floor to 3
    assert_equals(actual_damage, 3, "Player should take 3 damage from enemy attack with 60% defense")

    return true

# Test with different defense values
func test_various_defense_percentages() -> bool:
    var test_cases := [
        {"defense": 0, "incoming": 10, "expected": 10},  # No defense
        {"defense": 25, "incoming": 10, "expected": 7},  # 25% defense: 10 * 0.75 = 7.5 -> floor to 7
        {"defense": 50, "incoming": 10, "expected": 5},  # 50% defense: 10 * 0.5 = 5
        {"defense": 75, "incoming": 8, "expected": 2},   # 75% defense: 8 * 0.25 = 2
        {"defense": 90, "incoming": 20, "expected": 2},  # 90% defense: 20 * 0.1 = 2
        {"defense": 95, "incoming": 100, "expected": 5}, # 95% defense (capped): 100 * 0.05 = 5
    ]

    for test_case: Dictionary in test_cases:
        var test_player := Player.new()
        test_player.stats_component.defense = test_case["defense"]

        var damage := test_player.calculate_incoming_damage(test_case["incoming"])

        assert_equals(
            damage,
            test_case["expected"],
            "Defense %d%% with %d damage should result in %d (got %d)" % [
                test_case["defense"],
                test_case["incoming"],
                test_case["expected"],
                damage
            ]
        )

    return true