%Project: Pollen Recoginaztion
path=strcat(pwd,'/pollen_images/');
work_dir=dir(path);
OrgSet = [];
Plant_Name = {};
for i = 4 : size(work_dir,1)
    filename = strcat(path,work_dir(i).name);
    pci = image_preprocess(imread(filename));
    I = ismember(work_dir(i).name(1:length(work_dir(i).name)-5),Plant_Name);
    if ~I
        Plant_Name = [Plant_Name, work_dir(i).name(1:length(work_dir(i).name)-5)];
    end
    for j = 1 : size(Plant_Name,2)
        if strcmp(Plant_Name(1,j),work_dir(i).name(1:length(work_dir(i).name)-5)) 
            I = j;
            break;
        end
    end
    attr = [feature_extraction(pci), I];
    OrgSet = [ OrgSet; attr];
end
Plant_Name'
save result.txt OrgSet -ascii
arffwrite('pollen',OrgSet);
