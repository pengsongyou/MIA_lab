function result = trans(raw)
% Normalize image to 0-1 range
raw = im2double(raw);
% Inverse the image
inv_raw = 1 - raw;
% Threshold the inverse image
min = 0.975;
max = 0.999;
inv_raw(inv_raw<min) = 0;

% Normalize the detailed region to [0,1] range
inv_raw(inv_raw>=min) = (inv_raw(inv_raw>=min) - min) ./(max-min);

result = imadjust(inv_raw,[0.75 0.92],[]);
result = adapthisteq(result);
end