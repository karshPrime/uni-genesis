#!/usr/bin/env ruby

#? initial pet info
def get_pet()
    pet = Layer.new("Pet", 4)
    pet.velocity = 1
    pet.current_x = 120
    pet.current_y = 515
    pet.gravity = 1.2
    return pet
end

#? constant increment in pet's y-cord to make it "bounce"
def pet_bounce(pet, gravity_switch, player)
    if gravity_switch then pet.current_y += pet.velocity else pet.current_y -= pet.velocity; end
    
    pet.velocity = -1 if pet.velocity.round == 0 #crest of bounce
    pet.velocity *= pet.gravity if pet.velocity < 0  #falling
    pet.velocity /= pet.gravity if pet.velocity > 0  #rising
    
    if gravity_switch
        if pet.current_y < player.current_y - 35 #floor
            pet.current_y = player.current_y - 35
            pet.velocity = 10
        end
    else
        if pet.current_y > player.current_y + 35 #floor
            pet.current_y = player.current_y + 35
            pet.velocity = 10
        end
    end
end

#? having the pet always 30px behind the player
def pet_constant_update(pet, player, direction, gravity_switch)
    pet.current_x = player.current_x - (direction * 30)
    pet_bounce(pet, gravity_switch, player)
end
