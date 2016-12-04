function video(filename)
v = VideoReader(filename);

model_path = 'dpm_baseline.mat';
face_model = load(model_path);
detection_threshold = 0; 

nms_threshold = 0.3;

k = 1;
while hasFrame(v)
    s(k).cdata = readFrame(v);
    k = k+1;
end
h = waitbar(0,sprintf('Detecting faces in %s', filename));
mkdir(sprintf('./%s-detections',filename));
for i = 1:size(s, 2)
    waitbar(i / k)
    exTestImage = s(i).cdata;
    image = rgb2gray(exTestImage);
    [ds, bs] = process_face(image, face_model.model,  ...
                            detection_threshold, nms_threshold);
    if size(ds,1) ~= 0
        fname=sprintf('./%s-detections/frame-%i',filename,i);
        save(fname, 'ds');
    end
    
end
close(h);
end

