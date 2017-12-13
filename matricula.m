%% Carga de la imgen %%
clear all; clc; close all;
[fichero,p1]=uigetfile(('*.bmp;*.pcx;*.tif;*.jpg'),'Seleccione imagen para detectar matricula');
s1=strcat(p1,fichero); [img, map]=imread(s1);
%% Preprocesado %%
%img=imresize(img,[480 640]);
img2 = img;
figure;imshow(img);
% Rgb to gray
img=rgb2gray(img);
%figure;imshow(img);

% Eliminaci�n de ruido median filter
img = medfilt2(img,[5 5]);
%figure;imshow(img);
%% Segmentacion %%
img = ZoomPlate(img);
figure;imshow(img);title('Segmentacion');

orig = img;
%% Operaciones Morfol�gicas %%
se = [0 0 1 0 0; 0 1 1 1 0; 1 1 1 1 1; 0 1 1 1 0; 0 0 1 0 0];

% erosion
erosion = imerode(img,se);

% dilatacion
apertura = imdilate(erosion,se);

% cierre
img = apertura - erosion;
figure;imshow(img); title('Transformaciones');
img2 = img;
%% Detecci�n de borden canny
BW = edge(img, 'canny',0.5);
%figure;imshow(BW); title(�BW CANNY�);

%Suavizado de la imagen para reducir el n�mero de componentes conectados
msk=[0 0 0 0 0;
0 1 1 1 0;
0 1 1 1 0;
0 1 1 1 0;
0 0 0 0 0;];

B=conv2(double(BW),double(msk));
%figure;imshow(B);

%% Calculo de regiones %%
L =bwlabel(B,8);
%figure; imshow(L); title(�l�);
%Rellena �reas de conjuntos conexos con pixeles en blanco
d2 = imfill(L, 'holes');
%figure; imshow(d2); title(�fill�);
%Crea regiones
[Etiquetas, N]=bwlabel(d2);

MAP = [0 0 0; jet(N)];
I = ind2rgb(Etiquetas+1,MAP);
%figure; imshow(I);title(�I�);

%% Identificaci�n de la regi�n de la matricula %%

stats=regionprops(Etiquetas,'all');
areaMaxima=sort([stats.Area],'descend');
indiceLogo=find([stats.Area]==areaMaxima(1) ); % Coloca en orden de mayor a menor las �reas de la imagen

for i=1:size(indiceLogo,2)
rectangle('Position',stats(indiceLogo(i)).BoundingBox,'EdgeColor','r','LineWidth',3);
E = stats(indiceLogo(i)).BoundingBox;
end
%% Mostrar resultado %%

X=E.*[1 0 0 0]; X=max(X); %Determina eje X esquina superior Izq. Placa
Y=E.*[0 1 0 0]; Y=max(Y); %Determina eje Y esquina superior Der. Placa
W=E.*[0 0 1 0]; W=max(W); %Determina Ancho Placa
H=E.*[0 0 0 1]; H=max(H); %Determina Altura placa
Corte=[X Y (W-2) (H-7)]; %Determina coordenadas de corte
IMF=imcrop(orig,Corte);
I1 = orig(:,:,1);
[M,N] = size(IMF);

figure; imagesc(IMF); title('qqq');colormap gray; axis equal;

np=number_plate(img2);

disp(np);
%numberPlateExtraction(IMF);