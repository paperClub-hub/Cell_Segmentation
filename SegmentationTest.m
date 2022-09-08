dataDirectory ='.\';
testCases = dir(fullfile(dataDirectory, 'imgdir', '*.png'));
fprintf('\nReading cytoplasm ground truth... ');
testResults = cell(length(testCases), 1);
fprintf('Done.\n');

tic
%%
% Segmenting nuclei and cell clumps...
fprintf('\nLoading stack images... ');
allVolumeImages = [];
allVolumeImages = cell(length(testCases), 1);
alpha = 1.75;
beta = 20;

fprintf('\nSegmenting nuclei and cell clumps... \n');
imageInfo = cell(length(testCases), 1);


parfor i = 1: length(testCases)
    fprintf('\t%s: ', testCases(i).name(1: end - 4));
    imageName = fullfile(dataDirectory, 'imgdir', testCases(i).name);
    imageInfo{i}.loadedImg = imread(imageName);
    %%%%%TO DO: Segment Nuclei
    [imageInfo{i}.nuclei, imageInfo{i}.contourArea, imageInfo{i}.contourSize] = SegmentNuclei(imageInfo{i}.loadedImg);
    fprintf('nuclei segmented,');
    %%%%%TO DO: Segment Clumps 
    imageInfo{i}.allClumps = SegmentClumps(imageInfo{i}.loadedImg);
    fprintf('cell clump segmented.\n');
    %%%%%%TO DO: Segment Cell Boundary 
    fprintf('\nSegmenting overlapping cytoplasms (alpha = %0.2f, beta = %0.2f)...\n', alpha, beta);
    cytoplasms = SegmentCytoplasms(imageInfo{i}.loadedImg, allVolumeImages{i}, imageInfo{i}.contourSize, imageInfo{i}.contourArea, imageInfo{i}.allClumps, alpha, beta);
    testResults{i} = cytoplasms;
    fprintf('cytoplasms segmented.\n');
    
end
fprintf('All Segmentation Done.\n');
toc

%%
%%%%%%%%%%%%%%%% Results

for i = 1: length(testCases)
    fprintf('\t%s show: ', testCases(i).name(1: end));
    imageName = fullfile(dataDirectory, 'imgdir', testCases(i).name);
    imageInfo{i}.loadedImg = imread(imageName);
    img_nuclei = imageInfo{i}.nuclei;
    img_nucleiBoundary=bwperim(img_nuclei); 
    figure;imshow(imageInfo{i}.loadedImg);title('Original Image');
    hold on;
    
    %%%%%%%%%% green for nulei boundary
    [nuclei_B,nuclei_L] = bwboundaries(img_nucleiBoundary,'noholes');
    for n = 1:length(nuclei_B)
        nuclei_boundary = nuclei_B{n};
        plot(nuclei_boundary(:,2), nuclei_boundary(:,1), 'g', 'LineWidth', 1)
    end
    
    %%%%%%%%%%% red for nulei coordinate
    Ilabel = bwlabel(img_nuclei);
    Area_I = regionprops(Ilabel,'centroid');
    for x = 1: numel(Area_I)
        plot(Area_I(x).Centroid(1),Area_I(x).Centroid(2),'r.','markersize',10);%b.
    end;
    
    
    %%%%%%%%%%%%% red for cell boundary
    cellNo=size(testResults{i},1);
    for j=1:cellNo
        img_temp=testResults{i}{j,1};
        if isa(img_temp,'logical')
            [B_i,L] = bwboundaries(img_temp,'noholes');
            for j_i = 1:length(B_i)
                boundary = B_i{j_i};
                plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
            end
         end
    end
    
    %imwrite(imageInfo{i}.loadedImg,sprintf('%s%d%s','./result/',i,'.bmp'));%%Í¼Æ¬±£´æ
end



