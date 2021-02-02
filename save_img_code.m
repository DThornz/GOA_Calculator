imshow(im4);
f=gcf;
f.Position=[0 0 1080*2 2*1080];
f.Color='w';
print(f,'Binarized.tiff','-dtiff','-r600');  