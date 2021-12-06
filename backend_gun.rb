#!/usr/bin/env ruby

#? initial gun info
def get_gun()
    file_names = ["scope", "levels", "reload", "blast", "scope_detail1", "scope_detail2", "bullet", "numbers", "fire", "reload"]
    diff_cords = [[-859, -590], [0, -380], [-285, -16], [-32, -32]]
    
    #* array of all gun elements
    gun_info = Array.new
    for i in 0..7
        gun_info.push(Layer.new(file_names[i], 7))
        gun_info[i].current_x, gun_info[i].current_y = diff_cords[i][0], diff_cords[i][1] if i < 4
    end
    
    #* max bullets user will have at an instance
    gun_info[6].total = 5 
    
    #* rotation speed for details
    gun_info[4].angle = 1.75
    gun_info[5].angle = -1.5
    
    #* audio files
    i = 8; 2.times {gun_info.push(Audio_used.new(file_names[i], "wav")); i += 1}
    
    #* blast and reload pop-up wouldn't be seen by default
    gun_info[2].condition = gun_info[3].condition = false
    
    #* blast animation should start from frame 0
    gun_info[3].current_sprite_x = 0
    
    #* time information; how to display, where to display (cords)
    gun_info.push(get_time())
    
    return gun_info
end

#? time required for scope menu
def get_time()
    time_x_cords = [-28, 12, 32, -8]

    time_info = Array.new
    for i in 0..3
        time_number = Number_use.new(time_x_cords[i], -185, 40)
        time_number.current_sprite_x = 0
        time_info.push(time_number)
    end
    time_info[3].condition = true
    
    return time_info
end

#? to update time
def time_update(time, index)
    #* since draw function in Gosu Class is called 60 times in a second, every [index % 60 = 0] is a second
    #? game time will faster than IRL time
    if index % 25 == 0
        time[3].current_sprite_x = value_toggle(time[3].current_sprite_x)
    end

    if index % 50 == 0
        if time[2].current_sprite_x >= 360 
            time[2].current_sprite_x = 0
            if time[1].current_sprite_x >= 200 #max value to be 5
                time[1].current_sprite_x = 0
                if time[0].current_sprite_x >= 360
                    time[0].current_sprite_x = 0
                else
                    time[0].current_sprite_x += 40
                end
            else
                time[1].current_sprite_x += 40 
            end
        else
            time[2].current_sprite_x += 40
        end
    end
end

#? to draw time (one element of scope) 
def time_draw(numbers, cords, time, shoot)
    numbers.summon.subimage(400, 0, 40, 60).draw(cords[0] + time[3].current_x, cords[1] + shoot -190, 7, 0.5, 0.5) if time[3].current_sprite_x

    for i in 0...3
        numbers.summon.subimage(time[i].current_sprite_x, 0, 40, 60).draw(cords[0] + time[i].current_x, cords[1] + time[i].current_y + shoot, 7, 0.5, 0.5)
    end
end

#? draw bullet image the number of time stated in total.
def bullets_get(bullet, cords, shoot)
    #* player has 10 bullets in total. will have to reload the gun after shooting 5 times.
    for i in 0...bullet.total
        bullet.summon.draw(cords[0] + 15 + (i * 8), cords[1] + shoot+ 175, 7)
    end
end

#? action for what will happen when player shoots (left clicks)
def gun_fire(cords, gun, result)
    if gun[6].total <= 0
        gun[2].condition = true
    else
        gun[6].total -= 1
        gun[8].summon.play()
        gun[3].current_x, gun[3].current_y = cords[0]-32, cords[1]-32
        gun[3].current_sprite_x = 0
        gun[3].condition = true
        blast_thread = Thread.new{
            for i in 0..8
                animate(gun[3], 0, 640, 64)
                sleep(0.12)
            end
            gun[3].condition = false
        }
        result.ammo -= 1
    end
end

#? if all bullets have been shot then 5 more bullets will be given.
def gun_reload(gun)
    if gun[6].total == 0
        gun[2].condition = false
        gun[9].summon.play() #? will play gun feload sound
        gun[6].total = 5
    end
end

#? displays the score in gun menu
def draw_points(numbers, cords, points, shoot)
    if points == 10
        numbers.summon.subimage(0, 0, 40, 60).draw((cords[0] - 180), (cords[1] - 30 + shoot), 7, 0.7, 0.7)
        numbers.summon.subimage(40, 0, 40, 60).draw((cords[0] - 210), (cords[1] - 30 + shoot), 7, 0.7, 0.7)
    else
        numbers.summon.subimage((40 * points), 0, 40, 60).draw((cords[0] - 180), (cords[1] - 30 + shoot), 7, 0.7, 0.7)
    end
end

#? displays player health in gun menu
def draw_health(numbers, cords, health, shoot)
    if health == 10
        numbers.summon.subimage(40, 0, 40, 60).draw((cords[0] + 170), (cords[1] - 20 + shoot), 7, 0.5, 0.5)
        numbers.summon.subimage(0, 0, 40, 60).draw((cords[0] + 190), (cords[1] - 20 + shoot), 7, 0.5, 0.5)
        numbers.summon.subimage(0, 0, 40, 60).draw((cords[0] + 210), (cords[1] - 20 + shoot), 7, 0.5, 0.5)
    else
        health = (health * 10).to_s
        numbers.summon.subimage((40 * health[0].to_i), 0, 40, 60).draw((cords[0] + 170), (cords[1] - 20 + shoot), 7, 0.5, 0.5)
        numbers.summon.subimage((40 * health[1].to_i), 0, 40, 60).draw((cords[0] + 190), (cords[1] - 20 + shoot), 7, 0.5, 0.5)
    end
end

#? display the scope with all info in it
def draw_gun(gun, cords, shoot, points, player_health)
    gun[0].summon.draw((cords[0] + gun[0].current_x), (cords[1]+ gun[0].current_y + shoot), 7)
    gun[1].current_y = cords[1]/3          #? to animate level indicator at left of the screen
    loop_draw(gun, "y", 1, 1)              #? to animate level indicator at left of the screen
    
    time_draw(gun[7], cords, gun[10], shoot)
    bullets_get(gun[6], cords, shoot)

    draw_points(gun[7], cords, points, shoot)
    draw_health(gun[7], cords, player_health, shoot)

    for i in 4..5
        if i == 4 then side = 1 else side = -1; end
        gun[i].summon.draw_rot((cords[0]), (cords[1] + shoot), 7, (gun[i].angle * side))
        gun[i].angle += 1
    end
    
    gun[2].summon.draw(cords[0] -65, cords[1] + 185 + shoot, 7) if gun[2].condition
end
