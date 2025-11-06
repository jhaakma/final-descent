# To do

## Blacksmith and Equipment Modifications

### Blacksmith Room
Offers the folowing services:
- Repair equipment - fee based on durability recovered
- Upgrade equipment - Add a random modifier to a piece of equipment for a fee

### Weapon and Armor Modifiers
- Adds prefix such as "Refined", "Sharpened" etc
- Modifiers have restrictions based on item and damage type, e.g:
    - "Reinforced" can only be applied to armor
    - "Sharpened" can only be applied to slashing and piercing weapons
- Blacksmith can apply a random modifier to existing equipment for a fee
- Piece of equipment can only have one modifier applied




## Automate Itch.io releases




## Ability Mechanics
- AI for selecting abilities
    - Logic + randomness

## Game Feel
- Short delay after player and enemy action
- Popup windows have fade in, particle effects etc
- Menu sound effects- install bjxr


## Status Effect stacking issues
- Still needs work, for example, poison from a spell and poison from a weapon aren't stacking
- Status effects probably need a can_stack

## Managers
- Room Manager
    - Stores the list of room types
    - Holds logic for determining next room
    - Room difficulty increases as player descends
    - "Stages" - set of 10? rooms, with a boss at the end

## Difficulty System
- A mechanic for determining and validating difficulty rating of encounters
- Prerequisites:
    - Room Manager
    - CombatEntity refactor

## Theme
Create and use a consistent theme
Remove all unnecessary theme overrides


## Combat Enhancements
- Status effects
    - Stun - skip next turn
    - Weakness - reduced damage

## Magic
- Books to learn spells, consumes mana
- Staves improve spell effectiveness
- Wands with limited spell use

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