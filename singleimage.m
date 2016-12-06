function singleimage(filename, cellSize, imageSize)
rgbimg = imread(filename);
image = rgb2gray(rgbimg);
model_path = 'dpm_baseline.mat';
face_model = load(model_path);
detection_threshold = 0;
nms_threshold = 0.3;
[ds, bs] = process_face(image, face_model.model,  ...
detection_threshold, nms_threshold);
if exist(sprintf('./Face Data/images/classified/train/FeaturesSub-%i-%i.mat', cellSize(1), imageSize(1)), 'file')==0
 computeHog('train', 1000, cellSize, imageSize);
end

trainingFeaturesSub = load(sprintf('./Face Data/images/classified/train/FeaturesSub-%i-%i.mat', cellSize(1), imageSize(1)));
trainingLabelsSub   = load(sprintf('./Face Data/images/classified/train/LabelsSub-%i-%i.mat',cellSize(1), imageSize(1)));

hog_8x8 = extractHOGFeatures(double(zeros(imageSize)),'CellSize',cellSize);

hogFeatureSize = length(hog_8x8);
addpath(genpath('./libsvm-3.21'));
gender_model = svmtrain(trainingLabelsSub.tLabels, trainingFeaturesSub.tFeatures ,'-c 0 -t 2 -c 10');
num_faces = size(ds, 1);
for j = 1:num_faces
    x1 = ds(j,2):ds(j,4);
    y1 = ds(j,1):ds(j,3);
    x1 = round(x1(x1<=size(image,1)));
    y1 = round(y1(y1<=size(image,2)));
    features(j,:) = extractHOGFeatures(imresize(rgbimg(x1 ,y1), imageSize), 'CellSize', cellSize);
    labels(j,:)=j;
end


%img = imresize(faces{i,1},[50 50]);
%features = extractHOGFeatures(img, 'CellSize', cellSize);
[predicted_label, accuracy, decision_values] = svmpredict(double(labels), double(features), gender_model);
showsboxes_face(rgbimg, ds);
text(ds(:,3), ds(:,4), char(predicted_label),'Color', 'g','FontSize',14, 'FontWeight', 'bold');
end