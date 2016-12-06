function training(set_size, cellSize, imageSize)

if exist(sprintf('./Face Data/images/classified/train/FeaturesSub-%i-%i.mat', cellSize(1), imageSize(1)), 'file')==0
 computeHog('train', set_size, cellSize, imageSize);
end

trainingFeaturesSub = load(sprintf('./Face Data/images/classified/train/FeaturesSub-%i-%i.mat', cellSize(1), imageSize(1)));
trainingLabelsSub   = load(sprintf('./Face Data/images/classified/train/LabelsSub-%i-%i.mat',cellSize(1), imageSize(1)));
% trainingFeaturesSub = load('./Face
% Data/images/classified/train/Features.mat');
% trainingLabelsSub   = load('./Face Data/images/classified/train/Labels.mat');

addpath(genpath('./libsvm-3.21'));
if exist(sprintf('./Face Data/images/classified/gender_model-%i-%i.mat', cellSize(1), imageSize(1)), 'file')==0
    gender_model = svmtrain(trainingLabelsSub.tLabels, trainingFeaturesSub.tFeatures ,'-c 0 -t 2 -c 10');
    save(sprintf('./Face Data/images/classified/gender_model-%i-%i', cellSize(1), imageSize(1)), 'gender_model', '-v7.3');
end
% computeHog('test', 100, cellSize, imageSize);
% testFeaturesSub = load('./Face Data/images/classified/test/FeaturesSub.mat');
% testLabelsSub   = load('./Face Data/images/classified/test/LabelsSub.mat');
% 
% [predicted_label, accuracy, decision_values] = svmpredict(testLabelsSub.tLabels, testFeaturesSub.tFeatures, gender_model);

end