function bb = mmbox(bbss)
if (isempty(bbss))
    bb = []; 
    return; 
end
bb = [ min(bbss(:,1)), ...
           min(bbss(:,2)), ...
           max(bbss(:,1) + bbss(:,3)), ...
           max(bbss(:,2) + bbss(:,4)) ];
bb = [bb(1:2), bb(3:4) - bb(1:2)];
