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

% imshow(mri);
% imcontrast;

%% 2.1
MAMMOGRAPHY_PRESENTATION_pixel_size = pre_info.PixelSpacing
MAMMOGRAPHY_RAW_pixel_size = raw_info.PixelSpacing
MRI_pixel_size = mri_info.PixelSpacing

%% 2.3
h_mri = histogram(mri);

%% 2.4
[height, width, depth] = size(mri);
sbs = mri_info.SpacingBetweenSlices;
ps = mri_info.PixelSpacing;

% xy axial view
figure;
axial = mri(:,:,11);
imshow(axial,[],'InitialMagnification','fit');
title('Axial');
% xz sagittal view
a = mri(:,256,:);
b(1:height,1:depth) = a(:,1,:);
sagittal = imresize(b,[height, depth*sbs/ps(1)]);
figure;
imshow(sagittal,[],'InitialMagnification','fit');
title('Sagittal');
% yz coronal view
a = mri(256,:,:);
b(1:width,1:depth) = a(1,:,:);
coronal = imresize(b,[width, depth*sbs/ps(2)]);
figure;
imshow(coronal,[],'InitialMagnification','fit');
title('Coronal');

%% 2.5
% figure;
% imshow(raw,[],'InitialMagnification','fit');
% title('Raw Mammography Image');
figure;
imshow(pre,[]);
title('Presentation Mammography Image');


raw = double(raw);

% minVal = min(min(raw));
% maxVal = max(max(raw));
% norm_data = (raw - minVal) ./ ( maxVal - minVal );

chop = raw;
chop(chop>4000) = 0;
minVal = min(min(chop));
maxVal = max(max(chop));
norm_data = (chop - minVal) ./ ( maxVal - minVal );

% norm_data = 1 - norm_data;
% norm_data(norm_data<0.8) = 0;


w = stretchlim(norm_data);
result = imadjust(norm_data,w,[]);

result = adapthisteq(result,'Distribution','exponential');
% result = adapthisteq(result,'Distribution','exponential');
% result(result == 1) = 0;


% result = imhistmatch(chop,pre);
% c = 1/log(2);
% result = c .* log(1+norm_data);

figure;
subplot(221);imshow(norm_data);
subplot(222);histogram(norm_data)
subplot(223);imshow(result)
subplot(224);histogram(result)
