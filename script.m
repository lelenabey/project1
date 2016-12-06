cellSizes = {[2 2] [4 4] [8 8]};
cellSize = [4 4];
imageSizes = {[50 50] [75 75] [100 100]};
imageSize = [50 50];
filenames = {'legoman.mp4', 'parliament.mp4', 'clowns.mp4'};
cells = 3;
images = 1;
i = 3;
%for cells = 1:3
 %   for images = 1:3
        training(30, cellSizes{cells}, imageSizes{images});
        %for i = 1:size(filenames,2)
            %video(filenames{i});
            classify(filenames{i},  cellSizes{cells}, imageSizes{images});
            writeVideo(filenames{i});
        %end
%    end
%end
% training(1000, cellSize, imageSize);
% classify('parliament-720.mp4')
% writeVideo('parliament-720.mp4')
% filenames = {'legoman.mp4', 'parliament.mp4', 'clowns.mp4'};
