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


#### Downsampling of pointcloud
Implementation demonstrated in B.2. Visualisation of said pointcloud occurs in B.1

### Spatial Transformations and Pointcloud Registration
#### Implementation of rigid transformation techniques
B.3

#### ICP procedure
Implemented in B.4

## Part C | LiDAR-based Perception Module
### Feature Extraction
C.1 and C.2 are responsible for managing selected scalar features and the computation of a three-dimensional shape feature that can describe the three
largest amounts of spread along the three orthogonal directions respectively

### Data Split
C.3 splits data into training and testing subsets

