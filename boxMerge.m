function word = boxMerge(charbox)
% input: charbox [x, y, w, h]
% output: word
%%boundbox:为窗口集合；img:为彩色图；
%boxes[x,y,w,h]
%boxes[x,y,w,h,xcenter,ycenter,area,color]
if isempty( charbox )
    word = [];
    return;
end
%%
T1 = 3;%高度比 % = 2.1, 52.6/// = 2.1 use to the textLine method
T2 = 3 ;%水平间距 % =2 , 62.5/// =3 use to the textLine method
T3 = 0.2;%垂直间距
T4 = 6;%面积比
TW = 1.5;
% 6. 要求两个box没有互相包含关系
T6 = 4;%高宽比
charbox = sortrows(charbox);
%% single char merged to a textline
boxes = charbox(:, 1:4);
nbox = size(boxes,1);
for i = 1:nbox
    char(i) = struct('left',[],'right',[]);
    %SG(i) = struct('cc',[]);
    xCenter = boxes(i,1)+floor(boxes(i,3)/2);
    yCenter = boxes(i,2)+floor(boxes(i,4)/2);
    boxes(i,5) = xCenter;
    boxes(i,6) = yCenter;
    boxes(i,7) = boxes(i,3)*boxes(i,4);
end
%% union the left and right neighbor of each char
for i = 1:nbox-1
    x1 = boxes(i,1);
    w1 = boxes(i,3);
    h1 = boxes(i,4);
    x1Center = boxes(i,5);
    y1Center = boxes(i,6);
    s1 = boxes(i,7);
    hw1 = h1/w1;
    
    for j = i+1:nbox
        x2 = boxes(j,1);
        w2 = boxes(j,3);
        h2 = boxes(j,4);
        x2Center = boxes(j,5);
        y2Center = boxes(j,6);
        s2 = boxes(j,7);
        hw2 = h2/w2;
        
        if ( (1/T1 <= (h1/h2) && (h1/h2) <= T1) && ... %高度比<2.1 (最大/最小）
                ( max([w1, w2]) / min([w1, w2]) < TW ) && ... % width ratio 
                ( abs(x1Center-x2Center) <= T2*max(w1,w2)) &&...%质心水平距离x差< = 最大宽度的2.5倍
                ( abs(y1Center-y2Center) <= T3*max(h1,h2)) &&...%质心竖直距离y< = 最大高度的0.5倍
                ( 1/T4 <= s1/s2 && s1/s2 <= T4) &&...%面积比< = 6倍
                  1/T6<hw1/hw2 && hw1/hw2<T6  ) %高宽比< = 7%不把横条的进行分组
            if x1<= x2
                right_num_1 = size(char(i).right,2);
                left_num_2 = size(char(j).left,2);
                char(i).right(right_num_1+1) = j;
                char(j).left(left_num_2+1) = i;
            else
                left_num_1 = size(char(i).left,2);
                right_num_2 = size(char(j).right,2);
                char(i).left(left_num_1+1) = j;
                char(j).right(right_num_2+1) = i;
            end
        end
    end
end
%% generate words by merging chars
SG = cell(nbox, 1);
for i = 1:nbox
    n1 = size(char(i).left,2);
    n2 = size(char(i).right,2);
    if ( n1 ~= 0 || n2 ~= 0 ) &&(abs(n1-n2) <= 3)
        %  if n1 ~= 0&&n2 ~= 0&&(abs(n1-n2) <= 3)
        set1 = char(i).left ;
        set2 = char(i).right;
        unionChar = unique(  [set1, set2] );
        SG{i} = [unionChar,i];
    end
end
newSG = unionSet( SG, 1);
word = [];
% char of word
nWord = length( newSG );
for i =1: nWord
    idx = newSG{i};
    nChar = length( idx );
    word(i).nChar = nChar;
    word(i).charbox = boxes( idx,1:4);
    word(i).wordbox = mmbox( boxes(idx,:) );
end
if nWord > 0
    idxWordChar = [newSG{:}];
else
    idxWordChar = [];
end
% single char 
idxAll = 1:nbox;
idxSingleChar = setdiff( idxAll, idxWordChar);
% if input boxes has more than four dimension (5 = score)
if size( charbox, 2) > 4
    idxSingleChar = idxSingleChar( charbox(idxSingleChar, 5 ) > 0 ) ;
end
nSingle =  length( idxSingleChar);
k = nWord +1;
for i = 1:nSingle
    word(k).nChar = 1;
    word(k).charbox = boxes(idxSingleChar(i),1:4);
    word(k).wordbox = word(k).charbox;
    k = k +1;
end
if isempty( word )
    return;
end
%% 


end


function newSet = unionSet( set , numInterSect)
% input  and output are cell
nSet = length( set );
newSet = [];
mark = 1;
while mark
    mark = 0;
   for i = 1: nSet-1
        set1 = set{i};
        if isempty(set1)
            continue;
        end
        for j = i+1:nSet
            set1 = set{i};
            set2 =  set{j};
            if isempty(set2)
                continue;
            end
            interSet = intersect(set1, set2);
            if length(interSet) > numInterSect
                set{i} = union(set1,set2);
                set{j} = [];
                mark = 1;
            end
         end
   end
end
for i = 1: nSet
    if ~isempty( set{i} )
        newSet = [newSet; set(i)];
    end
end
end

function [newWord, newLine] = mergeWords ( word, textLine )
newLine = [];
newWord = [];
% textLine = removeContainBox ( textLine );
nLine = size( textLine, 1);
if nLine < 1
    return;
end
%% paras
MINIDIS = 1/5;
MINXGAP = 2;
%%
box = textLine;
box(:, 5) = box(:, 2) + box(:, 4);% box(5)-down, box(6)-ycenter
box(:, 6) = ( box(:, 2) + box(:, 5) )/2;

% sort according to the ycenter
[box, sortIdx] = sortrows( box, 6);
word = word( sortIdx );
xcenter = floor (box(: ,1) + box(:, 3) /2 );
% calculate the seg
upRow = [box(:, 6); 0];
downRow = [ 0; box(:,6)];
gapTemp = upRow - downRow;
gap = gapTemp(2: end-1);
crossIdx = find( gap < 10 );
nCross = length( crossIdx );
if nCross < 1   
    newLine = box(:, 1:4);
    newWord = word;
    return;
end
mergeSet = [];
for i =1: nCross
    maxW = max( box( crossIdx(i), 3 ), box( crossIdx(i) + 1, 3 ) );
    maxH = max( box( crossIdx(i), 4 ), box( crossIdx(i) + 1, 4 ) );
    upGap = abs( box( crossIdx(i), 2 ) - box( crossIdx(i) + 1, 2 ) ) /maxH;
    downGap = abs( box( crossIdx(i), 5 ) - box( crossIdx(i) + 1, 5 ) ) /maxH;
    xcenterGap = abs( xcenter(crossIdx(i)) - xcenter(crossIdx(i) + 1) )  / maxW ;
    if(  upGap < MINIDIS && downGap < MINIDIS  && xcenterGap < MINXGAP )
        % crossIdx(i) and crossIdx(i) + 1 need to be merged
        mergeSet = [mergeSet; crossIdx(i), crossIdx(i) + 1 ];
      end
end
if isempty( mergeSet )
    newLine = box(:, 1:4);
    newWord = word;
    return;
end
crossSetIdx = unique( mergeSet(:) );
if size( crossSetIdx, 1) > 1
    crossSetIdx = crossSetIdx';
end
% add the normal box
restIdx = setdiff( [1:nLine], crossSetIdx );
newLine = [newLine; box( restIdx, 1:4) ];
newWord = [newWord; word(restIdx)];
% add the merge box
mergeSetCell = num2cell( mergeSet, 2);
newMergeSetCell = unionSet( mergeSetCell, 0 );
nMerge = size( newMergeSetCell, 1); 
for i = 1:nMerge
    idx = newMergeSetCell{i};
    boxes = box( idx,: );
    newLine = [newLine; mmbox( boxes )];
    charBoxes = [];
    for k = idx
        charBoxes = [charBoxes; word(k).charbox];
    end
    newTemp.charbox = charBoxes;
    newTemp.nChar = size(charBoxes, 1);
    newTemp.wordbox = mmbox( charBoxes );
    newWord = [newWord, newTemp];
end
assert( size(newLine,1) == length( newWord ) );
% imshow( image );
% displayBox( textLine );
% displayBox( newLine, 'b' );
% disp('ok');
end