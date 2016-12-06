function [shotDetected, totalDiff] = shotDetectHist(prevFrame, frame, lowerThresh, upperThresh)

    [countPrev, locsPrev] = imhist(prevFrame);
    
    [count, locs] = imhist(frame);
    
    totalDiff = 0;
    
    for i = 1:length(locs)
        totalDiff = totalDiff + abs(count(i) - countPrev(i));
    end
 

    shotDetected =  0;
    if totalDiff > lowerThresh && totalDiff < upperThresh
        shotDetected = 1;
    end
        
end
