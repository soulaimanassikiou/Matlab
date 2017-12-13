function [ F ] = ZoomPlate( img )

BW = edge(img, 'canny',0.5);
figure;imshow(BW); title('BW CANNY');
[M,N] = size(BW)

B = zeros(M,1)

R = [];
R2 = [];
cnt = 1;
cnt2 = 1;
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
                R(cnt,:) = [i j];
                cnt = cnt + 1;
            end
            if ( pixel(1) == 1 && pixel(2) == 0 && pixel(3) == 1)
                B(i) = B(i) + 1;
                
                R2(cnt2,:) = [i j];
                cnt2 = cnt2 + 1; 
            end
            pixel = zeros(3,1);
        end
    end
end
figure;plot(B,M:-1:1);
[maxv,maxi]=max(B);
Lindex = maxi-40;
Hindex = maxi+40;
Corte=[0 Lindex N Hindex]; %Determina coordenadas de corte
F=imcrop(img,Corte);
figure;imshow(F);


hold on;
%plot(R2(:,2),R2(:,1),'r+');

% hold on;
 plot(R(:,2),R(:,1),'y+');
end