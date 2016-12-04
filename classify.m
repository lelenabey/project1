%function classify(filename)
filename = 'clowns.mp4'
v = VideoReader(filename);
frames = length(dir(sprintf('./%s-detections',filename)));
k = 1;
prev_faces = {};
prev_locs = [];
id =0;
mkdir(sprintf('./%s-classified',filename));
h = waitbar(0,sprintf('classifying faces in %s', filename));
hog_8x8 = extractHOGFeatures(double(zeros(102, 102)),'CellSize',[8 8]);
cellSize = [8 8];
hogFeatureSize = length(hog_8x8);
%gender_model  = load('./Face Data/images/classified/gender_model.mat');

while hasFrame(v)
    waitbar(k / frames)
    centers = [];
    image = readFrame(v);
   
    faces = {};
    if exist(sprintf('./%s-detections/frame-%d.mat',filename,k),'file')==2
        detections = load(sprintf('./%s-detections/frame-%d.mat',filename,k), 'ds');
        features  =[];
        num_faces = size(detections.ds,1);
        for j = 1:num_faces
            centers(j,:) = [detections.ds(j,1)+(detections.ds(j,3)-detections.ds(j,1))/2 detections.ds(j,2)+(detections.ds(j,4)-detections.ds(j,2))/2];
            x1 = detections.ds(j,2):detections.ds(j,4);
            y1 = detections.ds(j,1):detections.ds(j,3);
            x1 = round(x1(x1<=size(image,1)));
            y1 = round(y1(y1<=size(image,2)));
            faces{j,1} = image(x1 ,y1);
            faces{j,2} = 0;
        end
        
        if isempty(prev_faces)
            prev_locs = centers;
            for i = 1:num_faces
                id= id+1;
                faces{i,2} = id;
            end
            prev_faces = [prev_faces; faces];
            
            for i = 1:num_faces
                max_points = 0;
                for j = 1:size(prev_faces,1)
                [points, affine] = affine_t(faces{i,1}, prev_faces{j,1}, 0.75);
                 if max_points < size(points, 1)
                    max_points = size(points, 1)
                    faces{i,2} = prev_faces{j,2};
                 end
                end
                if faces{i,2} == 0
                    id= id+1;
                    faces{i,2} = id;
                    prev_faces = [prev_faces; faces(i,:)]
                    detections.ds(i,7) = faces{i,2};
                else
                    detections.ds(i,7) = faces{i,2};
                end
                img = imresize(faces{i,1},[50 50]);
                features = extractHOGFeatures(img, 'CellSize', cellSize);
                [predicted_label, accuracy, decision_values] = svmpredict(double(i), double(features), gender_model.gender_model);
                detections.ds(i,8)=predicted_label;
                faces{i,3} = predicted_label;
                prev_faces{i,3} = predicted_label;
                features  = [];
            end
            
            prevd = detections;
        end
        
        euc = pdist2(centers, prev_locs);
        
        for i = 1:num_faces
            max_points = 0;
            if min(euc(i,:))<=1000
                match = euc(i,:)==min(euc(i,:));
                detections.ds(i,7) = prevd.ds(match,7);
                detections.ds(i,8) = prevd.ds(match,8);
            else
                for j = 1:size(prev_faces,1)
                [points, affine] = affine_t(faces{i,1}, prev_faces{j,1}, 0.75);
                 if max_points < size(points, 1)
                    max_points = size(points, 1)
                    faces{i,2} = prev_faces{j,2};
                    faces{i,3} = prev_faces{j,3};
                 end
                end
                if faces{i,2} == 0
                    id= id+1;
                    faces{i,2} = id;
                   
                    detections.ds(i,7) = faces{i,2};
                    
                    img = imresize(faces{i,1},[50 50]);
                    features = extractHOGFeatures(img, 'CellSize', cellSize);
                    [predicted_label, accuracy, decision_values] = svmpredict(double(i), double(features), gender_model.gender_model);
                    detections.ds(i,8)=predicted_label;
                    faces{i,3} = predicted_label;
                    prev_faces = [prev_faces; faces(i,:)]
                    features  = [];
                else
                    detections.ds(i,7) = faces{i,2};
                    detections.ds(i,8) = faces{i,3};
                end
            end
            
        end  
        fname=sprintf('./%s-classified/frame-%i',filename,k);
        ds = detections.ds;
        save(fname, 'ds');
        prevd = detections;
        prev_locs = centers;
        end
        k = k+1
    end
    close(h);
%end