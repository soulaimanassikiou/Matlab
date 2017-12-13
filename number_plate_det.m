%% it sets up the environment, clear the memory and load a library
clc
close all;
clear;
load imgfildata;
%% we open a dialog so we can select an image, we store it into a variable and we take the width of the image as 'cc', and finally we resize it
[file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
s=[path,file];
picture=imread(s);
[~,cc]=size(picture);
%picture=imresize(picture,[300 500]);


%picture = imcrop(picture);
%% we convert the image in a gray scale image if it has 3 channels (RGB)
if size(picture,3)==3
  picture=rgb2gray(picture);
end


figure, imshow(picture);title('Pulsar cuatro veces sobre las esquinas de la matr�cula elegidas','FontSize',10,'Color',[0,0,1]); %Muestra la imagen elegida
[x,y]=ginput(4); input_points=[x y];    %Define interactivamente las coordenadas de entrada seleccionando 4 puntos en la imagen

base_points=[65 16;427 16;427 97;65 97];    %Establecemos unas dimensiones predefinidas de escalado predefinidas para la imagen resultante
t_carplate=cp2tform(input_points,base_points,'projective'); %Crea la estructura de la transformaci�n proyectiva
picture=imtransform(picture,t_carplate);   %Se aplica la transformada proyectiva para enderezar la matr�cula
figure,imshow(picture);title('Transformaci�n proyectiva de la imagen seleccionada','FontSize',10,'Color',[0,0,1]); %Lee la imagen base de referencia

%% we call the function that will crop the image for getting the plate of the vehicle
picture = ZoomPlate(picture);



% se=strel('rectangle',[5,5]);
% a=imerode(picture,se);
% figure,imshow(a);
% b=imdilate(a,se);

%% we compute a threshold for the image with the graythresh func. it uses Otsu's method that chooses a threshold to minimize the interclass variance between white and black pixels
% then we create the negate binary image with the threshold that we have just created
threshold = graythresh(picture);
picture =~imbinarize(picture,threshold);

%picture = bwareaopen(picture,3);
% TODO: eliminem els objectes petits de la imatge
if cc>2000
    picture1=bwareaopen(picture,3500);
else
    picture1=bwareaopen(picture,3000);
end

% we show the image without the plate numbers/letters
figure,imshow(picture1);
picture2=picture-picture1;
% we show just the plate content
figure,imshow(picture2);
picture2 = picture2 - bwareaopen(picture2,900);
% we eliminate little noises and show the result
picture2 = bwareaopen(picture2, 200);
figure,imshow(picture2);

%% We get the different elements of the plate (numbers and letters)
% we get the connected elements into the binary image, and we also get the number of connected elements as 'Ne'
[L,Ne]=bwlabel(picture2);
% we get the measurements for the set of the properties specified 'BoundingBox' for each
% labeled region with bwlabel
% so we get each letter separated
propied=regionprops(L,'BoundingBox');

hold on
pause(1)

% for each 'letter/number' we got in the last section we print a green box
% around
for n=1:size(propied,1)
  rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off

%% 
%figure
final_output=[];
t=[];
% for each letter/number identified we show it in a different image
for n=1:Ne
    [r,c] = find(L==n);
    n1=picture(min(r):max(r),min(c):max(c));
    n1=imresize(n1,[42,24]);
    %imshow(n1)
    pause(0.2)
    x=[ ];

    % TODO: where does imgfile comes from?
    % SOL: its the numbers and letters library
    totalLetters=size(imgfile,2);
    
    for k=1:totalLetters
        % we look up for the correlation between our current number 'n1' and
        % the numbers stored in the library and we place it into an array
        y=corr2(imgfile{1,k},n1);
        x=[x y];
    end
    
    % we get the more similar letter/number in the library compared to our current letter
    t=[t max(x)];
    if max(x)>.35
        z=find(x==max(x));
        %convert the cells into matrix
        out=cell2mat(imgfile(2,z));
        
        
        
        % we add it into our results array
        final_output=[final_output out];
    end
end

%% Print the result into a text, for MAC
file = fopen('number_Plate.txt', 'wt');
    fprintf(file,'%s\n',final_output);
    fclose(file);   
    system('open number_Plate.txt');
    %winopen('number_Plate.txt')