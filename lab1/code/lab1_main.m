clc
close all;
clear;
%% Load the image
dir_pre = '../MAMMOGRAPHY_PRESENTATION.dcm';
dir_raw = '../MAMMOGRAPHY_RAW.dcm';
dir_ul = '../ultrasound.DCM';
pre = dicomread(dir_pre);
pre_info = dicominfo(dir_pre);

raw = dicomread(dir_raw);
raw_info = dicominfo(dir_raw);

ul = dicomread(dir_ul);
ul_info = dicominfo(dir_ul);

dir_mri = '../MRI/';
mri = [];
for i = 1 : 22
    if i < 10
        name = sprintf('MRI0%d.dcm',i);
    else
        name = sprintf('MRI%d.dcm',i);
    end
    im_dir = strcat(dir_mri,name);
    mri(:,:,i) = dicomread(im_dir);
end
mri_info = dicominfo(strcat(dir_mri,'MRI01.dcm'));

%% 2.1
disp('Question 2.1: dimension of each modality');
disp(' ');
% X-ray
disp(['The dimensionality of X-ray images (Raw and Presentation) is ',num2str(pre_info.Height), '*',num2str(pre_info.Width)]);
disp(['The number of pixel of X-ray images (Raw and Presentation) is: ', num2str(double(pre_info.Height)*double(pre_info.Width))]);
MAMMOGRAPHY_PRESENTATION_pixel_size = pre_info.PixelSpacing;
MAMMOGRAPHY_RAW_pixel_size = raw_info.PixelSpacing;
disp(['The pixel size of X-ray images (Raw and Presentation) is: x direction ', num2str(MAMMOGRAPHY_PRESENTATION_pixel_size(1)),', y direction ',num2str(MAMMOGRAPHY_PRESENTATION_pixel_size(2))]);
disp(' ');

% Ultrasound
disp(['The dimensionality of ultrasound is ',num2str(ul_info.Height), '*',num2str(ul_info.Width)]);
disp(['The number of ultrasound is: ', num2str(double(ul_info.Height) * double(ul_info.Width))]);
disp('There is not pixel size information for ultrasound image');
disp(' ');

% MRI
[height, width, depth] = size(mri);
mri_pixel_size = mri_info.PixelSpacing;
sbs = mri_info.SpacingBetweenSlices;
disp(['The dimensionality of MRI image is: ',num2str(mri_info.Height),'*',num2str(mri_info.Width),'*',num2str(depth)]);
disp(['The number of pixel of MRI is: ', num2str(height*width*depth)]);
disp(['The pixel size of MRI images is: x direction ', num2str(mri_pixel_size(1)),', y direction ',num2str(mri_pixel_size(2)), ', z direction ', num2str(sbs)]);
disp(' ');
%% 2.2
disp('Question 2.2: verify the files are anonymized');
disp(' ');
raw_man_name = raw_info.PatientName.FamilyName;
pre_man_name = pre_info.PatientName.FamilyName;
ul_name = ul_info.PatientName.FamilyName;
mri_name = mri_info.PatientName.FamilyName;
disp(['The patient name of X-ray (Raw) image is: ',raw_man_name]);
disp(['The patient name of X-ray (Presentation) image is: ',pre_man_name]);
disp(['The patient name of ultrasound image is: ',ul_name]);
disp(['The patient name of MRI image is: ',mri_name]);
disp(' ');
%% 2.3
disp('Question 2.3: MRI histogram');
figure;h_mri = histogram(mri);
disp(' ');
%% 2.4
disp('Question 2.4: Axial, coronal and sagital of MRI');
disp(' ');
[height, width, depth] = size(mri);
sbs = mri_info.SpacingBetweenSlices;
ps = mri_info.PixelSpacing;

% xy axial view
figure;
axial = mri(:,:,11);
imshow(axial,[],'InitialMagnification','fit');
title('Axial');
% xz sagittal view
a = mri(:,floor(width/2),:);
b(1:height,1:depth) = a(:,1,:);
sagittal = imresize(b,[height, depth*sbs/ps(1)]);
figure;
imshow(sagittal,[],'InitialMagnification','fit');
title('Sagittal');
% yz coronal view
a = mri(floor(height/2),:,:);
b(1:width,1:depth) = a(1,:,:);
coronal = imresize(b,[width, depth*sbs/ps(2)]);
figure;
imshow(coronal,[],'InitialMagnification','fit');
title('Coronal');

%% 2.5
disp('Transformation');
result = trans(raw);
figure;imshow(result,[],'InitialMagnification','fit');
