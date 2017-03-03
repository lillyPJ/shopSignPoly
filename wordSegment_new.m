function charWord = wordSegment_new(Boxes )
%% split the string  to word
% input-boxes:
% input-textline
T = 3;
n = size(Boxes,1);
%% initilization
num = 1;
seg = 0;
dis = zeros(1,n-1);
%% 
if n> T
    for i = 1:n-1
        dis(i) = max(0,Boxes(i+1,1) - (Boxes(i,1)+Boxes(i,3)));%第i+1和第i窗口的水平间距
    end
    disMean = mean(dis);%平均的间距均值
    widMean = mean(Boxes(:,3));%平均的字符字宽
%     if( dis(1) > 3*dis(2) )
%         %  if( dis(1)> max(5,dis(2)+widMean*0.5) )
%         seg = [seg;1]; %寻找分割点
%     end
    for i = 2:n-2
        %D = dis(i);
        %if D>T1*disMean&&D>T2*widMean%满足条件1.间距与间距均值比例2.间距与平均宽度比例
        %
        %  if( dis(i) > widMean*0.2 )
        if ( ((dis(i)-dis(i-1)) >=  max([3,widMean*0.2,disMean*0.6+widMean/20]) && (dis(i)-dis(i+1)) >=  max([3,widMean*0.2,disMean*0.6+widMean/20])) ||  ...
                dis(i) >=   max(5,dis(i+1)+widMean*0.5) || ...
                dis(i) >=   max(5,dis(i-1)+widMean*0.5) )
            
            seg = [seg;i]; %寻找分割点
        end
        %   end
        %}
    end
    %    if( dis(n-1)-dis(n-2)> max([5,widMean*0.3,disMean*0.8+widMean/10]) )
%     if( dis(n-1) > dis(n-2)*3 )
%         %    if(  dis(n-1) > max(5,dis(n-2)+widMean*0.5) )
%         seg = [seg;n-1]; %寻找分割点
%     end
    num = 1;
    if size(seg,1) < 2
        wordboxes = mmbox(Boxes);
        charWord(num).charbox = Boxes;
        charWord(num).wordbox = wordboxes;
    else
        for i = 1:size(seg,1)-1
            indx = seg(i)+1;
            indy = seg(i+1);
            if indy == indx
                continue;
            end
            wordbox = mmbox(Boxes(indx:indy,:));
            charWord(num).charbox = Boxes(indx:indy,:);
            charWord(num).wordbox = wordbox;
            num = num+1;
        end
        %charWord(num) = struct('bbs',[]);
        lastBoxes = Boxes(seg(end)+1:end,:);
        if length( lastBoxes ) > 1 || lastBoxes(:, 3)/lastBoxes(:,4) > 2 % more than 2 chars
            wordbox = mmbox( lastBoxes );
            charWord(num).charbox = lastBoxes;
            charWord(num).wordbox = wordbox;
        end
    end
else
    wordbox = mmbox(Boxes);
    charWord(num).charbox = Boxes;
    charWord(num).wordbox = wordbox;
end