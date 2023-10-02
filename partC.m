clear all;
close all;
clc;

filename1 = "lidarLabel.mat";
labels = load(filename1);
classes = labels.lidarLabel;
filename2 = "lidarData.mat";
data = load(filename2);
dataset = data.lidarData;

%% C.1
n = length(dataset);
intensityScalarFeatures = []; % only will contain 3 values per row
for j = 1:n
    % These three values can describe the vector of features fairly well 
    % min, mean and max
    intensities = dataset{j}(:, 4);
    features = [min(intensities), mean(intensities), max(intensities)];
    intensityScalarFeatures = [intensityScalarFeatures; features];
end

%% C.2

shapeFeatures = [];
for i = 1:n
    coords = dataset{i}(:,1:3);
    %Covariance Matrix
    covM = cov(coords);
    eigenV = eig(covM);
    shapeFeatures = [shapeFeatures; eigenV'];
end

k = 3;
largest_shapeFeatures = maxk(shapeFeatures, k);

%% C.3
% https://au.mathworks.com/help/stats/cvpartition.html

tbl = [intensityScalarFeatures shapeFeatures];
% n = length(shapeFeatures);
p = 0.3;
hpartition = cvpartition(classes,'Holdout',p);

idxTrain = training(hpartition);
tblTrain = tbl(idxTrain,:);
idxTest = test(hpartition);
tblTest = tbl(idxTest,:);

classesTrain = classes(idxTrain);
classesTest = classes(idxTest);

%% C.3 Verification of presence of the 10 distinct classes

disp("Training set classes");
disp(unique(classesTrain));
disp("Testing set classes");
disp(unique(classesTest));

%% C.4

% https://au.mathworks.com/help/stats/fitcecoc.html

SVM_Model = fitcecoc(tblTrain, classes(idxTrain), 'Learners', 'svm'); 
% Training the SVM model on dataset tblTrain

labelPredict = predict(SVM_Model, tblTest); % Prediction on test data tblTest

predictions = string(labelPredict(:, 1))';
truth = string(classes(idxTest));

accuracyC4 = sum(predictions == truth)/length(classes(idxTest)); % Getting accuracy


%% C.5

results = [];

% Splitting up for later use

% Training
ifTrain = tblTrain(:, 1:3); % Intensity Features Training
sfTrain = tblTrain(:, 4:end); % Shape Features Training

% Testing
ifTest = tblTest(:, 1:3);
sfTest = tblTest(:, 4:end);

% For zero shape features added
SVM_Model = fitcecoc(ifTrain, classes(idxTrain)); 
labelPredict = predict(SVM_Model, ifTest);
predictions = string(labelPredict(:, 1))';
truth = string(classes(idxTest));
acc = sum(predictions == truth)/length(classes(idxTest)); % Getting accuracy
results = [results; acc];

n = size(sfTrain, 2);
for k = 1:n
    
    % must ensure that test data alligns with training data
    tempTrain = [ifTrain sfTrain(:, 1:k)];
    tempTest = [ifTest sfTest(:, 1:k)];
    % Training the SVM
    SVM_Model = fitcecoc(tempTrain, classes(idxTrain));     
    % Prediction on test data
    labelPredict = predict(SVM_Model, tempTest);
    predictions = string(labelPredict(:, 1))';
    truth = string(classes(idxTest));
    acc = sum(predictions == truth)/length(classes(idxTest)); % Getting accuracy
    results = [results; acc];

end

