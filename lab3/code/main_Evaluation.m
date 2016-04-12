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

display('Finish reading images, now start evaluating algorithms ...');

%% Draw ROC & Calculate AUC
color_list = {'c','m','r','g','b','k'}; % Different colors for plotting
good_thres = zeros(4,6); % Best threshold for each algorithm in each image
good_dist = zeros(4,6); % Smallest distance for each algorithm in each image

thres_step = 4; % differece between two threshold
rate_list = zeros(ceil(256/thres_step),2); % Contain tp and fp rate

for im_num = 1 : 4
    figure;
    hold on;
    txt_list = cell(1,6);
    
    jac_idx = zeros(ceil(256/thres_step),6);
    dice_idx = zeros(ceil(256/thres_step),6);
    for i = 1 : size(im_alg,1)
        threshold = -1;
        num = 1; % The variable for saving (tp,fp) pairs for each threshold
        while threshold < 255
            gd_th = im_manual{im_num}/255; % Ground truth

            % Threshold the current segmented image
            im_now = im_alg{i,im_num};
            im_now(im_now<=threshold) = 0;
            im_now(im_now>threshold) = 1;    

            % True Positive
            tp_image = gd_th .* im_now;
            
            tp_number = sum(sum(tp_image));
            p_number = sum(sum(gd_th));
            tp_rate = tp_number/p_number;
            rate_list(num,1) = tp_rate;
            
            % False Positive
            fp_image = im_now - tp_image;
            fp_number = sum(sum(fp_image));
            n_number = sum(sum(1-gd_th));
            fp_rate = fp_number/n_number;
            rate_list(num,2) = fp_rate;
            
            % Update threshold
            threshold = threshold + thres_step;
            num = num + 1; 
        end
        
        % AUC
        auc = compute_AUC(rate_list);

        % Best threshold of this algorithm for the current image 
        tmp_dist = bsxfun(@minus, rate_list, [1,0]).^2;
        tmp_ed = sqrt(tmp_dist(:,1) + tmp_dist(:,2)); % Euclidean Distance
        idx_best = min(find(tmp_ed == min(tmp_ed)));
        good_thres(im_num,i) = -1 + thres_step * (idx_best - 1);
        good_dist(im_num,i) = tmp_ed(idx_best); 
        
        % Plot ROC
        plot(rate_list(:,2),rate_list(:,1), 'color', color_list{i});
        txt_list{i} = strcat('alg',num2str(i),', auc = ',num2str(auc));
    end

    
    legend(txt_list,'Location','southeast','FontSize',8,'FontWeight','bold');
    ti = sprintf('ROC comparison of different algorithms for the image No. %i',im_num);
    title(ti);
    hold off;
end
%% Compute overlap measures (Jaccard, Dice, Hausdorf)

% Acquire the best threshold for each algorithm
best_dist = min(good_dist);
best_thres = zeros(1,6);
for i = 1 : 6
    idx = find(good_dist(:,i) == best_dist(i));
    best_thres(i) = good_thres(idx,i);
end

jac = zeros(6,4);% Jaccard Index
dice = zeros(6,4);% Dice Index
haus = zeros(6,4);% Hausdorff Distance
for alg_num = 1 : 6
    for i = 1 : 4
        threshold = best_thres(alg_num);
        gd_th = im_manual{i}/255; % Ground truth

        % Threshold the current segmented image
        im_now = im_alg{alg_num,i};
        im_now(im_now<=threshold) = 0;
        im_now(im_now>threshold) = 1;    

        % True Positive
        tp_image = gd_th .* im_now;
        tp_number = sum(sum(tp_image));

        % Compute Jaccard Index
        un = im_now + gd_th; 
        un(un>1) = 1; % union
        if sum(un(:)) ~= 0
            jac(alg_num,i) = tp_number / sum(un(:));
        else
            jac(alg_num,i) = 0;
        end
        % Compute Dice Index
        X = sum(im_now(:));
        Y = sum(gd_th(:));
        if (X + Y) ~= 0
            dice(alg_num,i) = 2*tp_number / (X + Y);
        else
            dice(alg_num,i) = 0;
        end

        % Compute Hausdorf distance
        haus(alg_num,i) = hausdorff(im_now,gd_th);
    end
end

%% Evaluation of 3D images
load 3DSegmentation
[jac3D,dice3D,haus3D] = Evaluate3D(mask,segmentation);
fprintf('\nJaccard Index of the 3D image is : %f \n',jac3D);
fprintf('Dice Index of the 3D image is : %f \n',dice3D);
fprintf('Hausdorff distance of the 3D image is : %f \n',haus3D);