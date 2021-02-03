function [spatialCalibration, units]=calibrate_scale(im)
f=figure(1);
imshow(im, []);
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
end