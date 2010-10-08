## check if a command line argument is given
if { $argc != 1 } {
  puts "single_particle_diffusion.tcl"
  puts "-----------"
  puts "Diffusion of a single polymer chain in a lattice boltzmann fluid"
  puts "usage:"
  puts "./Espresso single_particle_diffusion.tcl #procs #lb-nodes"
  puts ""
  puts "output: pos.dat v.dat energy.dat"
  puts "The files contain the time elapsed in the simulation and the center"
  puts "of mass position and velocity and kinetic energy"
}

## set up the box
setmd box_l [ lindex $argv 1 ] [ lindex $argv 1 ] [ lindex $argv 1 ]
## the skin is not important for a single particles
setmd skin 0.2
## the MD step in this simulation could be bigger, but
## we keep it consistent with typical LJ simulations
setmd time_step 0.01
## LB can not handle Verlet lists, so we disable them
cellsystem domain_decomposition -no_verlet_list

## open files for output
set posfile [ open "pos.dat" "w" ]
set vfile [ open "v.dat" "w" ]
set enfile [ open "energy.dat"  "w"]

## this creates the LB fluid with the parameters
## of our choice.
lbfluid grid 1. dens 1. visc 1. tau 0.1 friction 50.
## this activates the thermalization of the
## LB fluid and adds the random forces on the 
## particle
thermostat lb 1.

## create a particle
part 0 pos 0 0 0

## perform a couple of steps to come to equilbrium
puts "Warming up the system."
integrate 1000
puts "Done."

## Now the production run!
for { set i 0 } { $i < 1000 } { incr i } {
  if { $i % 100 == 99 } {
    ## tell the user we are still working
    puts "cycle $i completed"
  }
  integrate 10
  puts $posfile "[ setmd time ] [ part 0 print pos ]" 
  puts $vfile "[ setmd time ]  [ part 0 print v ]"
  puts $enfile "[ setmd time ]  [ analyze energy kinetic ]"
}

## and close output files
close $posfile
close $vfile
close $enfile
