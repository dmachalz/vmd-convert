#tcl script used by VMD; accepting input from SH script

#parsed variables: $structurefileout $trajectoryfileout $outformatstruc $outformattrj $startframe $endframe $selectalign $selectwrite $stepsize

### transforming parsed variables for usage in script ###
set structurefileout [lindex $argv 0]
set trajectoryfileout [lindex $argv 1]
set outformatstruc [lindex $argv 2]
set outformattrj [lindex $argv 3]
set startframe [lindex $argv 4]
set endframe [lindex $argv 5]
set selectalign [regsub -all {_-_-_} [lindex $argv 6] " "]
set selectwrite [regsub -all {_-_-_} [lindex $argv 7] " "]
set stepsize [lindex $argv 8]

### pbc wrapping ###
package require pbctools
pbc wrap -centersel protein -center com -compound res -all

### defining alignment function ###
proc fitframes { molid seltext } {
  set ref [atomselect $molid $seltext frame 0]
  set sel [atomselect $molid $seltext]
  set all [atomselect $molid all]
  set n [molinfo $molid get numframes]
   
  for { set i 1 } { $i < $n } { incr i } {
    $sel frame $i
    $all frame $i
    $all move [measure fit $sel $ref]
  }
  return
}

### executing alignment function ###
if {$trajectoryfileout != ""} {
  fitframes top protein
}

### writing out files ###
if {$structurefileout != ""} {
  animate write $outformatstruc $structurefileout beg 0 end 0 sel [atomselect top $selectwrite]
}

# if trajectory was provided and should be written out
if {$trajectoryfileout != ""} {
  animate write $outformattrj $trajectoryfileout beg $startframe end $endframe skip $stepsize sel [atomselect top $selectwrite]
}

exit
