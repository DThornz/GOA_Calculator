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
allFrames_gray=zeros(height,width,fnum); % Pre-allocate grayscale images
allFrames_gray=cast(allFrames_gray,'uint8');
for ii=1:fnum
    im=allFrames(:,:,:,ii); % Load frame
    im=im2uint8(im); % Convert to uint8
    im=im2gray(im);
    allFrames_gray(:,:,ii)=im; % Convert to grayscale
end
% clear allFrames
%% Create Calibration Scale
im=allFrames_gray(:,:,1);
[spatialCalibration, units]=calibrate_scale(im);
%% Process Single Image
im=allFrames_gray(:,:,100); % Load test frame
% im=imbinarize(im,.98);
% im=im2uint8(im);
[im_binarized, pixelArea]=process_img(im,spatialCalibration);
%% Overlay original grayscale image with mask (in red)
imshow(im); 
red = cat(3, ones(size(im)), zeros(size(im)), zeros(size(im)));
hold on
h=imshow(red);
set(h, 'AlphaData', im_binarized)
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
    waitbar(ii/fnum,f,sprintf('Processing image %d out of %d',ii,fnum))
    im=allFrames_gray(:,:,ii); % Load frame
%     im=imbinarize(im,.98);
%     im=im2uint8(im);
    [im_binarized, pixelArea]=process_img(im,spatialCalibration);
    % Save image to output
    im_mask_out(:,:,ii)=im_binarized;    
    % Save area to vector
    pixelArea_out(ii)=pixelArea;
end
delete(f)
close all force
%% Plot GOA over Time and Prep for Video
frames=1:fnum;
% time=frames/fps/3.3;
time=frames/fps;
f=figure('units','pixels','position',[0 0 1920*2 2*1080/1.5]);
% f=figure;
subplot(1,2,1)
g=gca;
p=plot(time,smooth(pixelArea_out)/100);
hold on
p.Color='r';
p.LineWidth=15;
f.Color='w';
g.FontSize=40;
g.Box='off';
g.FontName='Times New Roman';
g.FontWeight='bold';
xlim([min(time),max(time)])
ylabel('GOA (cm^{2})')
xlabel('Time (s)')
subplot(1,2,2)
% Overlay original grayscale image with mask (in red)
im=allFrames_gray(:,:,100); % Load 1st frame
imshow(im);
red = cat(3, ones(size(im)), zeros(size(im)), zeros(size(im)));
hold on
h=imshow(red);
set(h, 'AlphaData', im_mask_out(:,:,100))

%% Plot and Create Movie
% create the video writer with 1 fps
writerObj = VideoWriter('GOA_Video.avi','Uncompressed AVI');
writerObj.FrameRate = 10;
% set the seconds per image
% open the video writer
open(writerObj);
for ii=1:fnum
    subplot(1,2,1)
    p2=plot(time(ii),smooth(pixelArea_out(ii)/100),'g.','MarkerSize',80);
    subplot(1,2,2)
    imshow(im);
    red = cat(3, ones(size(im)), zeros(size(im)), zeros(size(im)));
    hold on
    h=imshow(red);
    set(h, 'AlphaData', im_mask_out(:,:,ii))
    drawnow
    frame = getframe(gcf) ;
    writeVideo(writerObj, frame);
    delete(p2);
end
% close the writer object
close(writerObj);