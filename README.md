# GOA Calculator

## This code was made to work with MATLAB R2020b

## This code requires the following MATLAB Toolbox:
1. Image Processing 

## What does this code do?

Given an input planar image of valve (example: aortic) the code will find the geometric orifice area (GOA) in cm<sup>2</sup> and output an the mask of the region along with an overlay using the original image. You must know at least one real world dimension of your image, either via a scale bar or knowledge of geometric dimensions (leaflet length, annular diameter, etc). Final output examples are shown below.

### Mask
<a href="url"><img src="https://github.com/DThornz/GOA_Calculator/blob/main/Exported%20Image%20Results/Masked_Img.png" align="center" height="500" width="500" ></a>


### Overlay
<a href="url"><img src="https://github.com/DThornz/GOA_Calculator/blob/main/Exported%20Image%20Results/Overlay.png" align="center" height="500" width="500" ></a>

## How does it do it?

Given a starting image there are a number of image processing steps done before a computer vision section of the code extracts the GOA regions, these are:

1. Image contrasting (imadjust)
2. Image blurring (imgaussfilt)
3. Graph cut (laznsapping)
4. Flood fill (graydiffweight/imsegfmm)
5. Invert mask (imcomplement)
6. Active contour (activecontour)
7. Binarization (imbinarize)
8. Area Extraction (bwarea)

[Details on the mathematics and usage of each step can be found in the MATLAB documentation.](https://www.mathworks.com/help/images/)

[Feel free to fork this on GitHub](https://github.com/DThornz/GOA_Calculator/fork)







