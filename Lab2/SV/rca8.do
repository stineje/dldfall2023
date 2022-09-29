# Copyright 1991-2007 Mentor Graphics Corporation
# 
# Modification by Oklahoma State University
# Use with Testbench 
# James Stine, 2008
# Go Cowboys!!!!!!
#
# All Rights Reserved.
#
# THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION
# WHICH IS THE PROPERTY OF MENTOR GRAPHICS CORPORATION
# OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.

# Use this run.do file to run this example.
# Either bring up ModelSim and type the following at the "ModelSim>" prompt:
#     do run.do
# or, to run from a shell, type the following at the shell prompt:
#     vsim -do run.do -c
# (omit the "-c" to see the GUI while running from the shell)

onbreak {resume}

# create library
if [file exists work] {
    vdel -all
}
vlib work

# compile source files
vlog ha.sv fa.sv rca8.sv test_rca8.sv

# start and run simulation
vsim -voptargs=+acc work.stimulus 

view list
view wave

-- display input and output signals as hexidecimal values
# Diplays All Signals recursively
#add wave -hex -r /stimulus/*
add wave -noupdate -divider -height 32 "Inputs"
add wave -hex /stimulus/dut/A
add wave -hex /stimulus/dut/B
add wave -hex /stimulus/dut/Cin
add wave -noupdate -divider -height 32 "Outputs"
add wave -hex /stimulus/dut/Sum
add wave -noupdate -divider -height 32 "Answer"
add wave -hex /stimulus/answer

add list -hex -r /stimulus/*
add log -r /*

-- Set Wave Output Items 
TreeUpdate [SetDefaultTree]
WaveRestoreZoom {0 ps} {75 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

-- Run the Simulation
run 480


