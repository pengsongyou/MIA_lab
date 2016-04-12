function[jac,dice,haus]=  Evaluate3D(mask,segmentation)

tp_image = mask.* segmentation;
tp_number = sum(tp_image(:));

% Compute Jaccard Index
un = segmentation + mask; 
un(un>1) = 1; % union
if sum(un(:)) ~= 0
    jac = tp_number / sum(un(:));
else
    jac = 0;
end
% Compute Dice Index
X = sum(segmentation(:));
Y = sum(mask(:));
if (X+Y) ~= 0
    dice = 2*tp_number / (X + Y);
else
    dice = 0;
end

% Compute Hausdorf distance
haus = hausdorff(segmentation,mask);
end