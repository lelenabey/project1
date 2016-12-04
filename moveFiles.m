for f = 1:4
[numData,textData,rawData] = xlsread(strcat('./Face Data/fold_',num2str(f),'_gender.csv'));

size(find([rawData{:,4}] == 'm'))
for i = 2:size(rawData ,1)
    if (rawData{i,4} == 'm' || rawData{i,4} == 'f')
        movefile(strcat('./Face Data/images/aligned/',rawData{i,1},'/landmark_aligned_face.',num2str(rawData{i,3}) ,'.',rawData{i,2}),strcat('./Face Data/images/classified/', rawData{i,4}));
    end;
end
end