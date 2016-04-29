function [ Iregistered, M] = affineReg2D( Imoving, Ifixed )
%Example of 2D affine registration
%   Robert Mart?  (robert.marti@udg.edu)
%   Based on the files from  D.Kroon University of Twente 

clear all; close all; clc;

% % Read two imges 
Imoving=im2double(imread('lenag1.png')); 
Ifixed=im2double(imread('lenag2.png'));

% % Smooth both images for faster registration
ISmoving=imfilter(Imoving,fspecial('gaussian'));
ISfixed=imfilter(Ifixed,fspecial('gaussian'));

mtype = 'sd'; % metric type: sd: ssd m: mutual information e: entropy 
ttype = 'a'; % rigid registration, options: r: rigid, a: affine

switch ttype
    case 'r' %squared differences
        % Parameter scaling of the Translation and Rotation
        scale=[10 10 1];
        % Set initial affine parameters
        x = [0 0 0]; % For affine tranformation
    case 'a'
        % Parameter scaling of the Translation and Rotation
        scale=1.*[1 1 100 1 1 100];
        % Set initial affine parameters
        x = [1 0 0 0 1 0]; % For affine tranformation

    otherwise
        error('Unknown registration type');
end;

x=x./scale;
tic    
[x]=fminsearch(@(x)affine_function(x,scale,ISmoving,ISfixed,mtype,ttype),x,optimset('Display','iter','MaxIter',1000, 'TolFun', 1.000000e-06,'TolX',1.000000e-06, 'MaxFunEvals', 1000*length(x)));
toc
% Scale the translation, resize and rotation parameters to the real values
x=x.*scale;


switch ttype
    case 'r' %squared differences
         M=[ cos(x(3)) sin(x(3)) x(1);
            -sin(x(3)) cos(x(3)) x(2);
             0 0 1];
    case 'a'
        M = [x(1) x(2) x(3); 
             x(4) x(5) x(6); 
             0 0 1];
    otherwise
        error('Unknown registration type');
end;


% Transform the image 
Icor=affine_transform_2d_double(double(Imoving),double(M),0); % 3 stands for cubic interpolation

% Show the registration results
figure,
    subplot(2,2,1), imshow(Ifixed);
    subplot(2,2,2), imshow(Imoving);
    subplot(2,2,3), imshow(Icor);
    subplot(2,2,4), imshow(abs(Ifixed-Icor));

% Iregistered = Icor;
end

