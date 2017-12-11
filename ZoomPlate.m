function [ F ] = ZoomPlate( img )

%First of all we get the edges of the image which is already
%bidimensional(black and white)
BW = edge(img, 'canny',0.5);
[M,N] = size(BW)

B = zeros(M,1)

%Loop for every pixel
for i=1:1:M
aux=1;
pixel = zeros(3,1);
for j=1:1:N
pixel(aux)=BW(i,j);
aux=aux+1;

%We save in the B array the density of edges in every row
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
%We get the maximum values of the two columns of B
[maxv,maxi]=max(B);
Lindex = maxi-81;
Hindex = maxi+81;
%We determine the coordinates of the cut
Corte=[0 Lindex N Hindex];
F=imcrop(img,Corte);

end
