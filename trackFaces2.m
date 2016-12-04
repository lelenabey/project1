function trackFaces2(filename)
v = VideoReader(filename);

k = 0;
prev = [];
id =0;
mkdir(sprintf('./%s-tracked',filename));
while hasFrame(v)
    centers = [];
    image = readFrame(v);
    k = k+1;
    if exist(sprintf('./%s-detections/frame-%d.mat',filename,k),'file')==2
        detections = load(sprintf('./%s-detections/frame-%d.mat',filename,k), 'ds');
        num_faces = size(detections.ds,1);
        for j = 1:num_faces
            centers(j,:) = [detections.ds(j,1)+(detections.ds(j,3)-detections.ds(j,1))/2 detections.ds(j,2)+(detections.ds(j,4)-detections.ds(j,2))/2];
        end
        if isempty(prev)
            prev = centers;
            for j = 1:num_faces
                id = id+1;
                detections.ds(j,7) = id;
            end
            prevd = detections;
        end
       
        euc = pdist2(centers, prev);
        for i = 1:num_faces
            if min(euc(i,:))<=1000
                match = euc(i,:)==min(euc(i,:));
                detections.ds(i,7) = prevd.ds(match,7);
            else
                id = id+1;
                detections.ds(i,7) = id;
            end
        end
        
        fname=sprintf('./%s-tracked/frame-%i',filename,k);
        ds = detections.ds;
        save(fname, 'ds');
        prevd = detections;
        prev = centers;

    else
        
    end
    
end

end