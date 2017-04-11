# tleAnalysis

See the Wiki (click [here](https://github.com/mfacchinelli/tleAnalysis/wiki)) to have more information on this project. A video tutorial is available on YouTube, by clicking [here](https://youtu.be/2I0SXzgqR7w).

***

Main file:
- `main.m`:          MATLAB file used to run functions and as interface between functions

Included functions for TLE analysis:
- `correctTLE.m`:    MATLAB function for correcting TLE files with overlapping elements
- `downloadTLE.m`:   MATLAB function to download TLEs from space-track.org 
- `errorsTLE.m`:   MATLAB function to analyze error sources in propagation and find correlations between errors and spacecraft parameters
- `peaksTLE.m`:  MATLAB function to find peaks in TLE observations
- `propagateTLE.m`:  MATLAB function to propagate Keplerian elements using SGP4
- `readTLE.m`:       MATLAB function for reading TLE files and plotting Keplerian elements over time
- `SGP4.m`:       MATLAB representation of SGP4 propagator 
- `statTLE.m`:       MATLAB function to collect statistical information on TLEs
- `thrustTLE.m`:     MATLAB function to detect thrust
 
Other functions:
- `cart2kepl.m`:     MATLAB function to convert from Cartesian coordinates to Keplerian elements
- `chauvenet.m`:     MATLAB function to apply Chauvenet's criterion to remove outliers
- `constants.m`:     MATLAB function to load constants
- `mergeArrays.m`:       MATLAB function to merge arrays at alternating indices
- `plotAll.m`:       MATLAB function to plot results
- `settings.m`:       MATLAB function to set options
- `subplotTitle.m`:  MATLAB function for adding a title to the whole subplot
 
Included folders:
- `documentation`:  sources of information (bibliography)
- `files`:          various text files filled with TLE lines of various spacecraft or debris
- `functions`:      functions used for the analysis of TLE file
- `propagation`:    functions used for propagation of TLEs
