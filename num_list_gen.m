function num_list = num_list_gen(size,imds,idx)

for i=1:size
    fileName = imds.Files{i};
    [filepath,name,ext] = fileparts(fileName);
    C = strsplit(name,'_');
    
    Num = str2num(C{idx});
    num_list(i,1) = Num;
end
