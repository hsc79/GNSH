clear;
clc;

addpath(genpath('D:\3.long bone\Github_code\Feature point estimation'));

load('PreTrainedNet01.mat')
PN01 = net; clear net;
load('SegtrainedNet_01.mat')
SN01 = net; clear net;

load('PreTrainedNet02.mat')
PN02 = net; clear net;
load('SegtrainedNet_02.mat')
SN02 = net; clear net;

load('PreTrainedNet03.mat')
PN03 = net; clear net;
load('SegtrainedNet_03.mat')
SN03 = net; clear net;

load('PreTrainedNet04.mat')
PN04 = net; clear net;
load('SegtrainedNet_04.mat')
SN04 = net; clear net;

load('PreTrainedNet05.mat')
PN05 = net; clear net;
load('SegtrainedNet_05.mat')
SN05 = net; clear net;

%%
currentFolder = pwd;
imgDir = fullfile(currentFolder,'Ex_data');
listing = dir(imgDir);

num=1;
view = 'L';
dcmName = fullfile(listing(num+2).folder,listing(num+2).name);
[filepath,name,ext] = fileparts(dcmName);

dcm = dicomread(dcmName);
info = dicominfo(dcmName);

if (info.Modality == 'CR')
    dcm_x = uint8(255 * mat2gray(dcm)); %Convert to uint8 format
    dcm_im = histeq(dcm_x);%255 - dcm_x;
else
    dcm_im = uint8(255 * mat2gray(dcm)); %Convert to uint8 format
end
im_size = size(dcm_im);
mask = zeros(im_size(1,1),im_size(1,2),'uint8');
mask(:,1:im_size(1,2)/2) = 1;

J = immultiply(dcm_im,mask);
    
[raw_cc,raw_peak,raw_Line1_2] = first_code_fn(J,PN01,PN02,SN01,SN02,view);
raw_Line1_1 = [raw_cc; raw_peak];

[low_Fpt03,lowFpt_L03,lowFpt_R03,low_Fpt04,lowFpt_L05,lowFpt_R05] = second_code_fn2(J,PN03,PN04,PN05,SN03,SN04,SN05,view);
raw_Line2_1 = [low_Fpt03; low_Fpt04];
raw_Line2_2 = [lowFpt_L03; lowFpt_R03];
raw_Line2_3 = [lowFpt_L05; lowFpt_R05];

result_line_left = [{raw_Line1_1},{raw_Line1_2},{raw_Line2_1},{raw_Line2_2},{raw_Line2_3}];    

%%
figure(1); imshow(dcm_im); hold on;
plot(raw_Line1_1(:,1),raw_Line1_1(:,2),'ro');
plot(raw_Line1_1(:,1),raw_Line1_1(:,2),'r','LineWidth',1);

plot(raw_Line1_2(:,1),raw_Line1_2(:,2),'bo');
plot(raw_Line1_2(:,1),raw_Line1_2(:,2),'b','LineWidth',1);

plot(raw_Line2_1(:,1),raw_Line2_1(:,2),'go');
plot(raw_Line2_1(:,1),raw_Line2_1(:,2),'g','LineWidth',1);

plot(raw_Line2_2(:,1),raw_Line2_2(:,2),'co');
plot(raw_Line2_2(:,1),raw_Line2_2(:,2),'c','LineWidth',1);