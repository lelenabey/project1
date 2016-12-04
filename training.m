computeHog('train', 100);
 trainingFeaturesSub = load('./Face Data/images/classified/train/FeaturesSub.mat');
 trainingLabelsSub   = load('./Face Data/images/classified/train/LabelsSub.mat');
%trainingFeaturesSub = load('./Face Data/images/classified/train/Features.mat');
%trainingLabelsSub   = load('./Face Data/images/classified/train/Labels.mat');

addpath(genpath('./libsvm-3.21'));
gender_model = svmtrain(trainingLabelsSub.tLabels, trainingFeaturesSub.tFeatures ,'-c 0 -t 2 -c 10');
%save('./Face Data/images/classified/gender_model', 'gender_model', '-v7.3');
% computeHog('test', 8);
% testFeaturesSub = load('./Face Data/images/classified/test/FeaturesSub.mat');
% testLabelsSub   = load('./Face Data/images/classified/test/LabelsSub.mat');

%[predicted_label, accuracy, decision_values] = svmpredict(testLabelsSub.tLabels, testFeaturesSub.tFeatures, gender_model);

