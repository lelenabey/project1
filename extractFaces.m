%function extractFaces(filename)
filename = 'clowns.mp4'
v = VideoReader(filename);

k = 1;
faces = {};
while hasFrame(v)
    image = readFrame(v);

    if exist(sprintf('./%s-classified/frame-%d.mat',filename,k),'file')==2
        detections = load(sprintf('./%s-classified/frame-%d.mat',filename,k), 'ds');
        num_faces = size(detections.ds,1);
        for j = 1:num_faces
            %centers(j,:) = [detections.ds(j,1)+(detections.ds(j,3)-detections.ds(j,1))/2 detections.ds(j,2)+(detections.ds(j,4)-detections.ds(j,2))/2];
            height = detections.ds(j,4)- detections.ds(j,2);
            width = detections.ds(j,3)-detections.ds(j,1);
            if size(faces,1)< detections.ds(j,7)
                faces(detections.ds(j,7)) = {imcrop(image, [detections.ds(j,1) detections.ds(j,2) width height])};
            end
        end
    end
    k = k+1;
end
mkdir(sprintf('./%s-faces',filename));
for i = 1:size(faces,2)
    face = faces{i};
    imwrite(imresize(face, [100 100]), sprintf('./%s-faces/face-%i.jpg',filename, i), 'jpg');
end
%end