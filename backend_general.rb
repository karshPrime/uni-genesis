#!/usr/bin/env ruby

=begin LAYER INFORMATION
 #   Z-order 0  Day/Night       Vertical Loop
 #   Z-order 0  Sun/Moon        Constant
 #   Z-order 1  Rocks
 #   Z-order 1  Landscape
 #   Z-order 1  Back Trees
 #   Z-order 1  Front Trees
 #   Z-order 1  Front Details
 #   Z-order 2  Clouds Group
 #   Z-order 2  Single Cloud
 #   Z-order 3  path
 #   Z-order 3  portal
 #   Z-order 4  player
 #   Z-order 4  Pet
 #   Z-order 4  Skulls
 #   Z-order 5  Attack- Flaire
 #   Z-order 5  Gun blast
 #   Z-order 6  front tree n details
 #   Z-order 7  scope base
 #   Z-order 7  scope detail 1
 #   Z-order 7  scope detail 2
 #   Z-order 7  bullet count
 #   Z-order 7  reload
 #   Z-order 7  time
 #   Z-order 7  health
 #   Z-order 7  points
=end

#? custom data type for graphical media used
class Layer
    attr_accessor :velocity, :current_x, :current_y, :summon, :fixed_z, :condition, :total, :current_sprite_x, :gravity, :health, :angle, :diff_x, :diff_y
    def initialize(file_name, fixed_z)
        @summon = Gosu::Image.new("media/#{file_name}.png")
        @fixed_z = fixed_z
    end
end

#? custom data type for audio
class Audio_used
    attr_accessor :summon
    def initialize(file_name, format)
        @summon = Gosu::Sample.new("media/#{file_name}.wav") if format == "wav"     #* audio that would be played and overriten
        @summon = Gosu::Song.new("media/#{file_name}.ogg") if format == "ogg"       #* audio that would be looped
    end
end

#? custom data type to initlize and keep track of all the numerical tasks done. Like in the time-display in gun scope
class Number_use
    attr_accessor :current_sprite_x, :current_x, :current_y, :condition
    def initialize(current_x, current_y, width)
        @current_y = current_y
        @current_x = current_x
    end
end

#? for final game result.
class Result
    attr_accessor :time, :points, :ammo, :should_play, :been_at, :reason
    def initialize()
        @reason = "over"
        @been_at = [0, 0]
        @time = 0
        @points = 0
        @ammo = 10
        @should_play = true
    end
end

module Path_cords
    #? y-values for given x-values. index 0 is the "normal" path level as in when there are no steps or fall. [[x_range_start, x_range_end], y_for_that_range]
    ground_l0 = 591
    Ground = [581, [[265, 342], ground_l0], [[343, 499], 550], [[1414, 1515], 522], [[1663, 1740], ground_l0], [[1819, 1896], ground_l0], [[2482, 2716], ground_l0], [[3107, 3184], ground_l0], [[3185, 3262], 529], 
    [[3263, 3340], ground_l0], [[3341, 3418], 557], [[3419, 3496], ground_l0], [[3497, 3575], 499], [[3575, 3652], ground_l0], [[4500, 4563], ground_l0], [[4564, 4662], 503], [[4663, 4775], ground_l0], 
    [[4776, 4874], 483], [[4875, 4980], ground_l0], [[4981, 5079], 505], [[5080, 5219], ground_l0], [[5220, 5318], 535], [[5319, 5408], ground_l0], [[5409, 5507], 471], [[5508, 5581], ground_l0],
    [[5816, 5883], 510], [[5884, 5948], 453], [[5949, 6026], ground_l0]]

    sky_l0 = 164
    Sky = [174, [[1297, 1437],205], [[1740, 1818], sky_l0], [[2037, 2171],205], [[2529, 2698],205], [[3185, 3263], sky_l0], [[3263, 3340],196], [[3341, 3418], sky_l0], [[3419, 3496],225],
    [[3496, 3573], sky_l0], [[4286, 4476], 205], [[4490, 4665], sky_l0], [[4666, 4764], 285], [[4765, 4877], sky_l0], [[4878, 4976], 305], [[4977, 5082], sky_l0], [[5083, 5181], 283],
    [[5182, 5321], sky_l0], [[5322, 5420], 253], [[5421, 5530], sky_l0], [[5531, 5629], 218], [[5630, 5947], sky_l0]]
end

#? add whitespaces to format text 
def add_space(text, align)
	case align
	when "left"
		before = 4
		after = 70 - text.size()
    when "center"
        before = after = (74 - text.size())/2
        before += 1 if text.size() % 2 != 0
	when "columnL"
		before = 8
		after = 32 - text.size()
	when "columnR"
		before = 0
		after = 34 - text.size()
	end
	before.times {text = " " + text}
	after.times {text = text + " "}
	return text
end

def game_start()
    about()
    theme_song = Gosu::Sample.new("media/theme.ogg")
    theme_song.play()
end

#? returns list for what path cords to use for given gravity_switch condition. gravity_switch shall be boolean value
def path_cords(gravity_switch)
    if gravity_switch then return Path_cords::Sky else return Path_cords::Ground; end
end

#? images will repeat after end to form a long scene
#? using start and end index here to make draw() in Genesis class less messy
def loop_draw(item, axis, index_start, index_end)
	for i in index_start..index_end
		x = y = 0
		x = item[i].current_x % - item[i].summon.width if axis == "x"
		y = item[i].current_y % - item[i].summon.height if axis == "y"
		item[i].summon.draw(x, y, item[i].fixed_z)
		item[i].summon.draw((x + item[i].summon.width), 0, item[i].fixed_z) if x < (item[i].summon.width - 1000) && axis == "x"
        item[i].summon.draw(0, (y + item[i].summon.height), item[i].fixed_z) if y < (item[i].summon.height - 730) && axis == "y"
	end
end

#? will change sprite starting x position in loop to form animation
def animate(item, sprite_start, sprite_end, width)
    item.current_sprite_x += width
    item.current_sprite_x = sprite_start if item.current_sprite_x >= sprite_end || item.current_sprite_x < sprite_start
end

#? limiting mouse cords within the required area on screen
def mouse_limit(x_cord, y_cord)
    x_cord = 859 if x_cord > 859
    x_cord = 140 if x_cord < 140
    y_cord = 590 if y_cord > 590
    y_cord = 138 if y_cord < 138
    return [x_cord, y_cord]
end

#? bool toggle
def value_toggle(condition)
    if condition == true then return false else return true; end
end
