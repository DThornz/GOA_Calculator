imshow(im);
f=gcf;
f.Position=[0 0 1080*2 2*1080];
f.Color='w';
print(f,'Image.png','-dtiff','-r600');  