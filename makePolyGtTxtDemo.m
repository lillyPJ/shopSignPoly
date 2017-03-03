% makePolyGtTxtDemo
% x1, y1, x2, y2, x3, y3, x4, y4, transcription
% testShowDemo
CASE = 'train';
destDataBase = '/home/lili/datasets/shopSignPoly';
destGtDir = fullfile(destDataBase, 'gt', CASE, 'txt', 'poly');
mkdir(destGtDir);

% dirs
sourceDataBase = '/home/lili/datasets/shopSign';
imgDir = fullfile(sourceDataBase, 'img', CASE);
sourceGtDir = fullfile(sourceDataBase, 'gt', CASE, 'txt');

% read image, show gt
imgFiles = dir(fullfile(imgDir,'*.jpg'));
nImg = numel(imgFiles);
for i = 1:nImg
%     if i < 103
%         continue;
%     end
    rawName = imgFiles(i).name;
    fprintf('%d:%s\n', i, rawName);
    imageName = fullfile(imgDir, rawName);
    gtName = fullfile(sourceGtDir, [rawName(1:end-3), 'txt']);
    image = imread(imageName);
    [box, tag, word] = loadGTFromTxtFile(gtName);
    % char box:[x, y, w, h]
    %imshow(image);
    %displayBox(box);
    %% changeFromCharBoxToPolyWord
    % group boxes
    box(:,3) = box(:,3) - box(:,1);
    box(:,4) = box(:,4) - box(:,2);
    charWords = mySelectGroup(box);
    nWord = length(charWords);
    polys = [];
    % get poly
    for j = 1:nWord
        charBox = charWords(j).charbox;
        %displayBox([charBox, j*ones(size(charWords(j).charbox, 1), 1)], 'g', 'u');
        gtP = getCornerPoints(charBox);
        poly = minBoundingBox(gtP);
        %displayEightBox(poly,'b');  
        polys = [polys; ceil(poly(:))'];
    end
    %% write to gt file
    destGtFile = fullfile(destGtDir, [rawName(1:end-3), 'txt']);
    fp = fopen(destGtFile, 'wt');
    nPoly = size(polys, 1);
    for j = 1:nPoly
        fprintf(fp, '%d, %d, %d, %d, %d, %d, %d, %d\n', polys(j,:));
    end
    fclose(fp);
    %displayBoxAndTag(word);
end
