% change filename and dir appropriately
fileName = 'videos/lego.mp4';
dir = 'videos/frames/shots-lego/';

v = VideoReader(fileName);
prevFrame = [];
i = 1;

% for analysis
diffs = zeros(1, v.NumberOfFrames);

lowerThreshold = 120000; % clown
upperThreshold = Inf;

% lowerThreshold = 95000; % parliament
% upperThreshold = Inf;

% lowerThreshold = 165000;   
% upperThreshold = 210000;

for i = 1:v.NumberOfFrames
    
    frame = read(v,i);
    frameGray = rgb2gray(frame);
    
    num = num2str(i);
    resultFileName = strcat(dir, 'shot-', num, '.jpg');
    
    
    if (size(prevFrame,1) > 0)
        [shotDetected, totalDiff] = shotDetectHist(prevFrame, frameGray, lowerThreshold, upperThreshold);
        diffs(i) = totalDiff;
        if shotDetected > 0
              imwrite(frame, resultFileName);
        end
    end

    prevFrame = frameGray;
    
end