Extended Lucas-Kanade Tracking
===============================

Version: 	1.0
Date:    	02/09/2014
Publisher: 	Shaul Oron (shauloron (at) gmail (dot) com)

THIS IS RESEARCH CODE USE AT YOUR OWN RISK !

THIS CODE IS DISTRIBUTED UNDER GNU GPL LICENSE http://www.gnu.org/copyleft/gpl.html

=====================================================================

Related publications:
------------------------

If you are using some/all of this code package please cite:
@inproceedings{Oron2014ELK,
  title={Extended Lucas Kanade Tracking},
  author={Oron, S. and Bar-Hillel, A. and Avidan, S.},
  booktitle={European Conference on Computer Vision (ECCV)},
  pages={},
  year={2014},
  organization={Springer}
}

The code distributed here also makes use of: 
VL-feat 0.9.18 http://www.vlfeat.org/
@misc{vedaldi08vlfeat,
	Author = {A. Vedaldi and B. Fulkerson},
	Title = {{VLFeat}: An Open and Portable Library
			of Computer Vision Algorithms},
	Year  = {2008},
	Howpublished = {\url{http://www.vlfeat.org/}}
and 
Pioter Dollars toolbox 
 http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html
   @misc{PMT, 
   author = {Piotr Doll\'ar}, 
   title = {{P}iotr's {I}mage and {V}ideo {M}atlab {T}oolbox ({PMT})}, 
   howpublished = {\url{http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html}} 
   } 
   
=====================================================================

Content:
--------------
1) ELK code
2) Redistribution of VL-feat 0.9.18 http://www.vlfeat.org/	
3) Redistribution of Pioter Dollars toolbox http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html   
4) ELK results for CVPR 2013 tracking benchmark [1] (see below)
5) One demo sequence 

=====================================================================

Getting started:
--------------------
1) Unzip
2) Run init.m (in Matlab)
3) Go to ELK_tracker folder and run ELK_tracker_main.m
4) You can view tracking results off-line using the play_tracking_reuslts_offline.m utility

Note:
- init.m will try to compile required mex files (complied files are available in win64 only)

=====================================================================

Running CVPR 2013 data:
------------------------
- CVPR 2013 benchmark [1] can be downloaded from http://visual-tracking.net/
- For running ELK on the dataset use run_ELK_on_CVPR_data (configure I/O dirs)
- Results can be analyzed using analyze_cvpr_results.m (configure I/O dirs)
- Results can also be converted to the benchmark result format using convert_results_to_cvpr_format.m

[1] “Online Object Tracking: A Benchmark", Yi Wu, Jongwoo Lim, and Ming-Hsuan Yang, CVPR 2013