function charWords = mySelectGroup(box)
% input: box = [x, y, w, h]
% groups: 
% --groups.box: box [n*4]
% --groups.idxGroup: idx in the groups [n*1]
% --groups.nLine: number of lines in the groups
% --groups.line(k).nBox: number of box in the k-th line
% --groups.line(k).idxBox: idx in the box [groups.line(k).nBox*1]

%% rules for groupsing 
%{
1. position of center
   y: abs(iy - jy) < max(ih, jh) * M_CY = 0.2
   x: abs(icx - jcx) < max(jw, iw) * M_CX = 2
2. ratio of height
   max(ih, jh)/min(ih, jh) < M_H = 1.5
3. ratio of width
   max(iw, jw)/min(iw, jw) < M_W = 3
%}

%% paras
M_CX = 2;
M_CY = 0.2;
M_H = 3;
M_W = 2;
%% init paras
m = size(box, 1);
if m < 1
    charWords = [];
    return;
end
line = zeros(m, 1);
nk = 0; %number fo line
%% group
box  =  sortrows(box);
groups.box = box;
groups.idxGroup = zeros(m, 1);
for i = 1:m
    if( line(i) > 0 )
        continue;
    end
    ix = box(i, 1); 
    iy = box(i, 2); 
    iw = box(i, 3); 
    ih = box(i, 4);
    icx  =  (ix + iw) / 2;
    icy  =  (iy + ih) / 2;
    %group the box(i) to the nk-th line
    nk = nk+1;
    line(i) = nk;
 
    tempGroup(nk).width = iw;
    tempGroup(nk).height = ih;
    tempGroup(nk).cy = icy;
    tempGroup(nk).rcx = icx; 
    
    groups.idxGroup(i) = nk;
    groups.line(nk).nBox = 1;
    groups.line(nk).idxBox = i;
    groups.nLine = nk;
    %the center-x of the most right character in the nk-th line
    for j = i+1:m
        if( line(j) > 0 )
            continue;
        end
        jx = box(j, 1); 
        jy = box(j, 2); 
        jw = box(j, 3); 
        jh = box(j, 4);
        jcx = (jx + jw) / 2;
        jcy = (jy + jh) / 2;
        if( abs(tempGroup(nk).cy - jcy) <= max(tempGroup(nk).height, jh) * M_CY && ...
            abs(tempGroup(nk).rcx - jcx) <= max(tempGroup(nk).width, jw) * M_CX && ...
            max(tempGroup(nk).height, jh) / min(tempGroup(nk).height, jh) <= M_H && ...
            max(tempGroup(nk).width, jw) / min(tempGroup(nk).width, jw) <= M_W )
            % group the box(j) to the nk-th line
            line(j) = nk;
            
            tempGroup(nk).width = (tempGroup(nk).width + jw) / 2;
            tempGroup(nk).height = (tempGroup(nk).height + jh) / 2;
            tempGroup(nk).cy = (tempGroup(nk).cy + jcy) / 2;
            if( tempGroup(nk).rcx < jcx )
                tempGroup(nk).rcx = jcx;
            end
            
            groups.idxGroup(j) = nk;
            groups.line(nk).nBox = groups.line(nk).nBox + 1;
            groups.line(nk).idxBox = [groups.line(nk).idxBox; j];
            
        end
    end
end
%     newBox = [groups.box, groups.idxGroup];
%     displayBox(newBox, 'b', 'u');
%% seg
nGroup = groups.nLine;
charWords = [];
for j = 1:nGroup
    idx = groups.line(j).idxBox;
    charBox = groups.box(idx,:);
    charWord = wordSegment_new(charBox);
    charWords = [charWords, charWord];
end
%% show the result 
% nWord = length(charWords);
% for j = 1:nWord
%     charBox = [charWords(j).charbox, j*ones(size(charWords(j).charbox, 1), 1)];
%     displayBox(charBox, 'g', 'u');
% end