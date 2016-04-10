function auc = compute_AUC(rate_list)
auc = 0;
for j = 1 : size(rate_list) - 1
    a = rate_list(j,1);
    b = rate_list(j+1,1);
    h = rate_list(j,2) - rate_list(j+1,2);
    auc = auc + (a + b) * h / 2;        
end
end