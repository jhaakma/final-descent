# To do

## Refactor CombatEntity/ATK and DEF bonuses
- Move get_total_defense_bonus etc to CombatEntity
- Allow potions etc to register an attack bonus
- Potions register bonus on use, then unregister on expiry
- get_total_defense_bonus etc directly sum from array of bonuses
- Merge CombatActor into CombatEntity

## Tidy ItemInstance
- Remove count, use only for item+data combo

## Permanent Conditions
- Like timed Status but with no time limit
- Used for permanent buffs and constant effect items

## Damage Types/Resistances
- Resistance = half damage from that type
- Update UI to show more info on enemies

## Player Abilities
- Make sure ability logs work with player
- Refactor CombatEneity/Enemy/EnemyResource to pull abilities list into CombatEntity
- Update combat UI to allow using new abilities
- Combat Manuals teach new abilities

## Enchantments
- Weapon has Enchantment slot
- Base Enchantment is blank
- OnStrike enchantment has on_attack_hit method
    - StatusOnStrikeEnchantment extends OnStrikeEnchantment
    - When attacking, check for OnStrike enchantments
    - Poison Dagger:
        - Weapon: Dagger
        - Enchantment: StatusOnStrikeEnchantment
            - Status: Poison
- ConstantEffect enchantment

## Theme
Create and use a consistent theme
Remove all unnecessary theme overrides

## Weapon degradation
- Random shrine event repairs items
- Blacksmith room to repair or even improve gear

## Combat Enhancements
- Status effects
    - Stun - skip next turn
    - Weakness - reduced damage

## Magic
- Scrolls for single use spells
- Books to learn spells, consumes mana
- Staves improve spell effectiveness
- Wands with limited spell use

## Managers
- Room Manager
    - Stores the list of room types
    - Holds logic for determining next room
    - Room difficulty increases as player descends
    - "Stages" - set of 10? rooms, with a boss at the end

## More Rooms
- Unsafe rest rooms
    - Like Mimics, the description can give it away
    - Chance to be attacked in your sleep

## Quest System
- Encounter a room with an NPC
- Accept a quest
- Unlocks new rooms with quest actions
- Completing quest unlocks room with NPC again to complete
- Example:
    HERMIT: I've lost my marbles, can you find them for me?
    - Accept
    New Room: Has combat with unique monster
        Defeating monster drops marbles
    New Room: HERMIT - "Thank you! Here's something for your trouble"
    - Reward: magic item

## Overarching Story
- Rooms with options to explore, find clues, unravel some sort of plot