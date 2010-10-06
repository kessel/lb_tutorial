## check if a command line argument is given
if { $argc != 2 } {
  puts "polymer.tcl"
  puts "-----------"
  puts "Diffusion of a single polymer chain in a lattice boltzmann fluid"
  puts "Please pass the number of monomers as a command line argument!"
  puts "./Espresso polymer.tcl #nodes #monomers"
  puts ""
  puts "output: pos.dat v.dat"
  puts "The files contain the time elapsed in the simulation and the center"
  puts "of mass position and velocity"
}
puts $argv
set nummon [ lindex $argv 1 ]

setmd box_l 16. 16. 16.
setmd skin 0.2
setmd time_step 0.01
cellsystem domain_decomposition -no_verlet_list

inter 0 0 lennard-jones 1. 1. 1.226 0.25 0.
inter 0 fene 7. 2.

set posfile [ open "pos.dat" "w" ]
set vfile [ open "v.dat" "w" ]

polymer 1 $nummon 1. bond 0

puts "Warming up the polymer chain."
thermostat langevin 1. 1.
inter ljforcecap 5.
integrate 500
inter ljforcecap 10.
integrate 500
inter ljforcecap 20.
integrate 500
inter ljforcecap 0.
thermostat off
puts "Done."

lbfluid grid 1. dens 1. visc 1. tau 0.1 friction 20.
thermostat lb 1.

puts "Warming up the system with LB fluid."
integrate 1000
puts "Done."

for { set i 0 } { $i < 3000 } { incr i } {
    integrate 10
    set vx 0.
    set vy 0.
    set vz 0.
    for { set j 0 } { $j < [ setmd n_part ] } { incr j } {
	      set v [ part $j print v]
        set vx [ expr $vx + [ lindex $v 0 ] ]
        set vy [ expr $vy + [ lindex $v 1 ] ]
        set vz [ expr $vz + [ lindex $v 2 ] ]
    }
    puts $posfile "[ setmd time ] [ analyze centermass 0 ]" 
    puts $vfile "[ setmd time ]  [ expr $vx/$nummon ] [ expr $vy/ $nummon ] [ expr $vz/ $nummon ]"
}
