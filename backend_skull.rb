#!/usr/bin/env ruby

#? initial skull info
def get_skull()
    skull = Layer.new("fire-skull", 4)
    skull.velocity = 5
    skull.current_x = 900
    skull.current_y = 300
    skull.gravity = 1
    skull.current_sprite_x = 0
    skull.total = 10
    return skull
end

#? constant increment in skull's location and animation
def skull_constant_update(skull, index)
    if skull.total > 0
        animate(skull, 0, 768, 96) if index % 6 == 0 #* making animation slow
        skull.current_x += skull.velocity
        skull.current_y += skull.gravity
        skull.velocity *= -1 unless (-50..1040).include?(skull.current_x)
        skull.gravity *= -1 unless (20..300).include?(skull.current_y)
    end
end

#? backend for actions when a skull is shot
def kill_skull(skull, gun_cords, result, player)
    if (skull.current_x..skull.current_x+96).include?(gun_cords[0]) && (skull.current_y..skull.current_y+112).include?(gun_cords[1])
        skull_should_be = skull.total - 1
        skull.total = 0
        skull.velocity += 2 #* each skull would be faster than the previous
        new_skull = Thread.new{
            sleep(rand(10))
            skull.total = skull_should_be
        }
        result.points += 1
    end
end

#? draw the skull 
def draw_skull(skull)
    skull.summon.subimage(skull.current_sprite_x, 0,  96, 112).draw(skull.current_x, skull.current_y, 4) if skull.total > 0
end
