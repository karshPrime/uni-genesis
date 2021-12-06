# Genesis [Assignment 9.3]
![Game Snip](https://raw.githubusercontent.com/ut-kr/Genesis/main/overview/game-snip.png)
## Project Summary
Genesis is a 2D indie game written in Ruby using the Gosu module. Game objective is to kill all mobs (skulls) possible. <br>
The player will be able to switch gravity and summon a 1st POV gun.<br>
**Controls:**
|         Key         | Action                                      |
|---------------------|---------------------------------------------|
|          W          | Switch player (and pet) gravity upwards     |
|          A          | Player (and pet) move backwards             |
|          S          | Switch player (and pet) gravity downwards   |
|          D          | Player (and pet) move forward               |
|        SPACE        | Enable scope                                |
|     CLICK LEFT      | Shoot                                       |
|     CLICK RIGHT     | Reload                                      |

## Required Data Types
### 1. Layer details
**Field Name:** Layer<br>
**Type:** Class<br>
**Notes:** Will import and initialize all graphical media used in the program. Will also be the parent class to various other classes.

### 2. Character details
**Field Name:** Character<br> 
**Type:** Class<br>
**Notes:** Will Inherit Layer class, and will contains all characteristics 
that a character would have.

### 3. Accessories details
**Field Name:** Accessories<br>
**Type:** Class<br>
**Notes:**  Will inherits Layer class, and will contains all characteristics that the “magical elements” (portals and carrot) would require.

### 4. Audio_used details
**Field Name:** Audio_used<br>
**Type:** Class<br>
**Notes:**  Will imports and initialize all audio that would be used in the program.

### 5. Number details
**Field Name:** Number_use<br>
**Type:** Class<br>
**Notes:** Will have instances to store current starting coordinate information for the number sprite file and the difference in x and y coordinate from the live-mouse-coordinates

### 6. Results
**Field Name:** Result<br>
**Type:** Class<br>
**Notes:** Will maintain a record of player health, score, time spent and ammo used.

### 7. Genesis details
**Field Name:** Genesis<br>
**Type:** Class<br>
**Notes:** Will inherit Gosu::Window and will be used to call all the functions and procedures defined.

## Overview of Program Structure
The code uses the following inbuilt and external libraries-
* Gosu - the base of the game.
* Colorize - to output fancier terminal instructions.
* Threads - to run different methods at (kind of) simultaneously.

Game uses a bunch of substances to make things look fancier and  less static. These substances are:
* player character
* pet character - will follow the player around
* backgrounds - layers of various images to give depth
* elements - things such as portal
* skull - game mob
* scope - for gun functionality
* result  - game statistics for the player

To make the code cleaner, each of these substances will be modularized in their own separate script-files, and one main file- `Genesis.rb` will call and use them.

### Chart 1: Genesis.rb [Gosu core methods]
![Chart1](https://github.com/ut-kr/Genesis/blob/main/overview/chart1.png?raw=true)
The initialize method will define (mostly) all instance variables that the main class- Genesis will use.

### Chart 2: Genesis.rb > def initialize()
![Chart2](https://github.com/ut-kr/Genesis/blob/main/overview/char2.png?raw=true)
These variables would be later used as parameters for different functions and procedures in other Gosu methods (`update`, `draw`, `button_up(id)` and `button_down(id)`).

### Other GOSU method’s actions:
#### update
Will take care of controls and movement and basically everything dynamic in the game as long as ammo and health is not less than or equal to 0.
#### draw
Will draw all the substances. Some substances would be drawn only if certain condition is matched.
#### button_down(id)
Will   be   used   to   put   certain   functions/procedures   on loop(like   function   for   player’s movement sound), and increment values for the substances which are supposed to update only on player’s interaction.
#### button_up(id)
Will be mainly used to stop all the loops started by button_down(id).