#!/usr/bin/env ruby

#? all the images used for background layers
def get_backgrounds()
    z_values = [0, 0, 1, 1, 1, 1, 1, 2, 2, 3, 6]
    velocities = [2, 0, 1.5, 2, 2.4, 3, 3.5, 5, 3.5, 5.5, 7]
    file_names = ["Time", "Orb", 'Rocks', "Landscape", "BackTrees", "BackFrontTrees", "BackFrontDetails", "CloudSingle", "CloudsGroup", "Ground", "FrontDetails"]
    bg_info = Array.new
    for i in 0..10
        bg = Layer.new(file_names[i], z_values[i])
        bg.current_x = bg.current_y = 0 
        bg.velocity = velocities[i]
        bg_info.push(bg)
    end
    bg_info[9].condition = [true, true] #left, right
    return bg_info
end

#? background elements that must update irrespective of user's actions.
def bg_constant_update(bg)
    #* clouds moving at different velocity against x-axis
    for i in [7, 8]
        bg[i].current_x -= bg[i].velocity
    end
    #* day/night image moving against y-axis
    bg[0].current_y -= bg[0].velocity
end

#? background layers moving with player's actions
def bg_move(bg, direction)
    for i in [2, 3, 4, 5, 6, 9, 10]
        #* the 3 conditions for the increment to happen are-
        #* 1) if the command is either right or left(1 or -1)
        #* 2) the map isn't at the very start(for right movement) and at the very end(for left movement)
        #* 3) the condition argument is false only when there is a pillar infront the player
        bg[i].current_x += bg[i].velocity if direction < 0 && bg[9].current_x < 0 && bg[9].condition[0]
        bg[i].current_x -= bg[i].velocity if direction > 0 && bg[9].current_x > -5385 && bg[9].condition[1]
    end
end
