## boundaries.tcl
##
## Simulate repulsive Lennard-Jones particles
## between two planar walls

## set MD parameters and a thermostat
set box_l 16.
setmd box_l $box_l $box_l $box_l
setmd skin 0.2 
setmd time_step 0.01
thermostat langevin 1. 1.

## set up  walls
constraint wall dist 1.5 normal 1. 0. 0. type 1
constraint wall dist -14.5 normal -1. 0. 0. type 1

## set up WCA interaction 
### between particles
inter 0 0 lennard-jones 1. 1. 1.225 0.25 0.
### and between particles and the walls
inter 0 1 lennard-jones 1. 1. 1.225 0.25 0.

puts "Creating particles"
## Loop over all particles
for { set i 0 } { $i < 50 } { incr i } {
  ## the flag ok indicates if the position
  ## of the particle is fine. While it is not
  ## fine, new positions well be crated randomly
  puts $i
  set ok 0
  while { !$ok } {
    set x [ expr 16 * [ t_random ] ]
    set y [ expr 16 * [ t_random ] ]
    set z [ expr 16 * [ t_random ] ]
    # if the particle is between the walls
    if { $x > 3. && $x < 13. } {
      part $i pos $x $y $z type 0
      # check if two particles overlap
      if { $i == 0 || [ analyze mindist ] >= 1. } {
        set ok 1 
      } 
    }
  }
}
puts "Done."

## now equilibrate the system for some time
integrate 1000

## apply external force and equilibrate again
for { set i 0 } { $i < 50 } { incr i } {
  part $i ext_force 0. 0.1 0.
}
integrate 1000

## initialize the histograms
## The box ist divided into nbins areas for which the 
## density is calculated by counting the particles
## in each area. The flux is calculated by taking
## the average number times the average velocity
## During the simulation the data will be only added
## up and finally divided by the number of samples
## that have been taken.
set nbins 16
set samples 0
## These two lists will con
set density_profile [ list ]
set flux_profile [ list ]
for { set i 0 } { $i < $nbins } { incr i } {
  lappend density_profile 0.
  lappend flux_profile 0.
}

puts "Running."
## production loop
for { set i 0 } { $i < 100 } { incr i } {
  integrate 500
  incr samples
  ## update the histograms
  for { set j 0 } { $j < 50 } { incr j } {
    ## determine the x position of particle $j
    set x [ lindex [ part $j print pos ] 0 ]
    ## determine the corresponding bin
    set bin [ expr int(floor($x/$box_l*$nbins)) ]
    ## fill data
    lset density_profile $bin [ expr [ lindex $density_profile $bin ] + 1 ]
    lset flux_profile $bin [ expr [ lindex $flux_profile $bin ] + [ lindex [ part $j print v ] 1 ] ]
  }
}
puts "Done."

set den_file [ open "density.dat" "w" ] 
set flux_file [ open "flux.dat" "w" ] 
set vel_file [ open "vel.dat" "w" ] 
for { set i 0 } { $i < $nbins } { incr i } {
  puts $den_file  "[ expr ($i+0.5)*$box_l/$nbins ] [ expr [ lindex $density_profile $i ] / $samples ]"
  puts $flux_file "[ expr ($i+0.5)*$box_l/$nbins ] [ expr [ lindex $flux_profile $i ]    / $samples ]"
  if { [ lindex $density_profile $i ] > 0 } { 
    puts $vel_file  "[ expr ($i+0.5)*$box_l/$nbins ] [ expr [ lindex $flux_profile $i ] /  [ lindex $density_profile $i ] ]"
  } else {
    puts $vel_file 0.
  }
}
close $den_file
close $flux_file
close $vel_file
