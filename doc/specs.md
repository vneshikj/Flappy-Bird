# Entity Specifications

This document is to be used for planning and documenting the implementaion details of each entity.

> _Every significant change to the implementation is to accompany an update to this document_

## Entities

### FSM

#### Requirements

Outputs states corresponding to the relevant game mode. Requires the following:

-   Game Start <- Prompts the user to choose a game mode from the menu
-   Game Mode
    -   Training <- Constant scrolling speed of pipes (no levels/power ups)
    -   Normal <- Full game features (levels and power ups)
-   Game Over <- On death, stops scrolling and prompts user to return to Game Start on click.

#### Important Signals

-   **Mouse Click + Position**: Will be the primary driver for state changes
-   **Collision Detected**: Performs actions based on collision type [(see bird)](#bird)
-   **Peripheral signals(?)**: Switches, pushbuttons could be used to reset or influence state.

#### Implementation Details

Should be treated as a Moore FSM

### Sprite

#### Requirements

Needs to draw sprites based on data from an external synchronous ROM. The sprite can be scaled based on a generic, and should be drawn given a cooridinate on the screen.

### Bird

#### Requirements

The _Bird_ is a sprite that is fixed horizontally on the screen, and travels up and down. The upwards motion is to be triggered on a mouse click.

#### Constants

-   **Acceleration**: To be added to fall speed

-   **Max fall speed** caps the rate at which the bird can fall

-   **Up speed**: To be added while ascending

#### Important Signals


-   **Bird on**: Outputs 1 if the bird sprite is present in the current vsync pixel (x,y).

-   **Size**: (_Constant_) determines how much space the bird will take up relative to its center.

-   **Y Motion**: Acts as fall speed, can be positive or negative.

-   **Mouse In**: 1 or 0, comes from PS/2 mouse module

- **Collision**: 3 Bit std logic representing the collision types, can be: 
    - **"000"** no collision
    - **"001"** pipe collision
    - **"010"** ground collision
    - **"011"** health pickup collision
    - **"100"** invincibility pickup collision
    - **"101"** death pickup collision

# Power Ups
## Health Pick Up
Bird has three lives. If it collides with a pipe, or the ground, one life is lost. On pick up, one of these lives is replenished. If bird is at full health, life total increases to four. 

## Invincibility
Bird is invincible. Pipe collisions don't count and can't lose life. Screen can go faster to increase points?

## Instant Death
Skull pick up. Increases bird scale and so it instantly collides with a pipe and you lose. Changes bird scale constant- change to penis?

#### Game state

-   **Game Over**
    Do not accept user inputs

-   **Game Start**
    Stay in middle of screen

-   **Gameplay (Game/Training)**
    _See below_

#### Implementation Details

**On:**

VGA_SYNC (Normal Operation)

```
IF mouse is pressed
    - Set fall speed to go up
ELSE IF mouse is NOT pressed (bird is falling)
    - Minus CONST from fall speed
    - Add fall speed (negative) to y position
```

VGA_SYNC (Edge cases)

```
IF at ground
    - Set fall speed to 0
Else if at top
    - Set Rise speed to 0
```

### Pipe

#### Requirements

The pipe is an entity which has a random height gap with a constant width, starts from the right of the screen and stops operation when it passes the left side of the screen.

#### Constants

-   **Pipe Gap**: Distance from the end of the pipe to the start of the next gap

-   **Pipe Width**: Distance from start of pipe top end of pipe

-   **Random Heights**: Vector of fixed size containing different pipe Heights

#### Important Signals

-   **Init**: Sets a scrolling speed

-   **Enable Next**: Inits the next pipe

-   **Scroll speed**: Input from FSM that determines how fast the pipes will scroll

-   **L Offset**: How far the right end of the pipe is from the start of the screen

-   **Pipe Index**: Randomly generated number to index a height from the random height vector

-   **Scroll Speed**: How fast the pipes scroll, determined by game difficulty

#### Game State

-   **Game Over**: All pipes stop scrolling

-   **Game Start**: All pipes reset

-   **Game (Train)**: All pipes scrolling

-   **Game (Normal)**: All pipes scrolling, depends on game mode

#### Implementation

**On:**

Init:

```
Store a random height using the random index
Set scroll speed to input scroll speed
```

VGA_Sync:

```
Move left by scroll speed (decrease L offset)
```

**VGA Display Conditions:**

```
PIPE_ON IF
- Must be true
(column >= L offset) AND (column <= L+Pipe Width) 
- One of these must be true
(row =< Pipe Height) **Top Pipe** OR (row >= Pipe Height + Pipe Gap) **Bottom Pipe**
```

### Display MUX

#### Requirements

This multiplexer requires **12 bit wide** bus inputs for **R[3..0] & G[3..0] & B[3..0]** for the following components:

-   Background x 1
-   Bird x 1
-   Pipe x 4
-   Ground x 1
-   Text x 1

The select input will need to be priority encoded

#### Important Signals

-   **RGB Inputs**: These come from every display component
-   **RGB Outputs**: Three signals, RGB to be sent to the vga sync
-   **Select**: Comes from the "On" signal of each component

#### Implementation Details

```
 Chain 2x1 MUX for non pipes to create a priority multiplexer
 Create a separate MUX for all the pipes that feeds into the MUX chain
```

The priority should be as follows:

1. Text
2. Bird
3. Ground
4. Pipes
5. Background

### Random Number Generator

#### Requirements

This will generate a random number within a range to be fed into the pipes. Clock triggered. Number will be a 3 bit (can be changed) std_logic_vector. It will use a Galois LSFR algorithm.

#### Important Signals

-   **Number**: The number generated, likely represented as STD_LOGIC_VECTOR

#### Implementation Details

Galois LSFR overview:

Initialisation

```
Store an n-bit seed
```

_Note that the reset is asynchronous and sets the bits back to the initial seed_

On rising edge

```
Concat arbitrary LSBs and XOR of Upper bits and stores in LSFR register
```

Outputs

```
Current value of LSFR register
```

### Pipe Start

#### Requirements

This will give a short pulse signalling the first pipe to enter the screen, it should only be triggered once when the FSM goes from Game Start to Game Mode, and needs to be reset when the game goes from Game Over to Game Start

#### Important Signals

-   **State**: 1 or 0 depending on whether the game has started or not

-   **Pulse**: 1 for one vysnc cycle.

### Text Display

#### Requirements

Have a single component to display text on the screen based on the game state

#### Game State

-   **Game Over** Display game over text + score

-   **Game Mode** Display score

-   **Game Start** Display menu to click + score

#### Important Signals

-   **Character address(es)**: Used to access the pixel data of the the sprites in the rom.

-   **Score**: Input that allows the display to update

-   **Text**: Should be constant values (predefined and stored for display on the relevant game state)

-   **Text on**: Used to output the relevant RGB to the VGA

- **Menu items**: To access game/train mode

- **Health and level dispaly**: Updated as game goes on

#### Implementation Details

Instantialize relvant sprite modules

### Ground

#### Requirements

Display graphics for the lower section of the screen

#### Implementation details

Once a y-coordinate is determined for the top of the ground:

```
Ground is on when pixel_row >= top of ground

Create gradient by checkinng y-pos
```

### Background

#### Requirements

Display the very bottom layer of the game, could be solid color or more complex graphics.

### Cursor

#### Requirements

Give the user visual feedback of where the mouse is on the screen, and also when the mouse is clicked (by changing colour). Also is able to interact with the menu on the start screen

