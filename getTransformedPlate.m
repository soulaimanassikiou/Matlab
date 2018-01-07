function [ imagine2 ] = getTransformedPlate( imagine )
%GETTRANSFORMEDPLATE Summary of this function goes here
%   Detailed explanation goes here
    

BW = edge(rgb2gray(imagine), 'canny');

    %# hough transform
    [H T R] = hough(BW);
    P  = houghpeaks(H, 4, 'threshold',ceil(0.75*max(H(:))));
    lines = houghlines(BW, T, R, P);

    % shearing transformata
    slopes = vertcat(lines.point2) - vertcat(lines.point1);
    slopes = slopes(:,2) ./ slopes(:,1);
    TFORM = maketform('affine', [1 -slopes(1) 0 ; 0 1 0 ; 0 0 1]);
    imagine2 = imtransform(imagine, TFORM);

    %# show image with lines overlayed, and the aligned/rotated image
    %axes(handles.ImagineRotita)
    %imshow(imagine2); 

    imagineGrey = rgb2gray(imagine2);

%-----------------------------------------------------------------

    %axes(handles.ImaginePrel1)
    %imshow(imagineGrey);

    imagineFiltrata = medfilt2(imagineGrey,[3 3]);
    %axes(handles.ImagineFilt)
    %imshow(imagineFiltrata);

    SE = strel('disk',1);
    GrayDil = imdilate(imagineGrey,SE);
    GrayEr = imerode(imagineGrey,SE);
    gdiff = imsubtract(GrayDil,GrayEr);
    gdiff = mat2gray(gdiff);
    gdiff = conv2(gdiff,[1 1;1 1]);
    gdiff = imadjust(gdiff,[0.5 0.7],[0 1],0.1);

    B = logical(gdiff);
    er = imerode(B,strel('line',50,0));
    out1 = imsubtract(B,er);

    imagineSobel = imfill(out1,'holes');

    H = bwmorph(imagineSobel,'thin',1);
    H = imerode(H,strel('line',3,90));

    final = bwareaopen(H,100);

    Iprops = regionprops(final,'BoundingBox','Image');

    %axes(handles.ImagineSobel)
    %imshow(final);

    imagineCuratata = imclearborder(final,18);
    imagineCuratata = bwareaopen(imagineCuratata,200);
    %axes(handles.ImagineSobelEd)
    %imshow(imagineCuratata);

    fileID = fopen('ImagineRezultata.txt','wb');
    dlmwrite('ImagineRezultata.txt',imagineCuratata);
    fclose('all');

    imagineCuratata2 = imagineCuratata;

    [dimX,dimY] = size(imagineCuratata2);

%-----------------------------------------------------------------
%-----------The licence plate is filled with white pixels---------
PrimPixelAlbStanga = 0;
PrimPixelAlbDreapta = 0;
Flag = 0;

for i = 1:dimX
    for j = 1:dimY
        if Flag == 0
            if imagineCuratata2(i,j) == 1
                PrimPixelAlbStanga = j;
                Flag = 1;
            end
        end
        if Flag == 1
            if imagineCuratata2(i,j) == 1
                PrimPixelAlbDreapta = j;
            end
        end
    end
    if PrimPixelAlbStanga > 0
        for k = PrimPixelAlbStanga:PrimPixelAlbDreapta
            imagineCuratata2(i,k) = 1;
        end
    end
    PrimPixelAlbStanga = 0;
    PrimPixelAlbDreapta = 0;
    Flag = 0;
end

%-----------------------------------------------------------------

%-----------------------------------------------------------------
%----------The smaller lines with white pixels are removed--------
%----------this is to eliminate all the smaller lines that--------
%--------------remained for example the logo sometimes------------

PrimPixelAlbStanga = 0;
PrimPixelAlbDreapta = 0;
Flag = 0;

for i = 1:dimX
    for j = 1:dimY
        if Flag == 0
            if imagineCuratata2(i,j) == 1
                PrimPixelAlbStanga = j;
                Flag = 1;
            end
        end
        if Flag == 1
            if imagineCuratata2(i,j) == 1
                PrimPixelAlbDreapta = j;
            end
        end
    end
    if PrimPixelAlbStanga > 0
        if (PrimPixelAlbDreapta - PrimPixelAlbStanga) < 40
            for k = PrimPixelAlbStanga:PrimPixelAlbDreapta
                imagineCuratata2(i,k) = 0;
            end
        end
    end
    PrimPixelAlbStanga = 0;
    PrimPixelAlbDreapta = 0;
    Flag = 0;
end

%axes(handles.ImagineCropata)
%imshow(imagineCuratata2);

%-----------------------------------------------------------------

%-----------------------------------------------------------------
%---------the corners of the licence plate are determined---------

imagineCuratata2 = bwareaopen(imagineCuratata2,500);

PrimaCoordX = 0;
PrimaCoordY = 0;
UltimaCoordX = 0;
UltimaCoordY = 0;
determinat = 0;

for i = 1:dimX
    for j = 1:dimY
        if imagineCuratata2(i,j) == 1
            if determinat == 0
                PrimaCoordX = j;
                PrimaCoordY = i;
                determinat = 1;
            else
                            UltimaCoordX = j;
                            UltimaCoordY = i;
            end            
        end
    end
end

PrimaCoordColX = 0;
PrimaCoordColY = 0;
UltimaCoordColX = 0;
UltimaCoordColY = 0;
determinatCol = 0;

for j = 1:dimY
    for i = 1:dimX
        if imagineCuratata2(i,j) == 1
            if determinatCol == 0
                PrimaCoordColX = j;
                PrimaCoordColY = i;
                determinatCol = 1;
            else                
                    UltimaCoordColX = j;
                    UltimaCoordColY = i;
            end            
        end
    end
end

    xmin = 0;
    ymin = 0;
    width = 0;
    height = 0;

    if PrimaCoordX < dimX/2
        xmin = PrimaCoordX;
        ymin = PrimaCoordY;
    else 
        xmin = PrimaCoordColX;
        ymin = PrimaCoordY;
    end

    xmin = xmin - xmin * 0.1;
    ymin = ymin * 1.1;

    if PrimaCoordX < dimX/2
        width = UltimaCoordX - PrimaCoordX;
        height = UltimaCoordY - PrimaCoordY;
    else
        width = UltimaCoordColX - PrimaCoordColX;
        height = UltimaCoordY - PrimaCoordY;
    end

    rect = [xmin ymin abs(width) abs(height)];

    RezultatCropat = imcrop(imagine2, rect);

    %axes(handles.ImagineCropataSiFilt)
    %imshow(RezultatCropat);

end





