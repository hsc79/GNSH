clear; clc;

%% ROI size calculation
maskDir = fullfile('D:\3.long bone\Github_code\Segmentation\Ex_dataset_01','mask_image_pad');
maskimds = imageDatastore(maskDir);

for num=1:size(maskimds.Files,1)
    mask_imFilename = maskimds.Files{num};
    mask_raw = imread(mask_imFilename);
    
    maskIm = rgb2gray(mask_raw);
    maskIm  = im2bw(maskIm);
    
    s  = regionprops(maskIm,'Area','BoundingBox');
    
    Area_x = cat(1, s.Area);
    if (size(Area_x,1) > 1)
        [val,idx] = max(Area_x)
        id_num = num
        box_x = cat(1, s.BoundingBox);
        box(num,:) = box_x(idx,:);
    else
        box(num,:) = cat(1, s.BoundingBox);
    end
end

[x_max,id_x] = max(box(:,3));
[y_max,id_y] = max(box(:,4));

%% ROI image gen
maskDir = fullfile('D:\3.long bone\Github_code\Segmentation\Ex_dataset_01','mask_image_pad');
maskimds = imageDatastore(maskDir);
m_path = 'D:\3.long bone\Github_code\Segmentation\Ex_dataset_01\mask_image_ROI';

imgDir = fullfile('D:\3.long bone\Github_code\Segmentation\Ex_dataset_01','raw_image_pad');
imds = imageDatastore(imgDir);
path = 'D:\3.long bone\Github_code\Segmentation\Ex_dataset_01\raw_image_ROI';
%%
for num=1%:size(maskimds.Files,1)
    mask_imFilename = maskimds.Files{num};
    mask_raw = imread(mask_imFilename);
    
    maskIm = rgb2gray(mask_raw);
    maskIm  = im2bw(maskIm);
    
    s  = regionprops(maskIm,'Area','centroid');
    Area_x = cat(1, s.Area);
    if (size(Area_x,1) > 1)
        [val,idx] = max(Area_x)
        roi_id = idx;
    else
        roi_id = 1;
    end
    
    centroids = cat(1, s.Centroid);
    %
    imFilename = imds.Files{num};
    I_raw = imread(imFilename);
    
    x_len = 730;
    y_len = 470;
    box = [centroids(roi_id,1)-(x_len/2) centroids(roi_id,2)-(y_len/2) x_len-1 y_len-1]; 
    cropIm_raw = imcrop(I_raw,box);
    crop_mask = imcrop(maskIm,box);
    crop_mask = crop_mask .* 255;
    cropIm_mask = cat(3, crop_mask, crop_mask, crop_mask);

    %%
    [filepath_m,name_m,ext_m] = fileparts(mask_imFilename);
    [filepath,name,ext] = fileparts(imFilename);
    
    baseFileName_m = sprintf('%s%s',name_m,ext_m);
    baseFileName = sprintf('%s%s',name,ext);
    
    fullFileName_m = fullfile(m_path, baseFileName_m); 
    imwrite(cropIm_mask,fullFileName_m);
    
    fullFileName = fullfile(path, baseFileName); 
    imwrite(cropIm_raw,fullFileName);
end



