function [imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionData_mix(imds,pxds)
% Partition CamVid data by randomly selecting 60% of the data for training. The
% rest is used for testing.
    
% Set initial random state for example reproducibility.
rng(0); 
numFiles = numel(imds.Files);

num_list = num_list_gen(numFiles,imds,3);

g01_idx = (find(num_list == 126))-1;
g02_idx = (find(num_list == 249))-g01_idx-1;
g03_idx = (find(num_list == 362))-g01_idx-g02_idx-1;
g04_idx = size(num_list,1)-g01_idx-g02_idx-g03_idx;

[trainIdx01,valIdx01,testIdx01] = data_idx_fn(0,g01_idx);
[trainIdx02,valIdx02,testIdx02] = data_idx_fn(g01_idx,g02_idx);
[trainIdx03,valIdx03,testIdx03] = data_idx_fn(g01_idx+g02_idx,g03_idx);
[trainIdx04,valIdx04,testIdx04] = data_idx_fn(g01_idx+g02_idx+g03_idx,g04_idx);

trainingIdx = [trainIdx01 trainIdx02 trainIdx03 trainIdx04];
valIdx = [valIdx01 valIdx02 valIdx03 valIdx04];
testIdx = [testIdx01 testIdx02 testIdx03 testIdx04];

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
valImages = imds.Files(valIdx);
testImages = imds.Files(testIdx);

imdsTrain = imageDatastore(trainingImages);
imdsVal = imageDatastore(valImages);
imdsTest = imageDatastore(testImages);

% Extract class and label IDs info.
classes = pxds.ClassNames;
labelIDs = labelID_fn();

% Create pixel label datastores for training and test.
trainingLabels = pxds.Files(trainingIdx);
valLabels = pxds.Files(valIdx);
testLabels = pxds.Files(testIdx);

pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
pxdsVal = pixelLabelDatastore(valLabels, classes, labelIDs);
pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);
end