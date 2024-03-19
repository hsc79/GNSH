clear; clc;

% Get the full path for the folder containing all the raw images
imgDir = fullfile('D:\3.long bone\Github_code\Segmentation\Ex_dataset_01','raw_image_ROI');
% Load the images located in the above path using imageDatstore - ML Function
imds = imageDatastore(imgDir);

% Suppress image display warnings
warning('off','images:initSize:adjustingMag')
pic_num = 1;
I_raw = readimage(imds, pic_num);

% Because images are dark histogram equalization is performed. - Image Processing toolbox
% figure
% imshow(I_raw)
% drawnow
% title('Raw image')

I = histeq(I_raw); 
figure
imshow(I)
drawnow
title('Raw image with equalized histogram')

classes = [
    "Background"
    "Object"
    ];

labelIDs = labelID_fn();

% Create the full path to the directory that contains the ground truth pictures.
labelDir = fullfile('D:\3.long bone\Github_code\Segmentation\Ex_dataset_01','mask_image_ROI');
% This function works similarly to imageDatastore. Instead it returns a datastore object that can be used to read pixel label data. - Computer Vision System Toolbox
pxds = pixelLabelDatastore(labelDir,classes,labelIDs);

% % Create a custom colormap to color each label in a different way
% cmap = HelperFunctions.camvidColorMap;
cmap = [
    100 100 100     
    0 255 255     
    ];
% Normalize between [0 1].
cmap = cmap ./ 255;

C = readimage(pxds, pic_num);
% Overlay segmentation results onto original image. - Computer Vision System Toolbox
B = labeloverlay(I,C,'ColorMap',cmap);
figure
imshow(B) 
pixelLabelColorbar(cmap,classes);

%%
tbl = countEachLabel(pxds);
% We calculate the frequency in order to get a histogram of the data
frequency = tbl.PixelCount/sum(tbl.PixelCount);

[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionData_mix(imds,pxds);
% 
%%
imageSize = [470 730 3]; %이미지 정보와 반대로 입력
numClasses = numel(classes);
% segnetLayers returns SegNet network layers, lgraph, that is preinitialized with layers and weidghts from a pretrained model.
lgraph = segnetLayers(imageSize,numClasses,'vgg16');

% Get the imageFreq using the data from the countEachLabel function
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
% The higher the frequency of a class the smaller the classWeight
classWeights = median(imageFreq) ./ imageFreq

pxLayer = pixelClassificationLayer('Name','labels','ClassNames', tbl.Name, 'ClassWeights', classWeights);

% Remove last layer of and add the new one we created. 
lgraph = removeLayers(lgraph, {'pixelLabels'});
lgraph = addLayers(lgraph, pxLayer);
% Connect the newly created layer with the graph. 
lgraph = connectLayers(lgraph, 'softmax','labels');
lgraph.Layers

pximdsVal = pixelLabelImageDatastore(imdsVal,pxdsVal);


options = trainingOptions('sgdm', ... % This is the solver's name; sgdm: stochastic gradient descent with momentum
    'Momentum', 0.9, ...              % Contribution of the gradient step from the previous iteration to the current iteration of the training; 0 means no contribution from the previous step, whereas a value of 1 means maximal contribution from the previous step.
    'InitialLearnRate', 1e-2, ...     % low rate will give long training times and quick rate will give suboptimal results 
    'L2Regularization', 0.0005, ...   % Weight decay - This term helps in avoiding overfitting
    'ValidationData',pximdsVal,...    
    'MaxEpochs', 120,...              % An iteration is one step taken in the gradient descent algorithm towards minimizing the loss function using a mini batch. An epoch is the full pass of the training algorithm over the entire training set.
    'MiniBatchSize', 2, ...           % A mini-batch is a subset of the training set that is used to evaluate the gradient of the loss function and update the weights.
    'Shuffle', 'every-epoch', ...     % Shuffle the training data before each training epoch and shuffle the validation data before each network validation.
    'Verbose', false,...        
    'Plots','training-progress');   

augmenter = imageDataAugmenter('RandXReflection',true,...
    'RandXTranslation', [-10 10], 'RandYTranslation',[-10 10]);

%% start training
datasource = pixelLabelImageSource(imdsTrain,pxdsTrain,...
    'DataAugmentation',augmenter);

% parpool('local',2)

% To avoid having to re-train, you can use the pretrained model
% Contact image-processing@mathworks.com for access
% Trains a network for image classification problems
tic
[net, info] = trainNetwork(datasource,lgraph,options);
toc


% save('SegtrainedNet_08_1.mat','net','info','options');