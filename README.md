# RGB Game of Life

The following Systemverilog files implement the cellular automaton Conway’s Game of Life on the iceblinkpico FPGA using HDL. The game of life is then serially transmitted to the ws2812b LED display, and cycles through the color wheel when it is displayed. The following is the first 18 generations of a cellular pattern called LWSS (light weight spaceship) which will travel across the screen indefinitely, exhibiting the wrap-around functionality. This can be easily seen, since generation 17 (second to last) is identical to generation 1. I chose this method of displaying testbench results because it is much easier to visualize the movement of the pattern than using waveforms. The step size is made to 200 clocks from 6M for speed. Zooming in, looking at the top left cell in the first generation, you can see that it dies on the second generation because there are not enough cells around it. Conversely, in the first generation third row third column, there are exactly 3 living cells immediately near it, so in the second generation a new cell is born at that index. Looking at other cells in the surrounding area, the last two rules also stand.

```
# . . # . . . . 
. . . . # . . . 
# . . . # . . . 
. # # # # . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . . . . 
. . . # # . . . 
. # # . # # . . 
. # # # # . . . 
. . # # . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . . . . 
. . # # # # . . 
. # . . . # . . 
. . . . . # . . 
. # . . # . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . # # . . . 
. . # # # # . . 
. . # # . # # . 
. . . . # # . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . # . . # . . 
. . . . . . # . 
. . # . . . # . 
. . . # # # # . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . . . . 
. . . . . # # . 
. . . # # . # # 
. . . # # # # . 
. . . . # # . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . . . . 
. . . . # # # # 
. . . # . . . # 
. . . . . . . # 
. . . # . . # . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . # # . 
. . . . # # # # 
# . . . # # . # 
. . . . . . # # 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . # . . # 
# . . . . . . . 
# . . . # . . . 
# . . . . # # # 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . . . . 
# . . . . . . # 
# # . . . # # . 
# . . . . # # # 
. . . . . . # # 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . . . . 
# # . . . . # # 
. # . . . # . . 
. # . . . . . . 
# . . . . # . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

# . . . . . . # 
# # . . . . # # 
. # # . . . # # 
# # . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. # . . . . # . 
. . # . . . . . 
. . # . . . # . 
# # # . . . . # 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . . . . 
. # # . . . . . 
# . # # . . . # 
# # # . . . . # 
# # . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . . . . 
# # # # . . . . 
. . . # . . . # 
. . . # . . . . 
. . # . . . . # 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. # # . . . . . 
# # # # . . . . 
# # . # # . . . 
. . # # . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

# . . # . . . . 
. . . . # . . . 
# . . . # . . . 
. # # # # . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 

. . . . . . . . 
. . . # # . . . 
. # # . # # . . 
. # # # # . . . 
. . # # . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . .

```

### Game Of Life

Next is the implementation of the game of life itself. The rules are simple and can be implemented with simple combinational logic when knowing the states and indexes of surrounding cells from the target cell:
If the cell is alive:
If there are 2 or 3 cells alive near it, it continues living, otherwise it dies.
If the cell is dead: 
If there are exactly 3 cells alive around it, it is brought back to life.

The state of the board is stored in 2 unpacked arrays, one for the current state and one for the next. This was done so the computations for the current generation do not overwrite logic conditions for the next. The 8x8 array is turned into a 64 bit logic signal before it is outputted from the main computational module for easy serial transmission to the LED board. 

Control is counter driven on the counter index, which is reset on the step size (half a second for each generation). This includes resetting the counter and iterating and calculating the next state of the 64 indices of the LED matrix. For this, a second counter variable is used as the index for 64 of the clock cycles.

To easily calculate the indices of the relevant surrounding cells from the target cells, I precomputed the indices of the 8 cells using continuous assign statements and indexed the current grid logic bus. This makes computations fast and the code readable since I could use division because 8 is a power of 2 and makes the synthesis much less bloated. This is because division hardware does not need to be built, since dividing by a power of 2 is just a bit shift. A huge benefit of this as well is that the wrap-around requirement is built in, since when the index attempts to go from 7 -> 8, it wraps around back to zero (or the other way around) because 3 bit values roll back to 0 when greater than 7. 

### Seed Files

2 seed files are added, with layout filled by hexcodes. Hex are 4 bits each, so the files are 8 rows of 2 hex characters for the 8x8 grid. glider.txt creates a glider structure that travels along the diagonal of the screen, and lwss.txt creates a light weight spaceship structure that moves horizontally across the screen. 

### Fade

A brief overview of the fade module from mp2. This module turns clock timings into 6 distinct zones where light intensity from each of the three color channels is either increasing, decreasing, on, or off. Combining the three with specific timings cycles through the whole visible color spectrum. The small tweak that needed to be made was changing the threshold values to output color intensities across timesteps instead of PWM values. Then, based on the rules defined in game of life, the cell on the LED screen either takes on the color value outputted by fade if it is alive, or zero (off) if it is dead. 

## Other Modules

### Top
Wires all other modules together, has some bit shift serialization logic.

### Controller 
A finite state machine that walks through each of the 64 pixels. Reads incoming pixels and loads shift register. 

### Ws2812b
Turns bits into a timed pulse for the LED screen to read and signals when to shift to the next bit.

Note: Controller and ws2812b are used from course examples

Simulation is run through this code block:
```iverilog -g2012 -o mp3_tb.vvp mp3_tb.sv && vvp mp3_tb.vvp```

Demo video:

https://youtube.com/shorts/Wsj8p5M67cE?feature=share


