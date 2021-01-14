# vmd-convert

This Script is a BASH-wrapper for VMD, which is used to convert MD simulation files into any file format provided by VMD. It can also just be used for alignment and pbc wrapping, if the same file formats as input files are provided.

## Usage  
This is how the script is used. This usage information is also available via the '-h' option

bash vmd-convert.sh [-ptcosawen]

## Command line arguments aka options aka flags:  

mandatory:  
 -p <structure file in> # example: <MD directory>/*-in.cms  
  -t <trajectory file in> # example: <MD directory>/*_trj/clickme.dtr  
  -c <structure file out> # example: <directory of structure file in>/structurefile-in.gro  
  -o <trajectory file out> # example: <directory of trajectory file in>/allframes.dcd  

optional:  
  -s <start frame> # default: 1  
  -e <end frame> # default: -1 (=last frame)  
  -a <VMD atom selection used for alignment>	# default: 'protein'  
  -w <VMD atom selection used for writing out> # default: 'all'  
  -n <every nth frame is written out>	# default: 1  
  -v show VMD output on stderr  
  
## Remarks:

The output file format is defined by the filename extension, as specified.
Since this wrapper script is using VMD, all VMD-COMPATIBLE input and output file formats are applicable.
Make sure to use the VMD selection language (http://www.ks.uiuc.edu/Research/vmd/vmd-1.3/ug/node132.html)

### Example usage:

bash vmd-convert.sh -p /mdspace/davidm/mdsims/cyp4z1-lucbe_1-in.cms -t 
/mdspace/davidm/mdsims/cyp4z1-lucbe_1_trj/clickme.dtr
Workflow
This small wrapper for VMD is written in BASH and TCL. The BASH script vmd-convert.sh takes the provided information and passes it to VMD after starting it the TCL script is used for tasks executed within VMD

### This script does:

#### 1. Initialising
Checks for correct input and presence of the TCL file (vmd-convert.tcl)
Loading vmd module
Creates a output directory if provided via '-c' or '-o' option

#### 2. VMD: loading files
Starts VMD with the given options in command line mode.
Loads the structure and trajectory file

#### 3. VMD: Working on trajectory
PBC (Periodic Boundary Conditions) Wrapping is executed.
Trajectory alignment conducted according to provided atom alignment selection (-a; default='protein')

#### 4. Write out files
The structure and or trajectory file are written out in the specified format.
Only atoms in atom selection for write out (-w; default='all') are considered.
