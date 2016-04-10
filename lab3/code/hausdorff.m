function dist = hausdorff(im1,im2)

% First get the boundary image
edge1 = zeros(size(im1));
edge2 = zeros(size(im2));
for i = 1 : size(im1,3)
    edge1(:,:,i) = edge(im1(:,:,i),'canny');
    edge2(:,:,i) = edge(im2(:,:,i),'canny');
end

% Get the index of nonzero element
idx1 = zeros(nnz(edge1),3);
idx2 = zeros(nnz(edge2),3);
[idx1_h,idx1_w,idx1_d] = ind2sub(size(edge1),find(edge1 ~= 0));
[idx2_h,idx2_w,idx2_d] = ind2sub(size(edge2),find(edge2 ~= 0));
idx1 = [idx1_h,idx1_w,idx1_d];
idx2 = [idx2_h,idx2_w,idx2_d];

% Compute the distance
if size(idx1,1) ~= 0 && size(idx2,1) ~= 0
    dist1 = comp_dist(idx1,idx2);
    dist2 = comp_dist(idx2,idx1);
else
    dist1 = -1;% Invalid
    dist2 = -1;
end

dist = max([dist1,dist2]);
end

function dist = comp_dist(idx1,idx2)
dist_list = zeros(size(idx1,1),1);

for i = 1 : size(idx1,1)
    a = bsxfun(@minus,idx2,idx1(i,:,:)).^2;    
    ed = sqrt(a(:,1) + a(:,2) + a(:,3)); % Euclidean distance
    dist_list(i) = min(ed);
end
dist = max(dist_list);
end