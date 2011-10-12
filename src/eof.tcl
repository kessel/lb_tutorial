## eof.tcl. A script that simulates EOF in a 10 Nanonmeter
#incr partcount
## wide channel with the LB method

## MD parameters
set box_l 16
setmd box_l $box_l $box_l $box_l
setmd time_step 0.01
setmd skin 0.3
cellsystem domain_decomposition -no_verlet_list

## create two charged walls with total charge 50.
set part_distance 2.
set total_charge 50.
set n_wall_part [ expr $box_l / 2 * $box_l /2 ]
set charge_per_part [ expr $total_charge / $n_wall_part ]
set partcounter 0
puts $charge_per_part
for { set y 0 } { $y < $box_l } { incr y } { 
  for { set z 0 } { $z < $box_l } { incr z } {
    part $partcounter pos 0. $y $z q $charge_per_part type 0 fix 1 1 1
    incr partcounter
    part $partcounter pos 15. $y $z q $charge_per_part type 0 fix 1 1 1
    incr partcounter
  }
}

## constraints for the counterions
constraint wall dist 1.5 normal 1. 0. 0. type 1
constraint wall dist -14.5 normal -1. 0. 0. type 1

## the ion-ion and ion-wall interaction potential
inter 1 2 lennard-jones 1. 1. 1.225 0.25 0.
inter 2 2 lennard-jones 1. 1. 1.225 0.25 0.


## setting up the ions
puts "Creating particles"
## Loop over all particles
for { set i 0 } { $i < 50 } { incr i } {
  ## the flag ok indicates if the position
  ## of the particle is fine. While it is not
  ## fine, new positions well be crated randomly
  set ok 0
  while { !$ok } {
    set x [ expr 16 * [ t_random ] ]
    set y [ expr 16 * [ t_random ] ]
    set z [ expr 16 * [ t_random ] ]
    # if the particle is between the walls
    if { $x > 3. && $x < 13. } {
      part $partcounter pos $x $y $z type 2
      # check if two particles overlap
      if { $i == 0 || [ analyze mindist ] >= 1. } {
        incr partcounter
        set ok 1 
      } 
    }
  }
}
puts "Done."



## charging the ions
for { set i 0 } { $i < 50 } { incr i } {
  part $i q -1.
}

## thermostat 
thermostat langevin 1. 1.

## electrostatic interacion
inter coulomb 1.0 p3m tunev2 accuracy 1e-4 mesh 16




## warmup
integrate 1000

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
for { set i 0 } { $i < 200 } { incr i } {
  integrate 50
  incr samples
  ## update the histograms
  for { set j 0 } { $j < 50 } { incr j } {
    ## determine the x position of particle $j
    set x [ lindex [ part $j print pos ] 0 ]
    ## determine the corresponding bin
    set bin [ expr int(floor($x/$box_l*$nbins)) ]
    ## fill data
    lset density_profile $bin [ expr [ lindex $density_profile $bin ] + 1. ]
    lset flux_profile $bin [ expr [ lindex $flux_profile $bin ] + [ lindex [ part $j print v ] 1 ] ]
  }
}
puts "Done."

## Write the profiles to files. 
## All number have to be divided by the volume
## of each bin and the number of samples
set den_file [ open "density.dat" "w" ] 
set flux_file [ open "flux.dat" "w" ] 
set vel_file [ open "vel.dat" "w" ] 
for { set i 0 } { $i < $nbins } { incr i } {
  puts $den_file  "[ expr ($i+0.5)*$box_l/$nbins ] [ expr [ lindex $density_profile $i ]/$box_l/$box_l/($box_l/$nbins) / $samples ]"
  puts $flux_file "[ expr ($i+0.5)*$box_l/$nbins ] [ expr [ lindex $flux_profile $i ]/$box_l/$box_l/($box_l/$nbins)    / $samples ]"
  if { [ lindex $density_profile $i ] > 0 } { 
    puts $vel_file  "[ expr ($i+0.5)*$box_l/$nbins ] [ expr [ lindex $flux_profile $i ] /  [ lindex $density_profile $i ] ]"
  } else {
    puts $vel_file "[ expr ($i+0.5)*$box_l/$nbins ] 0."
  }
}
close $den_file
close $flux_file
close $vel_file


