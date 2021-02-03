function save_img(im,file_name,file_type,res)
%{
    Saves an input image in a desired format and resolution

    im: Image to save
    file_name: Name of image to save
    file_type: File type for image (Ex: jpeg, png, tiff, etc)
    res: Pixel resolution (Ex: 300, 600, 900, etc)

%}

if nargin < 2
    % Defaults
    file_name=['Image ' char(datetime('now'))];
    file_type='png';
    res='300';
end

figure('visible','off');
imshow(im);
f=gcf;
f.Position=[0 0 1080*2 2*1080];
f.Color='w';
str1=[file_name '.' file_type];
str2=['-d' file_type];
str3=['-r' res];
fprintf('Saving image as "%s" \n with a resolution of %s DPI \n into current working folder.\n',str1,res)
print(f,str1,str2,str3);
