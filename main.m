clear;clc;close all
%% Load Video
[file,path] =uigetfile('*.mp4'); % Grab file
v=VideoReader([path file]); % Read video file
fnum=v.NumFrames; % Grab number of frames
fps=v.FrameRate; % Grab frame rate (usually 24)
width=v.Width; % Width of video in pixels
height=v.Height; % Height of video in pixels
%% Parse Images
allFrames=read(v); % Parse all frames into a 4D uint8 structure
allFrames_gray=zeros(width,height,fnum); % Pre-allocate grayscale images
allFrames_gray=cast(allFrames_gray,'uint8');
for ii=1:fnum
    im=allFrames(:,:,:,ii); % Load frame
    im=im2uint8(im); % Convert to uint8
    im=im2gray(im);
    allFrames_gray(:,:,ii)=im; % Convert to grayscale
end
% clear allFrames
%% Create Calibration Scale
f=figure(1);
imshow(allFrames_gray(:,:,1), []);
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% Make caption the instructions.
title('Left-click first point.  Right click last point.');
% Ask user to plot a line.
[x, y, profile] = improfile();
% Restore caption.
title('Original Image');
% Calculate distance
distanceInPixels = sqrt((x(1)-x(end))^2 + (y(1)-y(end))^2);
% Initialize
userPrompts = {'Enter true size:','Enter units:'};
defaultValues = {'30', 'mm'};
titleBar = 'Enter known distance';
caUserInput = inputdlg(userPrompts, titleBar, 2, defaultValues);
% Initialize.
realWorldNumericalValue = str2double(caUserInput{1});
units = char(caUserInput{2});
spatialCalibration = realWorldNumericalValue / distanceInPixels;
realWorldDistance = distanceInPixels * spatialCalibration;
fprintf('%f pixels = %f %s \n', ...
    distanceInPixels, realWorldDistance, units);
fprintf('Calibration Scale = %f %s/pixels \n',spatialCalibration,units);
close(f)
%% Process Single Image
im=allFrames_gray(:,:,100); % Load test frame
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

% Calculate area of mask region
pixelArea = bwarea(im4);

% Convert area from pixel^2 to mm^2
pixelArea = pixelArea*spatialCalibration^2;

% Report GOA in units of cm^2
fprintf('GOA = %f %s%c \n',pixelArea*.01,'cm',178);

% Overlay original grayscale image with mask (in red)
imshow(im);
red = cat(3, ones(size(im)), zeros(size(im)), zeros(size(im)));
hold on
h=imshow(red);
set(h, 'AlphaData', im4)

%% Batch Process Remaining Images
% Pre-allocation
im_mask_out=zeros(width,height,fnum);
pixelArea_out=zeros(1,fnum);
f = waitbar(0,'1','Name','Processing Images...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
for ii=1:fnum
    if getappdata(f,'canceling')
        break
    end
    % Update waitbar and message
    waitbar(ii/fnum,f,sprintf('Processing image %d our of %d',ii,fnum))
    
    im=allFrames_gray(:,:,ii); % Load test frame
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
    
    % Save image to output
    im_mask_out(:,:,ii)=im4;
    
    % Calculate area of mask region
    pixelArea = bwarea(im4);
    
    % Convert area from pixel^2 to mm^2
    pixelArea = pixelArea*spatialCalibration^2;
    
    % Convert area from mm^2 to cm^2
    pixelArea = pixelArea*0.01;
    
    % Save area to vector
    pixelArea_out(ii)=pixelArea;
end
delete(f)
close all force
%% Plot GOA over Time
imshow(im_mask_out(:,:,1))