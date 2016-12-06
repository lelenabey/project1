% logo1 = 'logos/cbc-logo-720-big.jpg';
% logo2 = 'logos/cbc-logo-720-small.jpg';


logo1 = 'logos/cbc_white_bg.jpg';

% logo1 = 'logos/cbc-logo-big.jpg';
% logo2 = 'logos/cbc-logo-big.jpg';

resultDir = 'results/logo/big-logo-whiteRef/';
numFrames = 8757;
% resultVideo = 'videos/logo-detect.mp4';
% vw = VideoWriter(resultVideo,'MPEG-4');
% open(vw);

 
%v = VideoReader(fileName);
%     
%     for i = 1 : v.NumberOfFrames
%         frame = read(v,i);
%         num = num2str(i);
%         imwrite(frame, strcat(directory, 'frame-', num, '.jpg'));
%     end
%     
%     out = 0;


% 1093 to 1100 <- big
% 1201 to 1209 <- small
% 6495 to 6503 <- occlusion

% Maybe if logo 720 big is low, take logo screenshot2

for i = 1093 : 1100

    num = num2str(i);
%     frameFileName = strcat('videos/frames/frames-trump-720/', 'frame-', num, '.jpg');
    frameFileName = strcat('videos/frames/frames-trump-720/', 'frame-', num, '.jpg');
    [xr,yr,inliers,matchesFound] = logoDetect(logo1, frameFileName);
    
    % too few inliers: run SIFT-RANSAC on second logo
%     if inliers < 10
%         [xr2, yr2, inliers2,matchesFound] = logoDetect(logo2, frameFileName);
%     end
%     
%     % if second logo is better, use it
%     if inliers2 > inliers
%         xr = xr2;
%         yr = yr2;
%         inliers = inliers2;
%     end
%     imagesc(imread(frameFileName)), axis image, colormap(gray),hold on
%         plot(xr,yr),
%         hold off;
    [im,cmap] = imread(frameFileName);
    width = int16(ceil(abs(xr(2) - xr(1))));
    height = int16(ceil(abs(yr(3) - yr(1))));
    
    if matchesFound == 1
        imWithOverlay = insertShape(im, 'Rectangle', [xr(1), yr(1), width, height]);
    else
        imWithOverlay = im;
    end
    
    resultFileName = strcat(resultDir, 'frame-', num, '.jpg');
    imwrite(imWithOverlay, resultFileName);
%     figure, imagesc(imWithOverlay), axis image;
%     frame = im2frame(imWithOverlay);

end
