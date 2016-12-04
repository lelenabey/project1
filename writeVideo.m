function writeVideo(filename)
v = VideoReader(filename);
vid_num = 0;
while exist(sprintf('redone-%s%i',filename,vid_num),'file')==2
    vid_num = vid_num+1;
end
w = VideoWriter(sprintf('redone-%s%i',filename, vid_num), 'MPEG-4');

open(w);
k = 1;
j = 0;
while hasFrame(v)
    image = readFrame(v);
    if exist(sprintf('./%s-shots/shot-%d.jpg',filename,k),'file')==2
        j = 30;
    end
    if j >  0
        j = j-1;
        image = imcomplement(image);
    end
    if exist(sprintf('./%s-classified/frame-%d.mat',filename,k),'file')==2
        detections = load(sprintf('./%s-classified/frame-%d.mat',filename,k), 'ds');
        showsboxes_face(image, detections.ds);
        text(detections.ds(:,1), detections.ds(:,2), num2str(detections.ds(:,7)),'Color', 'y','FontSize',12);
        text(detections.ds(:,3), detections.ds(:,4), char(detections.ds(:,8)),'Color', 'y','FontSize',12);
        truesize([v.height, v.width-1]);
        F = getframe();
        writeVideo(w, F);
    else
        writeVideo(w, image);
    end
    k = k+1;
end
close(w);
end