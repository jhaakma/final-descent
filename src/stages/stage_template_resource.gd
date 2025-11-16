## stage_template_resource.gd
## Minimal StageTemplateResource for Phase 1 stage generation
class_name StageTemplateResource
extends Resource

## Number of floors in this stage
@export var floors: int = 10
## Available room templates for this stage
@export var room_templates: Array[IRoomTemplate] = []

@export var color: Color = Color.html("#FFFFFF")  ## Theme color for the stage
"""

    Stage 1:
        Name: Hinterlands
        Rooms:
            Loot:
                - Hidden Stash
                - Unlocked Chest
            Combat:
                - Bandit Camp
                - Goblin Ambush (Name: "Unlocked Chest")
            Shop:
                - Traveling Merchant
            Blacksmith:
                - Wandering Smithy
            Rest:
                - Peaceful Glade
            Shrine:
                - Forgotten Shrine
        Boss: Goblin Chief
        Theme: Green

    Stage 2:
        Name: Abandoned Village
        Enemies: Undead, Skeletons
        Rooms:

"""