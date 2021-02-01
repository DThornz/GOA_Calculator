imshow(im4);
f=gcf;
f.Position=[0 0 1080*2 2*1080];
f.Color='w';
frame=getframe(f);
frame=frame.cdata;
imwrite(frame,'Binarized.tiff');