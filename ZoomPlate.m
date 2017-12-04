function [ F ] = ZoomPlate( img )

BW = edge(img, 'canny',0.5);
%figure;imshow(BW); title(‘BW CANNY’);
[M,N] = size(BW)

B = zeros(M,1)

for i=1:1:M
aux=1;
pixel = zeros(3,1);
for j=1:1:N
pixel(aux)=BW(i,j);
aux=aux+1;

if aux > 3
aux = 1;
if ( pixel(1) == 0 && pixel(2) == 0 && pixel(3) == 1)
B(i) = B(i) + 1;
end
if ( pixel(1) == 1 && pixel(2) == 0 && pixel(3) == 1)
B(i) = B(i) + 1;
end
pixel = zeros(3,1);
end
end
end
%figure;plot(B,M:-1:1);
[maxv,maxi]=max(B);
Lindex = maxi-81;
Hindex = maxi+81;
Corte=[0 Lindex N Hindex]; %Determina coordenadas de corte
F=imcrop(img,Corte);
%figure;imshow(F);
end