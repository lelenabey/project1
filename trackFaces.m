function trackFaces(filename)
v = VideoReader(filename);
frames = length(dir(sprintf('./%s-detections',filename)));
k = 1;
prev_faces = {};
prev_locs = [];
id =0;
mkdir(sprintf('./%s-tracked',filename));
h = waitbar(0,sprintf('Tracking faces in %s', filename));
while hasFrame(v)
    waitbar(k / frames)
    centers = [];
    image = rgb2gray(readFrame(v));
    k = k+1
    faces = {};
    if exist(sprintf('./%s-detections/frame-%d.mat',filename,k),'file')==2
        detections = load(sprintf('./%s-detections/frame-%d.mat',filename,k), 'ds');
        
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
            end
            prevd = detections;
        end
        
        euc = pdist2(centers, prev_locs);
        
        for i = 1:num_faces
            max_points = 0;
            if min(euc(i,:))<=1000
                match = euc(i,:)==min(euc(i,:));
                detections.ds(i,7) = prevd.ds(match,7);
            else
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
            end
            
        end  
        fname=sprintf('./%s-tracked/frame-%i',filename,k);
        ds = detections.ds;
        save(fname, 'ds');
        prevd = detections;
        prev_locs = centers;
        end
        
    end
    close(h);
end