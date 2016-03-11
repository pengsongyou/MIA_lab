close all;
clear;
clc;

dir_pre = '../MAMMOGRAPHY_PRESENTATION.dcm';
dir_raw = '../MAMMOGRAPHY_RAW.dcm';
pre = dicomread(dir_pre);
pre_info = dicominfo(dir_pre);

raw = dicomread(dir_raw);
raw_info = dicominfo(dir_raw);



% figure;
% imshow(pre,[]);
% title('Presentation Mammography Image');


raw = im2double(raw);
inv_raw = 1 - raw;
% 0.948 - 0.998
min = 0.975;
max = 0.999;
inv_raw(inv_raw<min) = 0;

% tmp = inv_raw;
% tmp(tmp>=min) = inv_raw(inv_raw>=min) - min./(max-min);
inv_raw(inv_raw>=min) = (inv_raw(inv_raw>=min) - min) ./(max-min);

% w = stretchlim(inv_raw);
result = imadjust(inv_raw,[0.75 0.92],[]);
result = adapthisteq(result);
imshow(result,[]);