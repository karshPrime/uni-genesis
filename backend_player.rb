#!/usr/bin/env ruby

#? initial player info
def get_player()
    wav_audio_name = ["fall", "teleport", "hurt"]
    
    player_character = Layer.new("player", 4)
    player_character.current_sprite_x = 0
    player_character.health = 10
    player_character.velocity = 0.25
    player_character.current_x = 150
    player_character.current_y = 590
    player_character.gravity = 10
    
    player_blood = Layer.new("blood", 4)
    player_blood.condition = false  #* by default blood wont be on screen

    player_info = Array.new

    player_info.push(player_character)
    player_info.push(Audio_used.new("run", "ogg"))
    for i in 0..2
        player_info.push(Audio_used.new(wav_audio_name[i], "wav"))
    end
    player_info.push(player_blood)

    return player_info
end

#? player right-left player movement
def player_move(player, direction)
    animate(player, 1700, 3400, 85)
    player.current_x += direction * player.velocity
    player.current_x = 888 if player.current_x > 888
    player.current_x = 80 if player.current_x < 80
end

#? restrict the player from walking over the pillars
def player_pillars(player, bg)
    if ((945 + bg.current_x)..(1000 + bg.current_x)).include?(player.current_x)
        player.current_x = 950 + bg.current_x
        bg.condition[1] = false
    elsif ((3765 + bg.current_x)..(3800 + bg.current_x)).include?(player.current_x)
        player.current_x = 3770 + bg.current_x
        bg.condition[1] = false
    else
        bg.condition[1] = true
    end
    if ((1006 + bg.current_x)..(1100 + bg.current_x)).include?(player.current_x)
        player.current_x = 1100 + bg.current_x
        bg.condition[0] = false
    elsif ((3806 + bg.current_x)..(3910 + bg.current_x)).include?(player.current_x)
        player.current_x = 3910 + bg.current_x
        bg.condition[0] = false
    else
        bg.condition[0] = true
    end
end

#? player will fall if not on path
def player_fall(player, new_y, gravity_switch)
    #? gravity_switch boolean value of whether the player is on ground. true = ground is the path, false = sky is the path
    #? new_y is the new y cordinate of the path where the player should be at.
    
    if gravity_switch then player[0].current_y -= player[0].gravity else player[0].current_y += player[0].gravity; end
    
    player[0].gravity = 1 if player[0].gravity.round == 0
    player[0].gravity /= 1.1 if player[0].gravity < 0
    player[0].gravity *= 1.1 if player[0].gravity > 0
    
    if gravity_switch #? the player will move towards the new_y in a motion if true
        if player[0].current_y < new_y #floor
            player[0].current_y = new_y
            player[0].gravity = 10
        end
        player[2].summon.play() if ((new_y+1)...(new_y+10)).include?(player[0].current_y)

    else #? the cords will just change, i.e. no fall or rise animation
        if player[0].current_y > new_y
            player[0].current_y = new_y
            player[0].gravity = 10
        end
        player[2].summon.play() if ((new_y-10)...new_y).include?(player[0].current_y)
    end
end

#? constantly update what y level player should be on
def player_update_y(player, gravity_switch, bg)
    cords_to_use = path_cords(gravity_switch)
    player_fall(player, cords_to_use[0], gravity_switch)
    
    for i in 1...cords_to_use.size()
        #puts("#{cords_to_use[i][0][0]}, #{cords_to_use[i][0][1]}, #{player[0].current_x}")
        #puts (-1*(bg[9].current_x - player[0].current_x))
        if (cords_to_use[i][0][0] .. cords_to_use[i][0][1]).include?(-1*(bg[9].current_x - player[0].current_x))
            player_fall(player, cords_to_use[i][1], gravity_switch)
        end
    end
end

#? effects to take place when the player gets hurt
def player_hurt(player)
    player[4].summon.play() #* adding play command here will overloop the audio giving more "howl" effect.
    blood_thread = Thread.new{
        player[5].condition = true
        sleep(0.5)
        player[5].condition = false
    }
end

#? keyboard controls for the player
def player_controls(player, backgrounds, direction, index)
    if Gosu.button_down?(Gosu::KB_A) || Gosu.button_down?(Gosu::KB_D)
        direction = -1 if Gosu.button_down?(Gosu::KB_A)
        direction = 1 if Gosu.button_down?(Gosu::KB_D)
        player_move(player, direction)
        bg_move(backgrounds, direction)
    else
        animate(player, 0, 1700, 85) if index % 2.5 == 0 # making the animation quite slower
    end
    return direction
end
