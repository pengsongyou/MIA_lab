close all
clc
clear

%% Read images
dir_2D = '../examples/';
% Read images in the alg folder
for i = 1 : 6
    dir_alg = strcat('/alg',num2str(i));
    dir_cur = fullfile(dir_2D,dir_alg,'/','*.tif');
    theFiles = dir(dir_cur);
    for j = 1 : length(theFiles)
        base_name = theFiles(j).name;
        full_name = fullfile(dir_2D,dir_alg,'/',base_name);
        fprintf(1,'Reading %s \n',full_name);
        im_alg{i,j} = double(imread(full_name));
    end
end

% Read original images
dir_cur = fullfile(dir_2D,'images/','*.tif');
theFiles = dir(dir_cur);
for j = 1 : length(theFiles)
    base_name = theFiles(j).name;
    full_name = fullfile(dir_2D,'images/',base_name);
    fprintf(1,'Reading %s \n',full_name);
    im_original{j} = double(imread(full_name));
end

% Read manual image
dir_cur = fullfile(dir_2D,'manual/','*.tif');
theFiles = dir(dir_cur);
for j = 1 : length(theFiles)
    base_name = theFiles(j).name;
    full_name = fullfile(dir_2D,'manual/',base_name);
    fprintf(1,'Reading %s \n',full_name);
    im_manual{j} = double(imread(full_name));
end

%% Draw ROC
im_num = 4; % The number of the image that we want to evaluate
thres_step = 5; % differece between two threshold
figure; 
for i = 1 : size(im_alg,1)
    threshold = 0;
    while threshold < 255
        hold on;
        gd_th = im_manual{im_num}/255; % Ground truth
        
        % Threshold the current segmented image
        im_now = im_alg{i,im_num};
        im_now(im_now<=threshold) = 0;
        im_now(im_now>threshold) = 1;    
        %imshow(test);
        %figure;imshow(im_manual{1});

        % True Positive
        tp_image = gd_th .* im_now;
        %figure;imshow(tp_image);

        tp_number = sum(sum(tp_image));
        p_number = sum(sum(gd_th));
        tp_rate = tp_number/p_number;

        % False Positive
        fp_image = im_now - tp_image;
        fp_number = sum(sum(fp_image));
        n_number = sum(sum(1-gd_th));
        fp_rate = fp_number/n_number;
        % figure;imshow(fp_image);
        
        % Update threshold
        threshold = threshold + thres_step;
        
        % Plot the ROC
        subplot(3,2,i);plot(fp_rate,tp_rate,'r*');
    end
    tit_current = strcat('alg',num2str(i)); 
    title(tit_current);
    hold off
end