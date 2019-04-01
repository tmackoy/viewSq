# viewSq

Program submission. Manuscripts that describe computer programs and NVAs must be accompanied
by: the program source code; job control scripts, where applicable; a README file giving the names and a brief description of all the files that make up the package and clear instructions on the installation and execution of the program; sample input and output data for at least one comprehensive test run that will convince the reviewers that the program operates as specified; and, where appropriate, a user manual.
A compressed archive program file or files, containing these items, should be uploaded at the "Attach Files" stage of the EES submission. The maximum file size allowed is 700Mb. For files larger than this the author should contact the Technical Editor at cpc.mendeley@gmail.com.

##### FILE DESCRIPTIONS

Calculate_rdf_stats_py.py --  


pkgIndex.tcl -- 


form_factors.csv -- 


viewsq.tcl --


##### INSTALLATION



###### LINUX


1. Add the following line to /usr/local/lib/vmd/scripts/vmd/loadplugins.tcl
&nbsp; vmd_install_extension viewsq      viewsq_tk_cb    "Analysis/viewSq"
2. Copy the folder "viewsq1.0" to /usr/local/lib/vmd/plugins/noarch/tcl
3. Copy the file "Calculate_rdf_stats_py.py" to /usr/local/lib/vmd/scripts/python

Invoke VMD and look for the plug-in under Extensions->Analysis. 

###### MAC

Due to memory restrictions, in order to reasonably use viewSq with over perhaps 10,000 atoms in Mac OS you will probably want to compile a 64-bit VMD version. The VMD website may offer some 64-bit pre-compiled versions which can be downloaded.


1. Add the following line to /Applications/VMD 1.9.3.app/Contents/vmd/scripts/loadplugins.tcl
&nbsp; vmd_install_extension viewsq      viewsq_tk_cb    "Analysis/viewSq"
2. Copy the folder "viewsq1.0" to /Applications/VMD 1.9.3.app/Contents/vmd/plugins/noarch/tcl
3. Copy the file "Calculate_rdf_stats_py.py" to /Applications/VMD 1.9.3.app/Contents/vmd/scripts/python

Ensure Python 3.* is the default python.

###### WINDOWS

Due to memory restrictions, in order to reasonably use viewSq with over perhaps 10,000 atoms in Windows you will probably want to compile a 64-bit VMD version. The VMD website may offer some 64-bit pre-compiled versions which can be downloaded.


1. Add the following line to \VMD\scripts\vmd\loadplugins.tcl
&nbsp; vmd_install_extension viewsq      viewsq_tk_cb    "Analysis/viewSq"
2. Copy the folder "viewsq1.0" to \VMD\plugins\noarch\tcl
3. Copy the file "Calculate_rdf_stats_py.py" to \VMD\scripts\vmd

Invoke VMD and look for the plug-in under Extensions->Analysis. When running viewSq, VMD may require you to specify the location of the Python script from step #3.
Ensure Python 3.* is in the Windows path.

##### ELEMENTS.NDX
While using viewSq, keep elements.ndx in the same folder where the input trajectory file exists.
1.  Determine which simulation you want to study first and copy the lammps dump file to a new folder on your desktop (preferably Linux for now, though Windows might work).
2.  Determine how many atoms there are in the simulation.
3.  Create a file named (elements.ndx) of the following format:
[ H  ]
1 2 3 4 5 6 7 8 9 10 ... 
The file will contain two lines and the numbering will end with the final atom number (the number you determined in step #1).
Don't make the above text file in Windows, as there may then be hidden characters. Maybe you can write a short Python script to create the file for you.
For reference here is the documentation (it's really short!) for .ndx files: http://manual.gromacs.org/online/ndx.html
4.  While you're at it you might as well create a second elements.ndx which has the breakdown into individual elements. Doing so will give you the ability to use viewSq to calculate form factor weighted S(q). You'll want to be able to do form factor weighted S(q) for our im and pyrr manuscripts. Remember that there will be more "lammps types" in your file than "elements". Something like 12 lammps types and seven or so elements.
So
[H]
1 5 7 9 ...
[N]
2 3 8 ...
[F]
4 6 ...
VMD TkConsole can be used for many simulation types to print atom serials which correspond to each atom type.
    1.  Load simulation
    2.  Open TkConsole
    3.  set sel [atomselect top "carbon"]
    4.  $sel get serial

### NEXT SECTION ###
1.  Download and extract the attached zip file.
2.  Follow Linux installation instructions in documentation_viewSq_11_13_18
3.  If installation works you'll see "viewSq" in the VMD extensions menu. You might see an error related to viewSq in the VMD terminal, but this can be ignored.
4.  Load your simulation file (and make sure elements.ndx -- ideally the version which is element specific) is located in the same folder as your dump file.
5.  Open viewSq, select your dump file from the drop down menu.
6.  For "Frames:" make First 0, Last 1, Step 2 (This assumes that your dump file only has one frame. If you have multiple frames we still only want to analyze one frame, so let's say there are 1000 frames, then:  First 0, Last 1, Step 9999 -- to try to only analyze the first frame -- we can analyze additional frames after we make sure everything is working)
7.  Delta r 0.1, Max r, 20.0 -- min q 0.2, max q 2
8.  Press "Compute s(q)" and keep an eye on the memory usage using "top" in a terminal -- if the memory usage exceeds the allocated ram then the calculation will either become extremely slow, or crash.
9.  Hopefully in less than 30 minutes (on my machine I can do one frame of an 11,250 atom simulation in about 5 minutes) you'll get a bunch of pop-up windows. You can use the drop down menu from the plots to save/export text files (matrix format works fine -- it's just a text file). You'll want to export the g(r) data and S(q) data. The g(r) data will have two columns (r, g(r)), and S(q) will have three columns (q, S(q), and form factor weighted S(q)). All units are angstroms or inverse angstroms.

### Anaconda instructions for lab computers ###

In your virtual machine go to the following website: https://www.anaconda.com/download/#download
Click the Linux penguin logo. Underneath the Download button you'll see:  64-Bit (x86) Installer (637 MB)
Download that to your Linux desktop.
Open a terminal and navigate to the desktop. In terminal run this command:  sudo bash <name of download file, without the triangle brackets>
Follow the instructions, install to default locations, and very importantly choose yes when asked the question about adding Anaconda to your path.
After the installation shut down Linux.
In Virtualbox make sure to set the ram fairly high, leaving only a few GB for the host MacOS.
Turn on virtual machine and try to run your viewSq calculation as before. Right before clicking "Compute s(q)" open a new terminal and type "top". When you click "Compute s(q)" you should watch top and see the cpu usage go to 100% for one process, and that process's memory usage climb quickly climb.

### ELEMENTS.NDX VIA VMD Tk CONSOLE ###
Anyway here's an alternative way for you to determine atom numbers associated with each element. You'll be able to copy and paste the atom numbers from VMD Tk console and paste them manually into an elements.ndx file. (Don't forget to perform the "wc elements.ndx" check to ensure the output is exactly number of elements + number of atoms).

    1.  Load dump frame into VMD
    2.  Open Tk console -- Extensions menu, Tk console
    3.  Then do the following over and over until every element set is complete
    4.  set sel [atomselect top "type 2 or type 7"]
    5.  $sel get serial
The above example can be tweaked so that each element requires one command 4 and one command 5. Anyway that's my way for creating elements.ndx.

### GENERAL NOTES
If you increase max_r or make delta_r smaller the run time will increase and the maximum memory usage will increase significantly. If you extend the q range, or make delta_q smaller, the maximum memory usage should stay nearly the same, but the run time will increase and the disk usage will increase.

There are a lot of new features, but at the very least you can aim for producing the low-q temperature trends (maybe make a plot and start storing your findings in spreadsheets and text files). After the initial all-all calculation finishes (you'll know it does because you'll have a bunch of plots showing) you can try out the Selection 1 and Selection 2 along with "Compute Selections" -- maybe try "type 1" and "type 1" first, and soon enough you should be looking at partial S(q). You can keep doing new selections as each one finishes. Therefore you can already study the temperature dependent trends of partial S(q).





