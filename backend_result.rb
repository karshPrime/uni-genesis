#!/usr/bin/env ruby

#? conditions for game to get over
def should_play_update(player, result, gravity_switch, bg_location)
    if player[0].current_y == 591 || player[0].current_y == 164
        player_hurt(player)
        result_health_minus(player[0], result, gravity_switch)
    end
    if result.points == 10
        result.reason = "won"
    elsif player[0].health <= 0
        result.reason = "lost"
        result.should_play = false
    elsif result.ammo == 0
        result.reason = "over"
    end
    
    #* game over when player gets to map's end
    (result.points += 5; result.should_play = false) if 6150 <= (player[0].current_x - bg_location)
end

#? player's health will decrease if he's landed anywhere but or between the path
def result_health_minus(player, result, gravity_switch)
    cords_to_use = path_cords(gravity_switch)
    unless (result.been_at[0]..result.been_at[1]).include?(player.current_x)
        player.health -= 0.25
    end
end

#? message to output when game's over. head title and color depends on why the game ended.
def game_over(result, player)
    puts "" #? output blank line
    case result.reason
    when "over" #? neither won nor lost. player failed to kill all skulls
        puts add_space("G A M E   O V E R", "center").colorize(:color => :black, :background => :light_yellow)
    when "lost" #? player died
        puts add_space("Y O U   L O S T", "center").colorize(:color => :white, :background => :red)
    when "won"  #? player collected all carrots possible
        puts add_space("Y O U   W O N", "center").colorize(:color => :white, :background => :green)
    end
    print add_space("Points            : #{result.points}", "columnL").colorize(:color => :black, :background => :white)
    puts add_space("Final Health     : #{(player.health*10).round}%", "columnR").colorize(:color => :black, :background => :white)
    print add_space("Ammo Used         : #{10 - result.ammo}", "columnL").colorize(:color => :black, :background => :white)
    puts add_space("Time Spent       : #{Time.at(result.time).utc.strftime("%M:%S")}", "columnR").colorize(:color => :black, :background => :white)
end
