#!/bin/bash
echo "                                          ";
echo "  ┬  ┬┌┬┐┌┬┐  ┌─┐┌─┐┌┐┌┬  ┬┌─┐┬─┐┌┬┐┌─┐┬─┐";
echo "  └┐┌┘│││ ││  │  │ ││││└┐┌┘├┤ ├┬┘ │ ├┤ ├┬┘";
echo "   └┘ ┴ ┴─┴┘  └─┘└─┘┘└┘ └┘ └─┘┴└─ ┴ └─┘┴└─";
echo "  v 0.3.1                                 ";
echo "                                          ";

### Checking for TCL script presence ###
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VMD=`which vmd`
if [ ! "${VMD}" ]; then
  echo "Could not find vmd."
  exit 1;
fi

# Deactivating CUDA acceleration to avoid conflicts with DESMOND
export VMDNOCUDA=1

tclscript=${DIR}/vmd-convert.tcl

if [ ! -f "$tclscript" ]; then
    echo "The file 'vmd-convert.tcl' is missing."
    exit 2;
fi


### Command line option parser ###
OPTIND=1  # Reset in case getopts has been used previously in the shell.

### Initialize check for required variables/options ###
SFI=false  	# structure file in
TFI=false  	# trajectory file in
SFO=false  	# structure file out
TFO=false  	# trajectory file out
SF=false	# starting frame
EF=false	# end frame
SA=false	# selection for alignment
OW=false	# selection for writing out
SSI=false	# stepsize for writing out

trajectoryfilein=""
outformatstruc=""
outformattrj=""
startframe="1"
endframe="-1"
selectalign="protein"
selectwrite="all"
stepsize=0  # Actual stepsize in vmd is defined as n+1

### Defining Usage ###
usage () { echo "Usage:

vmd-convert.sh [-ptcosawenh]

mandatory:
-p <structure file in>      			# example: <MD directory>/*-in.cms
-t <trajectory file in>     			# example: <MD directory>/*_trj/clickme.dtr
-c <structure file out>     			# example: <directory of structure file in>/structurefile-in.gro
-o <trajectory file out>    			# example: <directory of trajectory file in>/allframes.dcd

optional:
-s <start frame>            			# default: 1
-e <end frame>              			# default: -1 (=last frame)
-a <VMD atom selection used for alignment>	# default: 'protein'
-w <VMD atom selection used for writing out> 	# default: 'all'
-n <every nth frame is written out>		# default: 1
-v show VMD output on stderr

Since this wrapper script is using VMD, all VMD-COMPATIBLE input and output file formats are applicable.
The output file format is defined by the filename extension as specified.";}


### Getting all them arguments; As long as there is at least one more argument, keep looping ###
while getopts "p:t:c:o:s:e:a:w:n:v:h" opt; do
	case $opt in
	    p) structurefilein="$OPTARG"; SFI=true;;
	    t) trajectoryfilein="$OPTARG"; TFI=true;;
	    c) structurefileout="$OPTARG"; SFO=true; outformatstruc=$( echo $OPTARG |  awk -F"." '{ print $2 }');;
	    o) trajectoryfileout="$OPTARG"; TFO=true; outformattrj=$( echo $OPTARG |  awk -F"." '{ print $2 }');;
	    s) startframe="$OPTARG"; SF=true;;
	    e) endframe="$OPTARG"; EF=true;;
	    a) selectalign="$OPTARG"; SA=true;;
        w) selectwrite="$OPTARG"; OW=true;;
	    n) stepsize="$OPTARG";;
	    v) verbose="$OPTARG";;
	    h) usage; exit 3;;
	esac
done

#shift $((OPTIND-1))
#[ "$1" = "--" ] && shift

### Checking arguments ###
# Checking for presence of 'p' argument
if [ "${SFI}" == "false" ] || \
   [ "${TFI}" == "false" ] || \
   [ "${SFO}" == "false" ] || \
   [ "${TFO}" == "false" ] \
   ;  then
    echo "Mandatory option(s) missing!

Try '-h' option for help.";
    exit 3;
fi

### Echoing the used options ###
echo "VMD executable:       $VMD"
echo "structure file in:    $structurefilein"
echo "trajectory file in:   $trajectoryfilein"
echo "structure file out:   $structurefileout"
echo "trajectory file out:  $trajectoryfileout"
echo "start frame:          $startframe"
echo "end frame:            $endframe"
echo "alignment selection:  $selectalign"
echo "write out selection:  $selectwrite"
echo "step size:            $stepsize"
echo "verbose:              $verbose"


### Invoking VMD for trajectory conversion/cropping ###
echo ""
echo "Starting vmd trajectory conversion..."

VMDCMD="${VMD} -f $structurefilein $trajectoryfilein -dispdev text -e $tclscript -args $structurefileout $trajectoryfileout $outformatstruc $outformattrj $startframe $endframe ${selectalign// /_-_-_} ${selectwrite// /_-_-_} $stepsize"

if [ "${verbose}" == "true" ]; then
  echo ${VMDCMD}
else
  ${VMDCMD}  >/dev/null 2>&1
fi




echo -n "Successfully wrote "
echo -n $(realpath $structurefileout) \(`stat --printf="%s" $structurefileout` bytes\)
echo -n " and "
echo -n $(realpath $trajectoryfileout) \(`stat --printf="%s" $trajectoryfileout` bytes\)
echo .

exit 0;
