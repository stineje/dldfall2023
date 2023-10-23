This is the command to run graphviz on Linux/Mac.  If you do not have
a Linux/Mac, you can always run online at
https://dreampuf.github.io/GraphvizOnline/ or by searching on Google
for "graphviz online".  A sample Graphviz file (fsm.dot) is included
that is the FSM diagram of fsm.sv

dot -Tpng -O fsm.dot

The fsm.sv is a sample Moore-style FSM in SystemVerilog that I made
up.  To run with ModelSim, just type vsim -do fsm.do

The clk_div.sv is the clock divider you will need for this
laboratory.  To see what the clock divider does in ModelSim, you can
type vsim -do run.do.  Note: this may take a while to run as it runs
for 1.2 ms.


