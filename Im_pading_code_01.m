clear;
clc;

%% raw image re-sizing
% Get the full path for the folder containing all the raw images
imgDir = fullfile('D:\3.long bone\Github_code\Segmentation','EX_rawdata');
path1 = 'D:\3.long bone\Github_code\Segmentation\Ex_dataset_01\raw_image_pad';
path2 = 'D:\3.long bone\Github_code\Segmentation\Ex_dataset_01\raw_image_resize';
% 
% Load the images located in the above path using imageDatstore - ML Function
imds = imageDatastore(imgDir);

re_X = 3107;
re_Y = 9314;

for num=1%:size(imds.Files,1)
    imageFilename = imds.Files{num};
    I_raw = imread(imageFilename);
    im_size = size(I_raw);
    
    [filepath,name,ext] = fileparts(imageFilename);
    baseFileName = sprintf('%s%s',name,ext);
    
    [Bxy,dif_y,dif_x,px,py] = pad_im_fn(I_raw,im_size,re_Y,re_X);
    B = imresize(Bxy,1/10,'nearest');
    
    fullFileName1 = fullfile(path1, baseFileName); 
    imwrite(Bxy,fullFileName1);
    
    fullFileName2 = fullfile(path2, baseFileName); 
    imwrite(B,fullFileName2);
end

%% mask image preprocess
% Get the full path for the folder containing all the raw images
maskDir = fullfile('D:\3.long bone\Github_code\Segmentation','EX_maskdata');
m_path1 = 'D:\3.long bone\Github_code\Segmentation\Ex_dataset_01\mask_image_pad';
m_path2 = 'D:\3.long bone\Github_code\Segmentation\Ex_dataset_01\mask_image_resize';
% 
% Load the images located in the above path using imageDatstore - ML Function
M_imds = imageDatastore(maskDir);

for num=1%:size(M_imds.Files,1)
    maskFilename = M_imds.Files{num};
    I = imread(maskFilename);
    BW = imfill(I,'holes');
    BW = BW .* 255;
    
    im_size_m = size(BW);
    newImage = cat(3, BW, BW, BW);
    
    [filepath_m,name_m,ext_m] = fileparts(maskFilename);
    baseFileName_m = sprintf('%s%s',name_m,ext_m);
    
    [Bxy_m,dif_y_m,dif_x_m,px_m,py_m] = pad_im_fn(newImage,im_size_m,re_Y,re_X);
    B_m = imresize(Bxy_m,1/10,'nearest');
    
    fullFileName1_m = fullfile(m_path1, baseFileName_m); 
    imwrite(Bxy_m,fullFileName1_m);
    
    fullFileName2_m = fullfile(m_path2, baseFileName_m); 
    imwrite(B_m,fullFileName2_m);
end