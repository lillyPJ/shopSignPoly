% testShowDemo

% dirs
dataBase = '/home/lili/datasets/shopSign';
CASE = 'train';
imgDir = fullfile(dataBase, 'img', CASE);
gtDir = fullfile(dataBase, 'gt', CASE, 'txt');

% read image, show gt
imgFiles = dir(fullfile(imgDir,'*.jpg'));
nImg = numel(imgFiles);
for i = 1:nImg
    rawName = imgFiles(i).name;
    %rawName = 'xm_0037.jpg';
    imageName = fullfile(imgDir, rawName);
    gtName = fullfile(gtDir, [rawName(1:end-3), 'txt']);
    image = imread(imageName);
    [box, tag, word] = loadGTFromTxtFile(gtName);
    box(:,3) = box(:,3) - box(:,1);
    box(:,4) = box(:,4) - box(:,2);
    imshow(image);
    %displayBox(box);
    groups = mySelectGroup(box);
    newBox = [groups.box, groups.idxGroup];
    displayBox(newBox, 'b', 'u');
    %displayBoxAndTag(word);
end