function [xr,yr,num_inliers_best,matchesFound] = logoDetect(logo, img)
  try  
    img1 = single(rgb2gray(imread(logo)));
%     img1 = imresize(img1, 0.2);
    % feature points and descriptors using vlfeat's SIFT
    [fa,da] = vl_sift(img1);

    img2 = single(rgb2gray(imread(img)));
    % feature points and descriptors using vlfeat's SIFT
    [fb,db] = vl_sift(img2);

%     h1a = vl_plotframe(fa) ;
%     h2a = vl_plotframe(fa) ;

    %size(fa(:,sela))

    eucd = pdist2((double(da))',(double(db))', 'euclidean');
    % Matrix of min and second min distance
    minAndSecondMin = zeros(size(eucd,1),2);

    % Get min and second min distance
    for i=1:size(eucd,1)
        currRow = eucd(i,:);
        minD = min(currRow);
        scndMinD = min(currRow(currRow>minD));
        minAndSecondMin(i,1) = minD;
        minAndSecondMin(i,2) = scndMinD;
    end


    ratiosD = zeros(size(minAndSecondMin,1),1);
    % Get reliability ratio
    for i=1:size(minAndSecondMin,1)
        ratiosD(i) = minAndSecondMin(i,1) / minAndSecondMin(i,2);
    end

    matchThreshold = 0.8;

    % holds ratio, x1, y1, x2, y2
    % ratio is important for getting top k correspondents
    matchingVectorPoints = zeros(size(eucd,1), 5);

    % Get indices of matching vector pairs
    for i=1:size(ratiosD,1)
%         ratiosD(i,1)
        if ratiosD(i,1) < matchThreshold
            v1index = i;
            v2index = find(eucd(i,:) == minAndSecondMin(i,1));
    %         matchingVectorPairIndices(i,1) = i;
    %         matchingVectorPairIndices(i,2) = v2index;
            matchingVectorPoints(i,1) = ratiosD(i,1);
            matchingVectorPoints(i,2) = fa(1,v1index);
            matchingVectorPoints(i,3) = fa(2,v1index);
            matchingVectorPoints(i,4) = fb(1,v2index);
            matchingVectorPoints(i,5) = fb(2,v2index);
        end 
    end
    % get rid of zeroes
    matchingVectorPoints = matchingVectorPoints(any(matchingVectorPoints,2),:);

    %matchingVectorPoints
    %plot(matchingVectorPoints(:,1))
    % figure; imagesc(img1); hold on; plot(matchingVectorPoints(:,2),matchingVectorPoints(:,3),'*');colormap(gray);
    % figure; imagesc(img2); hold on; plot(matchingVectorPoints(:,4),matchingVectorPoints(:,5),'*');colormap(gray);

    sortedMatchesByCorrespondence = sortrows(matchingVectorPoints);

%     fg = figure;imagesc(img1);axis image;colormap(gray);hold on;
%     drawnow;
%     [x,y] = ginput(4);
% %     [x,y]
%     x
%     y
    
    %%% SCREENSHOT COORDINATES 
    if strcmp(logo, 'logos/cbc_logo_screenshot.jpg') == 1
        x = [0; 95; 95; 0];
        y = [0; 0; 95; 95];
    end
    %%%
    if strcmp(logo, 'logos/cbc_logo_screenshot2.jpg') == 1
        x = [0; 75; 75; 0];
        y = [0; 0; 75; 75];
    end

    if strcmp(logo, 'logos/cbc_white_bg.jpg') == 1
        x = [33; 473; 473; 33];
        y = [33; 33; 473; 473];
    end

    if strcmp(logo, 'logos/cbc-logo-720-big.jpg') == 1
        x = [0; 142; 142; 0];
        y = [0; 0; 142; 142];
    end

    if strcmp(logo, 'logos/cbc-logo-720-small.jpg') == 1
        x = [0; 104; 104; 0];
        y = [0; 0; 104; 104];
    end
    
    if strcmp(logo, 'logos/cbc-logo-big.jpg') == 1
        x = [0; 1247; 1247; 0];
        y = [0; 0; 1247; 1247];
    end


    % x = [0; 285; 285; 0];
    % y = [0; 0; 285; 285];

    k = 1;

    num_inliers_best = 0;
    inlierThreshold = 200;
    k = 0;
    noMatchesFound = 0;
    
    while(k<600)
        
        num_inliers = 0;

    %     k = size(matchingVectorPoints, 1);
    %     k = input(sprintf('Enter a value for k between 1 and %d\n',k));
    %     
        % GET top-k correspondence
        % ratio, x1, y1, x2, y2
        % randomPoints = sortedMatchesByCorrespondence(1:k,:);
        
        if (size(sortedMatchesByCorrespondence,1) <= 2)
            noMatchesFound = 1;
            break;
        end
        
        
        k1 = randi(size(sortedMatchesByCorrespondence, 1));
        k2 = randi(size(sortedMatchesByCorrespondence, 1));

        while (k1 == k2)
            k2 = randi(size(sortedMatchesByCorrespondence, 1));
        end
        k3 = randi(size(sortedMatchesByCorrespondence, 1));
        while (k3 == k1 | k3 == k2)
            k3 = randi(size(sortedMatchesByCorrespondence, 1));
%             k3
        end

        randomPoints = [sortedMatchesByCorrespondence(k1,2:5); ...
                        sortedMatchesByCorrespondence(k2,2:5); ...
                        sortedMatchesByCorrespondence(k3,2:5)];

        P = zeros(size(randomPoints,1)*2, 6);
        Pprime = zeros(size(randomPoints,1), 1);

        %populate P and P'
        for i=1:size(randomPoints,1)*2
            % every first r`ow
            if mod(i,2) ~= 0
                xi = randomPoints(ceil(i/2),1);
                yi = randomPoints(ceil(i/2),2);
                xiprime = randomPoints(ceil(i/2),3);
                P(i,1) = xi;
                P(i,2) = yi;
                P(i,5) = 1;
                Pprime(i,1) = xiprime;

            % every second row
            else
                xi = randomPoints((i/2),1);
                yi = randomPoints((i/2),2);
                yiprime = randomPoints((i/2),4);

                P(i,3) = xi;
                P(i,4) = yi;
                P(i,6) = 1;
                Pprime(i,1) = yiprime;
            end

        end

        % a = (P^T P)^-1 P^T P'
        % Moore Penrose pseudoinverse: pinv(A) = (A^T A)^-1 A^T
        % 
        PTP = P.' * P;
        %inverse of PTP using Moore Penrose
        PTPinv = ((PTP.' * PTP)^(-1)) * PTP.';

        A = PTPinv * P.' * Pprime;
        Pallmatches = zeros(size(sortedMatchesByCorrespondence,1),6);
        for i=1:size(sortedMatchesByCorrespondence,1)*2
            % every first row
            if mod(i,2) ~= 0
                xi = sortedMatchesByCorrespondence(ceil(i/2),2);
                yi = sortedMatchesByCorrespondence(ceil(i/2),3);

                Pallmatches(i,1) = xi;
                Pallmatches(i,2) = yi;
                Pallmatches(i,5) = 1;

            % every second row
            else
                xi = sortedMatchesByCorrespondence((i/2),2);
                yi = sortedMatchesByCorrespondence((i/2),3);

                Pallmatches(i,3) = xi;
                Pallmatches(i,4) = yi;
                Pallmatches(i,6) = 1;

            end
        end

        transformedPointsAll = Pallmatches * A;

        % Get number of inliers based on distThreshold
        for i=1:size(sortedMatchesByCorrespondence,1)
            if mod(i,2) == 0
                xp = sortedMatchesByCorrespondence(i/2,4);
                yp = sortedMatchesByCorrespondence(i/2,5);
                xpp = transformedPointsAll(i-1);
                ypp = transformedPointsAll(i);

                if pdist2([xp,yp], [xpp,ypp], 'euclidean') <= inlierThreshold
                    num_inliers = num_inliers + 1;
                end
            end
        end

        if num_inliers > num_inliers_best
            num_inliers_best = num_inliers;
            bestTransform = A;
        end
    %     
    %     num_inliers_best
    %     bestTransform

        %Get euclidean distance between transformed points and points in P'


    %     plotPoints = [];
    %     for i = 1:size(x)
    %         plotPoints(size(plotPoints,1)+1,:) = [x(i) y(i) 0 0 1 0];
    %         plotPoints(size(plotPoints,1)+1,:) = [0 0 x(i) y(i) 0 1];
    %     end
    %    figure; imagesc(img2); axis image; hold on; plot(randomPoints(:,3), randomPoints(:,4),'*'); colormap(gray);
    %     
    %   
    %     parallelogram = plotPoints * A;
    %     yr = parallelogram(2:2:length(parallelogram));
    %     xr = parallelogram(1:2:length(parallelogram));
    %     
    %     xr= [xr' xr(1)];
    %     yr= [yr' yr(1)];
    % 
    %     figure, imagesc(img), axis image, colormap(gray),hold on
    %     plot(xr,yr);
    %     hold off;
    %     
    %     eucd = pdist2((double(da))',(double(db))', 'euclidean');


    %     
    %     figure, imagesc(img2), axis image, colormap(gray),hold on
    %     plot(plots(:,1), plots(:,2), '*');
    %     hold off;
        k = k + 1;

    end
    
    
    if noMatchesFound == 1
        xr = [0 0 0 0 0];
        yr = [0 0 0 0 0];
        matchesFound = 0; % return variable
        num_inliers_best = 0;
        
    else
        bestSoFar = Pallmatches * bestTransform;
        plots = zeros(size(bestSoFar,1)/2,2);
        for i=1:size(bestSoFar,1)
            if mod(i,2) ~= 0
                plots(ceil(i/2),1) = bestSoFar(i);
            else
                plots(i/2,2) = bestSoFar(i); 
            end
        end
        %plots

%     figure, imagesc(img2), axis image, colormap(gray),hold on
%         plot(plots(:,1), plots(:,2), '*');
%         hold off;


        plotPoints = [];
        for i = 1:size(x)
            plotPoints(size(plotPoints,1)+1,:) = [x(i) y(i) 0 0 1 0];
            plotPoints(size(plotPoints,1)+1,:) = [0 0 x(i) y(i) 0 1];
        end
    %    figure; imagesc(img2); axis image; hold on; plot(randomPoints(:,3), randomPoints(:,4),'*'); colormap(gray);

%        num_inliers_best
        parallelogram = plotPoints * bestTransform;
        yr = parallelogram(2:2:length(parallelogram));
        xr = parallelogram(1:2:length(parallelogram));

        xr= [xr' xr(1)];
        yr= [yr' yr(1)];
        matchesFound = 1;
    end
    
    noMatchesFound = 0;
%         imagesc(imread(img)), axis image, colormap(gray),hold on
%         plot(xr,yr),
%         hold off;

  catch
      
         xr = [0 0 0 0 0];
        yr = [0 0 0 0 0];
        matchesFound = 0; % return variable
        num_inliers_best = 0;
      
  end
%         out = 0;
end