clear; clc;

addpath('.\gco-v3.0');
addpath('.\gco-v3.0\matlab');
addpath('.\matlab_wmf_release_v1');

dataset = 2;
tmpID = 31;
% Step 1: Image Alignment
wimg = step1_img_align(dataset, tmpID);

% Step 2: Focus Measure
[Mp, Mf, FMs] = step2_focus_measure(wimg);

% Step 3: Grap-cuts
labels = step3_graph_cuts(Mp, Mf, FMs, dataset);

% Step 4: All-in-focus
aif = step4_all_in_focus(labels, wimg);

% Step 5: Depth Refinement
refined_depth = step5_depth_refine(aif, labels, dataset);