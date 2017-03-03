% saveFigDemo

% dirs
saveFigBase = '.';
dataBase = '/home/lili/datasets/shopSign';
CASE = 'test';
imgDir = fullfile(dataBase, 'img', CASE);
gtDir = fullfile(dataBase, 'gt', CASE, 'txt');
figDir = fullfile(saveFigBase, 'figure', CASE);
mkdir(figDir);
% read image, show gt
imgFiles = dir(fullfile(imgDir,'*.jpg'));
nImg = numel(imgFiles);
for i = 1:nImg
    rawName = imgFiles(i).name;
    rawName = 'xm_0034.jpg';
    imageName = fullfile(imgDir, rawName);
    gtName = fullfile(gtDir, [rawName(1:end-3), 'txt']);
    image = imread(imageName);
    [box, tag, word] = loadGTFromTxtFile(gtName);
    box(:,3) = box(:,3) - box(:,1);
    box(:,4) = box(:,4) - box(:,2);
    imshow(image);
    %displayBox(box);
%     word = boxMerge(box);
%     nWord = length(word);
%     for j = 1:nWord
%         charBox = word(j).charbox;
%         charBox = [charBox, j*ones(size(charBox, 1), 1)];
%         displayBox(charBox, 'g', 'u');
%     end
    charWords = mySelectGroup(box);
    
    nWord = length(charWords);
    for j = 1:nWord
        charBox = [charWords(j).charbox, j*ones(size(charWords(j).charbox, 1), 1)];
        displayBox(charBox, 'g', 'u');
    end
    
%     newBox = [groups.box, groups.idxGroup];
%     displayBox(newBox, 'b', 'u');
    title(sprintf('%d:%s\n', i, rawName));
    %saveas(gcf, fullfile(figDir, rawName));
    fprintf('%d:%s\n', i, rawName);
    %displayBoxAndTag(word);
end