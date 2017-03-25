# tleAnalysis

See the Wiki ([click here](https://github.com/mfacchinelli/tleAnalysis/wiki)) to have more information on this project.

***

Main file:
- `main.m`:          MATLAB file used to run functions and as interface between functions

Included functions for TLE analysis:
- `correctTLE.m`:    MATLAB function for correcting TLE files with overlapping elements
- `downloadTLE.m`:   MATLAB function to download TLEs from space-track.org
- `propagateTLE.m`:  MATLAB function to propagate Keplerian elements using SPG4
- `readTLE.m`:       MATLAB function for reading TLE files and plotting Keplerian elements over time
- `statTLE.m`:       MATLAB function to collect statistical information on TLEs
- `thrustTLE.m`:     MATLAB function to detect thrust
 
Other functions:
- `constants.m`:     MATLAB function to load constants
- `cart2kepl.m`:     MATLAB function to convert from Cartesian coordinates to Keplerian elements
- `plotAll.m`:       MATLAB function to plot results
- `subplotTitle.m`:  MATLAB function for adding a title to the whole subplot
 
Included folders:
- `documentation`:  sources of information (bibliography)
- `figures`:        plots of Keplerian elements of spacecraft under `files`
- `files`:          various text files filled with TLE lines of various spacecraft or debris
- `functions`:      functions used for the analysis of TLE file
- `propagation`:    functions used for propagation of TLEs
