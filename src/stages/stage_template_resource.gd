## stage_template_resource.gd
## Minimal StageTemplateResource for Phase 1 stage generation
class_name StageTemplateResource
extends Resource

@export var floors: int = 10                                                 ## total rooms including boss

"""

    Stage 1:
        Name: Hinterlands
        Enemies: Goblin Scounts, bandits
        Rooms:
            Combat:
                - Bandit Camp
                - Goblin Ambush (Name: "Suspicious Clearing")
            Shop:
                - Traveling Merchant
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