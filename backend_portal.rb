#!/usr/bin/env ruby

Portal_Screen_Location = [[960, 560], [1120, 150], [3750, 560], [3950, 150]]

#? initial portal info
def get_portal()
    portal = Layer.new("portal", 3)
    portal.angle = 0
    return portal
end

#? factors that needa update irrespective of user's actions
def portal_constant_update(portal)
    portal.angle += 1
end

#? limit the elelemt tasks to only when they are on screen. to prevent unnecessary code running
def teleport_check(player, bg, portal, gravity_switch)
    i = 0
    while i < 4
        #puts player[0].current_y - Portal_Screen_Location[1][1]
        if ((Portal_Screen_Location[i][0] - 10)..(Portal_Screen_Location[i][0] + 30)).include?(player[0].current_x - bg.current_x) && (player[0].current_y > Portal_Screen_Location[i][1])
            gravity_switch = value_toggle(gravity_switch)
            player[3].summon.play() #* teleport audio
            player[0].current_x += Portal_Screen_Location[i+1][0] - Portal_Screen_Location[i][0] 
            player[0].current_y = Portal_Screen_Location[i+1][1]
        end
        i += 2
        #* alternate portals are of same type- inhale or exhale
    end
    return gravity_switch
end

#? to display the portal
def draw_portal(portal, bg)
    for i in 0...Portal_Screen_Location.size()
        if (-1 * bg.current_x) >= Portal_Screen_Location[i][0] - 1000 && (-1 * bg.current_x) <= Portal_Screen_Location[i][0]
            portal.summon.draw_rot(Portal_Screen_Location[i][0]+bg.current_x, Portal_Screen_Location[i][1], 3, portal.angle)
        end
    end
end
