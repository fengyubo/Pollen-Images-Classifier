%function [pci_preprocess] = image_preprocess(pci)
%stretched pci 
pci  = imread('Acacia.jpg');
pci = imresize(pci,[150,150]);

%hsv transmission
pci_hsv = rgb2hsv(pci);

%hsv Saturation Channel abstraction
pci_hsv = pci_hsv(:,:,2);
%imshow(pci_hsv);

%histogram equalization
pci_hsv = histeq(pci_hsv);
%imshow(pci_hsv)

%gamma process
hgamma = vision.GammaCorrector(3.0,'Correction','De-gamma');
pci_gamma = step(hgamma, pci_hsv);
%imshow(pci_gamma)

%gaussion filter
pci_gaussion = imgaussfilt(pci_gamma);
imshow(pci_gaussion)

%graph threshold processing
pci_thresh = pci_gaussion;
%pci_thresh = rgb2gray(pci_gaussion);
thresholdi = graythresh(pci_gaussion);
pci_thresh  = im2bw(pci_gaussion, thresholdi);
imshow(pci_thresh)

% remove all object containing fewer than 30 pixels
%pci_thresh = bwareaopen(pci_thresh,20);
%imshow(pci_thresh)

% dilation
se = strel('square',4);
pci_dilation = imdilate(pci_thresh,se);
imshow(pci_dilation)

%hole filling
pci_holefilling = imfill(pci_dilation,'holes');
%imshow(pci_holefilling)

%erosion
pci_ero = imerode(pci_holefilling,se);
imshow(pci_ero)

%central connected componet abstraction
CC = bwconncomp(pci_ero);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
for i = 1 : size(numPixels,2)
    if i ~= idx
        pci_ero(CC.PixelIdxList{i}) = 0;
    end
end
RGB = zeros(size(pci));
RGB(:, :) = [ pci_ero pci_ero pci_ero];
pci_preprocess = pci.*uint8(RGB);
imshow(pci_preprocess)



