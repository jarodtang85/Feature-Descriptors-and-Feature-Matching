# Sensor-Data-Processing

## Part A | Feature Descriptors and Feature Matching
Feature matching is an essential step in several computer vision applications that involves establishing correspondences
between two images of the same object or scene. The first step is to detect a set of interest points associated with
image descriptors. Once the features and descriptors are extracted from the sequence of images, the next step involves
establishing matching between feature descriptors to establish correspondences

### A.4
A simple feature matching algorithm is built to establish unique correspondence between feature descriptors

## Part B | LiDAR Pointcloud Matching
### LiDAR Data and Preprocessing
LiDAR measures the position of points in the three-dimensional world using spherical coordinates: radial distance from
the centre origin to the 3D point, elevation angle measured up from the sensor XY plane, and azimuth angle measured
counterclockwise from the x-axis of the sensor. The spherical coordinates are converted to cartesian coordinates x,
y, and z and stored as a 3 by 1 column vector. The points are stacked into a matrix that stores the scanned points.
Sometimes, there can be a 4th column in the matrix storing the amplitude of the returned signal. One matrix of
LiDAR points is usually referred to as pointcloud, and a pointcloud can represent an entire object or part of an object
or surrounding environment.

#### Downsampling of pointcloud
Implementation demonstrated in B.2. Visualisation of said pointcloud occurs in B.1

### Spatial Transformations and Pointcloud Registration
Objects in the world mostly stay put while the reference frame attached to the vehicle moves, observing them from
different perspectives. When the vehicle moves, it will affect the perception of all the scanned points in the point cloud.
A combination of translation and rotation operations can describe the vehicular movement between two locations.
Given two point clouds in two different coordinate frames, and with the knowledge that they correspond to or contain
the same object in the world, optimal translation and rotation between the two reference frames can be computed to
minimise the distance between the two point clouds. The process of finding a spatial transformation (rotation and
translation) that aligns the two point clouds is known as point-set registration. A popular algorithm is the iterative
closest point (ICP) procedure. The basic intuition behind ICP is that when we find the optimal translation and
rotation, we can use them to transform one point cloud into the coordinate frame of the other such that the pairs of
points that truly correspond to each other will be the ones that are closest to each other in a Euclidean sense.

#### Implementation of rigid transformation techniques
B.3

#### ICP procedure
Implemented in B.4

## Part C | LiDAR-based Perception Module
The pointclouds and their road object names are available in two ‘.mat’ files: lidarData.mat and lidarLabel.mat. The
lidarData.mat is a cell array consisting of 523 elements corresponding to 523 LiDAR scans of different objects. Each
element of the cell array is a 2D matrix with 4 columns (x,y,z coordinates of a world object, and the fourth column
represents intensity A of the returned laser signal). The number of rows in each element varies and represents the
number of 3D pointclouds obtained for the given scan. The lidarLabel.mat is a cell array consisting of 523 class names
corresponding to the 523 LiDAR scans. These 523 scans belong to a total of 10 classes: building, car, pedestrian, pillar,
pole, traffic lights, traffic sign, tree, trunk and van. Load the data and labels and inspect the content and dimensions
before proceeding further.

### Feature Extraction
A primary step in developing a supervised machine learning object recognition algorithm involves extracting feature
descriptors from LiDAR pointclouds that can efficiently represent different categories in the data. The pointcloud
features available in literature can be roughly divided into two classes: the global features for the whole object or the
local features for each point inside the object pointcloud. A simple object-level global feature can be the intensity of
the returned laser signal. Different objects with different characteristics and views reflect the laser signal differently.
The intensity values (4th column in the LiDAR pointcloud matrix) can be used to extract simple features for our
recognition task.

C.1 and C.2 are responsible for managing selected scalar features and the computation of a three-dimensional shape feature that can describe the three
largest amounts of spread along the three orthogonal directions respectively

### Data Split
C.3 splits data into training and testing subsets. C.4 uses the training feature matrix and class labels developed in C.1 and C.2 to train a multi-class SVM. The classification accuracy is published in the command window. In C.5, the classifier in C.4 is trained using only intensity features. This section explores the effect of incrementally adding one shape feature at a time in the training-testing process. Test accuracy is used as the performance metric in this section.

