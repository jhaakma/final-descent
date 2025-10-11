# To do

## Create AI component to override enemy AIs

## Fixes:
- Replace inventory function params with ItemStacks or ItemTiles
- Have condition affect buy price in addition to sell price

## Buff-Effect layer
- Need a wrapper around status effects for buffs, so they can have unique names, while sti

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
- Rooms with options to explore, find clues, unravel some sort of plote

## Difficulty Scaling
- Higher difficulty enemies, better items as you descend floors