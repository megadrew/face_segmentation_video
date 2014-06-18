README

face_segmentation_video
=======================

by Andrew Kae

This package contains code in support of the paper:

Andrew Kae, Benjamin Marlin, and Erik Learned-Miller
The Shape-Time Random Field for Semantic Video Labeling.
IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2014.

Included in this package:

common/  
	common set of files used by all models.
folds/
	set of training/test/validation files for 5 folds.
lib/
	model files used to run code.
params/
	parameter settings used by the models.
scripts/
	common set of scripts used to run the code.
utils/
	common set of "utility" scripts used by all models.
README.md : this file

Directions

1) Download the data associated with the paper at:

http://vis-www.cs.umass.edu/STRF/index.html

2) Edit scripts/startup_directory.m to match your own system.

3) Run drive_models.m with the model of your choice.  This script takes a parameter setting and a model.
For example run

> drive_models('../params/param_test_strf', 'strf') 

in order to test the STRF model.

The available models are:
	* scrf
	* scrf_temporal
	* scrf_rbm
	* scrf_rbm_temporal
	* scrf_crbm
	* strf

If you have additional questions, please email me at akae @ cs . umass . edu (ignore spaces).



* Copyright (c) 2014, Andrew Kae, UMass-Amherst
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the author nor the organization may be used to 
*       endorse or promote products derived from this software without specific 
*       prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY Andrew Kae ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
