viewSq
===============

viewSq is a utility for calculating, analyzing, and visualizing static structure factors (S(q)) from trajectories produced using molecular dynamics or Monte Carlo simulations.

A tutorial is available [here](https://github.com/tmackoy/viewSq/tree/master/tutorials/spce_water).

If you find this code useful in your research, please cite: 

Mackoy, T.; Kale, B.; Papka, M.E.; Wheeler, R.A. viewSq, a Visual Molecular Dynamics (VMD) module for calculating, analyzing, and visualizing X-ray and neutron structure factors from atomistic simulations. *Comput. Phys. Commun.* **2021**, in press.

Installation
===============
### LINUX ###


1. Add the following line to /usr/local/lib/vmd/scripts/vmd/loadplugins.tcl

vmd_install_extension viewsq      viewsq_tk_cb    "Analysis/viewSq"

2. Copy the folder "viewsq1.0" to /usr/local/lib/vmd/plugins/noarch/tcl

3. Copy the file "Calculate_rdf_stats_py.py" to /usr/local/lib/vmd/scripts/python

Invoke VMD and look for the plug-in under Extensions->Analysis. 

Ensure Python 3.* is the default. If VMD asks for a path to Python, the following may work:  /usr/bin/python3.


### OSX ###

1. Add the following line to /Applications/VMD 1.9.3.app/Contents/vmd/scripts/vmd/loadplugins.tcl

vmd_install_extension viewsq      viewsq_tk_cb    "Analysis/viewSq"

2. Copy the folder "viewsq1.0" to /Applications/VMD 1.9.3.app/Contents/vmd/plugins/noarch/tcl

3. Copy the file "Calculate_rdf_stats_py.py" to /Applications/VMD 1.9.3.app/Contents/vmd/scripts/python

Ensure Python 3.* is the default. 

VMD 1.9.3 may not be compatible with recent MacOS versions: https://www.ks.uiuc.edu/Research/vmd/macosxcatalina.html


### WINDOWS ###

1. Add the following line to \VMD\scripts\vmd\loadplugins.tcl

vmd_install_extension viewsq      viewsq_tk_cb    "Analysis/viewSq"

2. Copy the folder "viewsq1.0" to \VMD\plugins\noarch\tcl

3. Copy the file "Calculate_rdf_stats_py.py" to \VMD\scripts\python (the folder may need to be created manually)

Invoke VMD and look for the plug-in under Extensions->Analysis. When running viewSq, VMD may require you to specify the location of the Python script from step #3. Ensure Python 3.* is in the Windows path.

Note: 64-bit Linux versions of VMD with viewSq can also be run using Windows Subsystem for Linux (https://docs.microsoft.com/en-us/windows/wsl/install-win10) and an X server.


Usage
===============
Invoke VMD and look for the viewSq module under Extensions->Analysis.

A tutorial is available [here](https://github.com/tmackoy/viewSq/tree/master/tutorials/spce_water).


License
===============
Copyright 2020 Travis Mackoy

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

