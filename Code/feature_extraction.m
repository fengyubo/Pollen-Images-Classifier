function [features] = feature_extraction(pci)
%pci = imread('Calytrix tetragona.jpg'); 
%pci = image_preprocess(pci);
pci_bin = rgb2gray(pci);

pci_label = labelmatrix(bwconncomp(pci_bin));
pci_geo_pp = regionprops(pci_label,'all');

%geometric paramaters
pci_Area = pci_geo_pp.Area;
pci_BoundingBox = [ pci_geo_pp.BoundingBox(3) pci_geo_pp.BoundingBox(4)];
pci_WeightedCentroid = pci_geo_pp.Centroid;%Weighted Centroid: by gray-scale image
    pCentroid = regionprops(labelmatrix(bwconncomp(pci)),'Centroid');%Centroid: by RGB image
pci_Centroid = pCentroid.Centroid(1:2);
pci_MajorAxisLength = pci_geo_pp.MajorAxisLength;
pci_MinorAxisLength = pci_geo_pp.MinorAxisLength;
pci_ConvexArea = pci_geo_pp.ConvexArea;
pci_EquivDiameter = pci_geo_pp.EquivDiameter;
pci_Solidity = pci_geo_pp.Solidity;
pci_Perimeter = pci_geo_pp.Perimeter;
pci_Extent = pci_geo_pp.Extent;
pci_Eccentricity = pci_geo_pp.Eccentricity;
pci_shape = 4*pi*pci_Area/pci_Perimeter^2;
pci_Box = [pci_BoundingBox(1)/4 pci_BoundingBox(2)/4 pci_BoundingBox(1)/2 pci_BoundingBox(2)/2];
pci_Height = max(sum(pci_label));
pci_Width = max(sum(pci_label,2));
%feature done, expect for WeightedCentroid apci_geo_pp the pci_geo_ppame apci_geo_pp Centroide

%texture feature extraction
%center region image isolate
pci_texture = pci( round(pci_geo_pp.BoundingBox(2)+pci_Box(2)):round(pci_geo_pp.BoundingBox(2)+pci_Box(4)), round(pci_geo_pp.BoundingBox(1)+pci_Box(1)):round(pci_geo_pp.BoundingBox(1)+pci_Box(3)),:);
%texture Contrast, Correlation, Energy, Homogeneity abstraction
    glcms = graycomatrix(rgb2gray(pci_texture));
    stats = graycoprops(glcms,'all');
pci_texture_Constast = stats.Contrast;
pci_texture_Correlation = stats.Correlation;
pci_texture_Energy = stats.Energy;
pci_texture_Homogeneity = stats.Homogeneity;

%texture Entropies for six attributes
%BB: Bounding Box
%pci_BB_rgb = pci(round(pci_geo_pp.BoundingBox(2)):round(pci_geo_pp.BoundingBox(2)+pci_geo_pp.BoundingBox(3)), round(pci_geo_pp.BoundingBox(1)): round(pci_geo_pp.BoundingBox(1)+pci_geo_pp.BoundingBox(4)),:);
pci_BB_rgb = pci;
pci_BB_hsv = rgb2hsv(pci_BB_rgb);
pci_BB_Blue_Entropy = entropy(pci_BB_rgb(:,:,3));
pci_BB_Sat_Entropy = entropy(pci_BB_hsv(:,:,2));
pci_BB_Val_Entropy = entropy(pci_BB_hsv(:,:,3));
%B: Box
pci_B_rgb = pci_texture;
pci_B_hsv = rgb2hsv(pci_B_rgb);
pci_B_Blue_Entropy = entropy(pci_B_rgb(:,:,3));
pci_B_Sat_Entropy = entropy(pci_B_hsv(:,:,2));
pci_B_Val_Entropy = entropy(pci_B_hsv(:,:,3));


%Fourier Descriptor, Relative areas, Relative objects
    %C = imcontour(pci_bin,2);
    [x,y] = find(pci_bin,1);
    contour = bwtraceboundary(pci_bin,[x y],'N',8,nnz(pci_bin),'clockwise');
    sort(contour,1);
    %plot(contour(:,2),contour(:,1),'g','LineWidth',2);
    pci_tfd = dct(abs(fft(contour(:,2).*[0:size(contour,1)-1]')));
pci_FourierDescriptors = pci_tfd(1:5);

% Relative areas
% Relative objects
pci_rel_area = [];
pci_rel_objs = [];
for i = 1 : 5
     tmp_img = im2bw(pci_bin, 0.2+i/10);
     pci_rel_area = [pci_rel_area sum(sum(tmp_img))];
     CC = bwconncomp(tmp_img);
     pci_rel_objs = [ pci_rel_objs, CC.NumObjects ];
end
format long g
pci_pp = [];
pci_pp = [ pci_pp pci_BoundingBox]; 
pci_pp = [ pci_pp pci_WeightedCentroid]; 
pci_pp = [ pci_pp pci_Centroid]; 
pci_pp = [ pci_pp pci_MajorAxisLength]; 
pci_pp = [ pci_pp pci_MinorAxisLength];
pci_pp = [ pci_pp pci_ConvexArea];
pci_pp = [ pci_pp pci_EquivDiameter];
pci_pp = [ pci_pp pci_Solidity];
pci_pp = [ pci_pp pci_Perimeter];
pci_pp = [ pci_pp pci_Extent];
pci_pp = [ pci_pp pci_Eccentricity];
pci_pp = [ pci_pp pci_shape];
pci_pp = [ pci_pp pci_Box];
pci_pp = [ pci_pp pci_Height];
pci_pp = [ pci_pp pci_Width];
pci_pp = [ pci_pp pci_texture_Constast];
pci_pp = [ pci_pp pci_texture_Correlation];
pci_pp = [ pci_pp pci_texture_Energy];
pci_pp = [ pci_pp pci_texture_Homogeneity];
pci_pp = [ pci_pp pci_BB_Blue_Entropy];
pci_pp = [ pci_pp pci_BB_Sat_Entropy];
pci_pp = [ pci_pp pci_BB_Val_Entropy];
pci_pp = [ pci_pp pci_B_Blue_Entropy];
pci_pp = [ pci_pp pci_B_Sat_Entropy];
pci_pp = [ pci_pp pci_B_Val_Entropy];
pci_pp = [ pci_pp pci_FourierDescriptors'];
pci_pp = [ pci_pp pci_rel_area];
pci_pp = [ pci_pp pci_rel_objs];
features = pci_pp;
end

