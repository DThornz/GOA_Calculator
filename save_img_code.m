imshow(allFrames(:,:,:,100));
f=gcf;
f.Position=[0 0 1080*2 2*1080];
f.Color='w';
print(f,'Original.png','-dpng','-r600');  