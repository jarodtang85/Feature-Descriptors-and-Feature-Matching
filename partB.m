clear all;
close all;
clc;

%% B.1
filename = "pointcloudA.mat";
T = load(filename);
pointcloud_A = T.pointcloudA;
% Display the original point cloud
figure(1);
subplot(2, 1, 1);
pcshow([pointcloud_A(:, 1) pointcloud_A(:, 2) pointcloud_A(:, 3)]);
title("B.1: Original Pointcloud");
%% B.2

% Downsample the point cloud using a box grid filter of size 0.25
gridStep = 0.25;

% Only the first three columns (x, y, z coordinates) for pointCloud object
% Also must convert from single to point cloud object
pc_new = pointCloud(pointcloud_A(:, 1:3));

ptcloud_down = pcdownsample(pc_new, 'gridAverage', gridStep);
% Display the downsampled point cloud
subplot(2, 1, 2);
pcshow(ptcloud_down);
title('B.2 - Downsampled Pointcloud');

%% B.3

alpha = 30;
% Rotation matrix
R = [cosd(alpha) -sind(alpha) 0 ;sind(alpha) cosd(alpha) 0;0 0 1];
T = [2; 4; 0]; % Translation Matrix
pc_cardCoords = pointcloud_A(:, 1:3);
% Applying Transformation
pcB = ((R * pc_cardCoords') + T)';
figure(2);
subplot(2, 1, 1);
pointcloud_B = pointCloud(pcB);
pcshow(pointcloud_B);
title('B.3 - Manually Applied Transformations');

%% B.3 Verification 

% Build the affine transformation matrix
affineMat = [R(1, :), T(1); R(2, :), T(2); R(3, :), T(3); 0, 0, 0, 1];

% Create an affine3d object
tform = affine3d(affineMat');

% Apply the transformation
subplot(2, 1, 2);
ptCloudOut = pctransform(pointCloud(pointcloud_A(:, 1:3)), tform);
pcshow(ptCloudOut);
title("B.3 - Verification");
% Check if the transformed pointclouds match
disp("B.3 Verification:");
isequal(pointcloud_B, ptCloudOut) % should return 1 (true) if the transformations match

%% B.4

% x, y, z coords of pointcloud A
pcA = pointcloud_A(:, 1:3);
% x, y, z coords of pointcloud B
pcB = pcB(:, 1:3);

% ICP procedure

% https://www.youtube.com/watch?v=QWDM4cFdKrE
% Steps were taken from the above referenced video

% Initialising:
R = eye(3); % No rotation
t = [0;0;0]; % No translation
n = 18; % number of iterations


for i = 1:n
    % Step 1: aligning points using k nearest neighbour approach
    % https://au.mathworks.com/help/stats/knnsearch.html
    pcB_new = (R * pcB' + t)';
    idx = knnsearch(pcA, pcB_new);
    
    % Step 2: Compute CoM of each respective point cloud and shift
    % pointclouds on top of each other 
    centroid_A = mean(pcA(idx, :));
    centroid_B = mean(pcB);
    
    % Shifting centroids such that they're about same point
    % This simplifies the process of calculating rotation matrix and
    % can do calculations independent of translation

    A_shift = pcA - centroid_A;
    B_shift = pcB - centroid_B;
    
    % Step 3: computer optimal rotation using SVD to better align points
    [V,~,U] = svd(A_shift'*B_shift); % ~ used to disregard S
    D = [1 0 0; 0 1 0; 0 0 det(V*U')];
    R = V*D*U';
    % Note: U' is U transposed
    % Using R, find optimal translation
    t = (centroid_A - (R*centroid_B')')';
end

figure(3);
subplot(3, 1, 1);
pcshowpair(pointCloud(pcA), pointCloud(pcB));
title("Before Reallignment");

subplot(3, 1, 2);
pcB_transformed = pcB_new;
pcshowpair(pointCloud(pcA), pointCloud(pcB_transformed));
title("After manual ICP procedure (no. iterations = " + n + ")");

% Checks
% isOrthogonalU = isequal(U*U', eye(size(U,1)));
% isOrthogonalV = isequal(V*V', eye(size(V,1)));
%% B.4 Verification

tform = pcregistericp(pointCloud(pcB), pointCloud(pcA),Extrapolate=true);
ptCloudOut = pctransform(pointCloud(pcB), tform);
subplot(3, 1, 3);
pcshowpair(pointCloud(pcA), ptCloudOut);
title("pcregistericp()");


