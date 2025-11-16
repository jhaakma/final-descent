## stage_generator.gd
## Generates a StageInstance from a StageTemplateResource
class_name StageGenerator
extends Resource

## Public entry point
static func generate(_stage_number: int, template: StageTemplateResource, rng_seed: int) -> StageInstance:

    var rng := RandomNumberGenerator.new()
    rng.seed = rng_seed

    var planned_rooms: Array[RoomResource] = []

    #generate x rooms according to template
    for i in range(template.floors):
        var chosen_room_template: IRoomTemplate = template.room_templates.pick_random()
        var generated_room: RoomResource = chosen_room_template.generate_room(_stage_number)
        planned_rooms.append(generated_room)

    return StageInstance.new(template, _stage_number, rng_seed, planned_rooms)
