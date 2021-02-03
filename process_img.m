function [im_binarized, pixelArea]=process_img(im,spatialCalibration)
%{
    Processes a given image to extract the GOA mask and area region given
    a starting image and spatial calibration info from calibrate_scale.m

    im: Image to process
    spatialCalibration: Output from calibrate_scale.m
%}

im2=imadjust(im,[50 250]/255); % Adjust frame contrast
im3=imgaussfilt(im2,1); % Add gaussian blur to image

X=im3; % Temporarily store image as X

% Graph cut
foregroundInd = [8217 8219 8222 8223 8226 8228 8231 8234 8236 8237 8239 8243 8245 8741 8744 8745 8746 8776 8778 8780 8782 9268 9269 9794 9795 10321 10322 10847 10848 10850 11374 11375 11376 11902 11903 12431 12960 12961 13488 13489 14018 14547 ];
backgroundInd = [2698 2699 2701 2702 2704 3223 3224 3239 3752 4280 4808 5336 5864 6393 6394 6922 7981 8510 8511 9039 10098 10628 11157 11686 12216 12745 12746 13275 13805 14865 15395 15925 16455 ];
L = superpixels(X,2909);
BW = lazysnapping(X,L,foregroundInd,backgroundInd);

% Flood fill
row = 65;
column = 46;
tolerance = 255;
weightImage = graydiffweight(X, column, row, 'GrayDifferenceCutoff', tolerance);
addedRegion = imsegfmm(weightImage, column, row, 0.01);
BW = BW | addedRegion;

% Invert mask
BW = imcomplement(BW);

% Active contour
iterations = 100;
BW = activecontour(X, BW, iterations, 'Chan-Vese');

% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;

% Binarize image
im4=imbinarize(maskedImage);
im_binarized=im4;

% Calculate area of mask region
pixelArea = bwarea(im4);

% Convert area from pixel^2 to mm^2
pixelArea = pixelArea*spatialCalibration^2;

% Report GOA in units of cm^2
fprintf('GOA = %f %s%c \n',pixelArea*.01,'cm',178);

end
