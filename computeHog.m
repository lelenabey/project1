function computeHog(set, size)

trainingSet = imageSet(sprintf('./Face Data/images/classified/%s', set),   'recursive');

img = read(trainingSet(2), 4);
img = imresize(img,[50 50]);
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);

% figure; 
% imshow(img);hold on;
% plot(vis8x8); 

cellSize = [8 8];
hogFeatureSize = length(hog_8x8);

%trainingFeatures = [];
%trainingLabels   = [];

tFeatures = [];
tLabels   = [];
for gender = 1:numel(trainingSet)
    if size > 0
        numImages = size;   
    else
        numImages = trainingSet(gender).Count;  
    end
    features  = zeros(numImages, hogFeatureSize, 'single');
    h = waitbar(0,sprintf('Computing Hog for %s', trainingSet(gender).Description(1)));
    for i = 1:numImages
        waitbar(i / numImages)
        img = rgb2gray(read(trainingSet(gender), i));
        img = imresize(img,[50 50]);
        features(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
    end
    close(h);
    % Use the imageSet Description as the training labels. The labels are
    % the digits themselves, e.g. '0', '1', '2', etc.
    labels = repmat(trainingSet(gender).Description, numImages, 1);
    
    tFeatures = [tFeatures; double(features)];   %#ok<AGROW>
    tLabels   = [tLabels;   double(labels)  ];   %#ok<AGROW>
    

end
if size > 0
 save(sprintf('./Face Data/images/classified/%s/FeaturesSub', set), 'tFeatures', '-v7.3');
 save(sprintf('./Face Data/images/classified/%s/LabelsSub', set), 'tLabels', '-v7.3');
else
 save(sprintf('./Face Data/images/classified/%s/Features', set), 'tFeatures', '-v7.3');
 save(sprintf('./Face Data/images/classified/%s/Labels', set), 'tLabels', '-v7.3');
end
end