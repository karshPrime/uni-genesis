#!/usr/bin/env ruby

#!                              _     
#!    __ _  ___ _ __   ___  ___(_)___ 
#!   / _` |/ _ \ '_ \ / _ \/ __| / __|
#!  | (_| |  __/ | | |  __/\__ \ \__ \
#!   \__, |\___|_| |_|\___||___/_|___/
#!   |___/
#!

require 'gosu'
require 'colorize'
require_relative 'backend_general.rb'
require_relative 'backend_about.rb'
require_relative 'backend_backgrounds.rb'
require_relative 'backend_portal.rb'
require_relative 'backend_gun.rb'
require_relative 'backend_pet.rb'
require_relative 'backend_player.rb'
require_relative 'backend_result.rb'
require_relative 'backend_skull.rb'


#// please install the extension "better comments" by Aaron Bond if using VS code for more understandable comments


class Genesis < Gosu::Window
    def initialize()
        super 1000, 730, false
        game_start() #* initial commands (background music and print instructions)
        @backgrounds = get_backgrounds()
        @player = get_player()
        @pet = get_pet()
        @gun = get_gun()
        @portal = get_portal()
        @skull = get_skull()
        @result = Result.new()
        @direction = 1 #? right = 1, left = -1
        @show_mouse = @gravity_switch = @scope_enabled = false
        #* index is a variable which will be constantly incremented (by +1). it would be used for time.
        #* gun shoot is a variable which will be 0 while default and -10 when the mouse's left click is pressed.
        #* mouse pointer shall be hidden by default, though visible for video demonstration.
        @index = @gun_shoot = 0
    end

    def needs_cursor?
        @show_mouse
    end

    def update()
        if @result.should_play
            @index += 1
            player_update_y(@player, @gravity_switch, @backgrounds)
            player_pillars(@player[0], @backgrounds[9])
            @direction = player_controls(@player[0], @backgrounds, @direction, @index)
            @gravity_switch = teleport_check(@player, @backgrounds[9], @portal, @gravity_switch)
            bg_constant_update(@backgrounds)
            portal_constant_update(@portal)
            time_update(@gun[10], @index)
            pet_constant_update(@pet, @player[0], @direction, @gravity_switch)
            skull_constant_update(@skull, @index)
            @cords = mouse_limit(mouse_x, mouse_y)
            @result.time += 1 if @index % 50 == 0 #* game time is faster than irl time
            should_play_update(@player, @result, @gravity_switch, @backgrounds[9].current_x)
        else
            game_over(@result, @player[0])
            sleep(0.5) #* the game window will be still/static for 0.5 sec
            close
        end
    end

    def draw()
        loop_draw(@backgrounds, "y", 0, 0)
        @backgrounds[1].summon.draw(0,0,0)
        loop_draw(@backgrounds, "x", 2,10)

        if @gravity_switch then path = -1 else path = 1; end
        @player[0].summon.subimage(@player[0].current_sprite_x, 0, 85, 150).draw((@player[0].current_x - (@direction * 42.5)), (@player[0].current_y - (path * 75)), @player[0].fixed_z, @direction, path)
        @player[5].summon.draw(@player[0].current_x - 150, @player[0].current_y - 160, 4) if @player[5].condition
        @pet.summon.draw((@pet.current_x - (@direction * 28)), @pet.current_y, @pet.fixed_z, @direction, path)

        draw_gun(@gun, @cords, @gun_shoot, @result.points, @player[0].health) if @scope_enabled

        draw_portal(@portal, @backgrounds[9])

        @gun[3].summon.subimage(@gun[3].current_sprite_x, 0, 64, 64).draw(@gun[3].current_x, @gun[3].current_y, 6) if @gun[3].condition
    
        draw_skull(@skull)
    end

    def button_down(id)
        case id
        when Gosu::KB_ESCAPE
            close
        when Gosu::KB_W
            @gravity_switch = true
        when Gosu::KB_S
            @gravity_switch = false
        when Gosu::KB_D
            @player[1].summon.play(true)
            #* clouds are faster when player moves against their direction
            @backgrounds[7].velocity += 6
            @backgrounds[8].velocity += 6
        when Gosu::KB_X
            #! for debugging purpose 
            puts @player[0].current_y
            puts (@player[0].current_x - @backgrounds[9].current_x)
        when Gosu::KB_Z
            #! for demonstration purpose
            @show_mouse = value_toggle(@show_mouse)
        when Gosu::KB_A
            #* walk sound will start to play on loop
            @player[1].summon.play(true)
        when Gosu::KB_SPACE
            @scope_enabled = true
        when Gosu::MS_LEFT
            @gun_shoot = -10
            if @scope_enabled
                gun_fire(@cords, @gun, @result)
                kill_skull(@skull, @cords, @result, @player[0]) if @gun[6].total > 0 
            end
        when Gosu::MS_RIGHT
            gun_reload(@gun)
        end
    end

    def button_up(id)
        case id
        when Gosu::KB_SPACE
            @scope_enabled = false
        when Gosu::KB_D
            #* return the clouds speed to default when player isn't moving against their direction
            @backgrounds[7].velocity -= 6
            @backgrounds[8].velocity -= 6
            @player[1].summon.play(false)
        when Gosu::KB_A
            #* walk sound loop will break
            @player[1].summon.play(false)
        when Gosu::MS_LEFT
            @gun_shoot = 0
        end
    end
end

Genesis.new.show()
