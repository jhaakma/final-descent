# To do

## Quest System
- Stages no longer have set nunmber of rooms
- Continue to generate rooms until quset objectives are met
- Common quest layout:
    - Discovery: Find a mystery to solve
    - Investigation: Find clues that point to a specific objective
    - Objective: Find an item, kill an enemy etc
    - Resolution: Final room is unlocked

## Automate Itch.io releases
- https://learn-monogame.github.io/how-to/automate-release/

### Considerations
How to balance the progression, prevent the player from deliberately avoiding the quest to farm rooms for loot/gold
- Increase enemy difficulty without increasing loot/gold rewards as player spends time in a given stage?
- Make completing the quest unavoidable, unable to skip rooms that are part of the quest

## Stage Enhancements
- Theme:
    - Initially, stage has color the UI background is set to
    - Later, stage can have its own music, effects etc
- Storyline
    - Mandatory, custom rooms at a specific floor


## LootPick generation
May not be a bug, but something to keep an eye out for:
- LootPicks are generated using the current_floor, so we need to make sure resolved_items is being called lazily when the player encounters the chest. Otherwise we will need to hook it into the room generation and pass the stage there



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