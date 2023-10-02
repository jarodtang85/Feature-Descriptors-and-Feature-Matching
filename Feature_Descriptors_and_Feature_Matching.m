clear all;
close all;
clc;

profile on;

%% A.1 and A.2
% Taken from https://au.mathworks.com/help/vision/ref/detectsiftfeatures.html
filename = "file1.png";
img1 = rgb2gray(imread(filename)); %Convert to grayscale
figure(1);
for i = 2:1:5
    % Detect SIFT features and extract their descriptors
    points1 = detectSIFTFeatures(img1, NumLayersInOctave = i, Sigma = 1.6);
    % Increasing number of layers in octave for each iteration
    [features1, validPoints1] = extractFeatures(img1, points1);

    % Display Results
    subplot(4, 1, i-1);
    imshow(img1);
    hold on;
    plot(validPoints1.selectStrongest(10),showOrientation=true);
    title("Interest Points - Number of Layers Within Octave: " + i);
end
% Last title must be printed outside for loop
title("Interest Points - Number of Layers Within Octave: 5");

% Cannot start from NumLayersInOctave = 1 otherwise MATLAB will crash

%% A.3

filename = "file1.png";
img1 = rgb2gray(imread(filename)); %Convert to grayscale
points1 = detectSIFTFeatures(img1, NumLayersInOctave = 3, Sigma = 1.6);
[features1, validPoints1] = extractFeatures(img1, points1);

filename = "file2.png";
img2 = rgb2gray(imread(filename)); %Convert to grayscale
points2 = detectSIFTFeatures(img1, NumLayersInOctave = 3, Sigma = 1.6);
[features2, validPoints2] = extractFeatures(img2, points2);

% L2 Normalisation of the feature descriptors 
fd1 = features1 ./ sqrt(sum(features1.^2, 2));
fd2 = features2 ./ sqrt(sum(features2.^2, 2));
matchMatrix = zeros(size(fd1, 1), size(fd2, 1));  % Initialise to optimise code
%% Exhaustive search (manually applied matchFeatures)
for i = 1:size(fd1, 1)
    for j = 1:size(fd2, 1)
    % Calculating the Euclidean distance between the i-th feature descriptor of the first image (fd1) and 
    % the j-th feature descriptor of the second image (fd2). This serves as a measure of similarity 
    % for feature matching.
        matchMatrix(i, j) = norm(fd1(i, :) - fd2(j, :));
    end
end

% Initialising
M = size(matchMatrix, 1);
N = size(matchMatrix, 2);

%% Finding one-one correspondence for feature descriptions

% d1 and d2 represent minimum distances of img1 and img2 respectively,
% however this is not needed

% Image 1 to image 2
[d1, minIdx1] = min(matchMatrix, [], 2);

% Image 2 to image 1
[d2, minIdx2] = min(matchMatrix, [], 1);

pairloc = []; % Initialising matrix storing pairs pertaining to shared feature descriptors
for i = 1:M
    if minIdx2(minIdx1(i)) == i
        pairloc = [pairloc; i, minIdx1(i)]; % gets index of particular feature in minIdx1 and minIdx2 (j)
    end
end

% extract (x, y) coordinates that correspond to the feature pair
mp1 = validPoints1(pairloc(:, 1),:);
mp2 = validPoints2(pairloc(:, 2),:);

figure(2);
subplot(2, 1, 1);
showMatchedFeatures(img1,img2,mp1,mp2);
title("A.3: Unique Correspondences of img1 and img2 without directly using matchFeatures()");
legend("Matched Points 1", "Matched Points 2");

%% A.4
% Taken from https://au.mathworks.com/help/vision/ref/matchfeatures.html
indexPairs = matchFeatures(features1,features2,'MatchThreshold',100,'MaxRatio',1.0, "Unique",true);
matchedPoints1 = validPoints1(indexPairs(:,1),:);
matchedPoints2 = validPoints2(indexPairs(:,2),:);
subplot(2, 1, 2);
showMatchedFeatures(img1,img2,matchedPoints1,matchedPoints2);
title("A.4 - matchFeatures() Performance: MatchThreshold = 100, MaxRatio = 1.0, Unique = true");
legend("Matched Points 1", "Matched Points 2");

%% Lines 106 onwards purely for my own understanding, hence they have all been commented out for this submission

% %% Simple Performance Analysis
% 
% figure(3);
% subplot(2, 1, 1);
% showMatchedFeatures(img1,img2,mp1(1:10),mp2(1:10));
% title("First 10 comparison - A.3");
% legend("Matched Points 1", "Matched Points 2");
% 
% subplot(2, 1, 2);
% showMatchedFeatures(img1,img2,matchedPoints1(1:10),matchedPoints2(1:10));
% title("First 10 comparison - A.4");
% legend("Matched Points 1", "Matched Points 2");
% 
% % To compare performance:
% % profile viewer;
% 
% %% Applying Filtering Process
% 
% % Demonstrates that the process is still viable and some points do map
% % appropiately
% 
% newIdx_A3 = [];
% newIdx_A4 = [];
% max_dist = 80; 
% % For A.3
% for k = 1:length(mp1)
%     pt1 = mp1.Location(k, :);
%     pt2 = mp2.Location(k, :);
%     x_diff = pt1(1)-pt2(1);
%     y_diff = pt1(2) - pt2(2);
%     difference = [x_diff y_diff];
%     if (norm(difference) < max_dist) 
%         newIdx_A3 = [newIdx_A3; k];
%     end
% end
% 
% % For A.4
% for k = 1:length(matchedPoints1)
%     pt1 = matchedPoints1.Location(k, :);
%     pt2 = matchedPoints2.Location(k, :);
%     x_diff = pt1(1)-pt2(1);
%     y_diff = pt1(2) - pt2(2);
%     difference = [x_diff y_diff];
%     if (norm(difference) < max_dist) 
%         newIdx_A4 = [newIdx_A4; k];
%     end
% end
% 
% 
% figure(4);
% subplot(2, 1, 1);
% showMatchedFeatures(img1,img2,mp1(newIdx_A3),mp2(newIdx_A3));
% title("A.3 - Filtered");
% legend("Matched Points 1", "Matched Points 2");
% 
% subplot(2, 1, 2);
% showMatchedFeatures(img1,img2,matchedPoints1(newIdx_A4),matchedPoints2(newIdx_A4));
% title("A.4 - Filtered");
% legend("Matched Points 1", "Matched Points 2");
% 
% 
