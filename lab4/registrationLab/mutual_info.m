function e = mutual_info(Imove,Ifix)
    % Get the histograms of both images
    H1 = imhist(Imove,256);
    H2 = imhist(Ifix,256);
    P1 = H1 / numel(Imove);
    P2 = H2 / numel(Ifix);
    
    % Remove 0 elements
    P1(P1==0) = [];
    P2(P2==0) = [];
    
    % Compute entropy of both images
    E1 = -sum(P1.*log2(P1));
    E2 = -sum(P2.*log2(P2));
    
    % Calculate the joint histogram
    
    h = joint_hist(Imove,Ifix);
    
    % Calculate joint entropy
    h = h./numel(h);
%     E_tmp = 0;
%     for i = 1 : 256
%         for j = 1 : 256
%             if h(i,j) ~= 0
%                 E_tmp = E_tmp - h(i,j) * log2(h(i,j));
%             end
%         end
%     end
    
    h(h == 0) = [];
    E_joint = -sum(h.*log2(h));
    
    % Mutual information 
    e = -(E1 + E2 - E_joint);
    
    
    % Test
%     p1 = H1 / numel(Imove);
%     p2 = H2 / numel(Ifix);
%     h = joint_hist(Imove,Ifix);
%     h = h./numel(h);
%     e_tmp = 0;
%     for m = 1 : 256
%         if p1(m) ~= 0
%             for n = 1 : 256
%                 if h(m,n) ~= 0 && p2(n) ~= 0
%                     e_tmp = e_tmp + h(m,n) * log2(h(m,n) / ((p1(m) * p2(n))));
%                 end
%             end
%         end
%     end
    
end

function h = joint_hist(Imove,Ifix)
    Imove = im2uint8(Imove);
    Ifix = im2uint8(Ifix);
    rows = size(Imove, 1);
    cols = size(Imove, 2);
    N = 256;

    h = zeros(N, N);

    for i = 1 : rows;   
      for j = 1 : cols;   
        h(Imove(i,j)+1,Ifix(i,j)+1)= h(Imove(i,j)+1,Ifix(i,j)+1)+1;
      end
    end
end
