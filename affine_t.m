% I = imread('keyboard1.jpg');
% I = imresize(I,0.5);
% I = single(rgb2gray(I)) ;
% Ib = imread('keyboard2.jpg');
% Ib = imresize(Ib,0.5);
% 
% % I = imread('book.jpg');
% % I = single(rgb2gray(I)) ;
% % Ib = imread('findbook.jpg');
% 
% Ib = single(rgb2gray(Ib)) ;
% [f,d] = vl_sift(I) ;
% 
% [fb, db] = vl_sift(Ib) ;
% 
% 
% % figure, imagesc(I), axis image, colormap(gray),hold on
% % vl_plotframe(f(:, perm));
% % hold off;
% % figure, imagesc(I), axis image, colormap(gray),hold on
% % vl_plotsiftdescriptor(d(:,sel),f(:,sel));
% % hold off;
% % 
% % figure, imagesc(Ib), axis image, colormap(gray),hold on
% % vl_plotframe(fb(:,selb));
% % hold off;
% % figure, imagesc(Ib), axis image, colormap(gray),hold on
% % vl_plotsiftdescriptor(db(:,selb),fb(:,selb));
% % hold off;
% %set(h2,'color','y','linewidth',2) ;
% 
% %h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel)) ;
% %set(h3,'color','g') ;
% % matches = zeros(128, 2, size(d,2));
% % for i = 1:size(d,2)
% %     for j = 1:size(db,2)
% %         if abs(d(:,i) - db(:,j)) <= abs(matches(:,1,i))
% %             matches(:,2,i) = matches(:,1,i);
% %             matches(:,1,i) = d(:,i) - db(:,j);
% %         elseif abs(d(:,i) - db(:,j)) <= abs(matches(:,2,i))
% %             matches(:,2,i) = d(:,i) - db(:,j);
% %         end
% %     end
% %     
% % end
% 
% d = double(d);
% db = double(db);
% euc= pdist2(d', db', 'euclidean');
% sorted = sort(euc, 2);
% ratios=sorted(:,1)./sorted(:,2);
% 
% %copy_f(:,129)= ratios';
% %matches = sortrows(copy_f', 129)';
% 
% threshold = 0.8;
% matches = zeros(size(find(ratios<=threshold),1), 3);
% for i = 1:size(euc,1)
%     if ratios(i) < threshold
%         matches(i,1) = ratios(i);
%         matches(i,2)= i;
%         matches(i,3)=find(euc(i,:)==sorted(i,1));
%     end
% end
% 
% matches( ~any(matches,2), : ) = [];
% matching_points = zeros(size(matches,1), 5);
% 
% for i = 1:size(matches,1)
%     matching_points(i,1) = matches(i,1);
%     matching_points(i,2:3) = [f(1,matches(i,2)) f(2,matches(i,2))];
%     matching_points(i,4:5) = [fb(1,matches(i,3)) fb(2,matches(i,3))];
%     
% end


function [good_points, good_affine] = affine_t(I, Ib, threshold)
matching_points = get_matches(I,Ib , threshold);

% mmk = matching_points';
% figure, imagesc(I), axis image, colormap(gray),hold on
% plot(mmk(2,:),mmk(3,:),'g.') ;
% hold off;
% figure, imagesc(Ib), axis image, colormap(gray),hold on
% plot(mmk(4,:),mmk(5,:),'g.') ;
% hold off;

% format of matching points
% ratio | xcoord-img1 | ycoord-img1 | xcoord-img2 | ycoord-img2

matching_pointss = sortrows(matching_points, 1);
k = size(matching_pointss, 1);

% fg = figure;imagesc(I);axis image;hold on;colormap gray;
% drawnow;
% [x,y] = ginput(4);

inl_thr=5;
max_matches = 0;
S = 40;%log(1-0.9)/log(1-(1/size(matching_pointss, 1))^3)
indices = [];
while (S>0 && k >=3)
    random_3 = randperm(k,3);
    rand_points = matching_pointss(random_3,:);
    S = S-1;
%     k = size(matching_pointss, 1);
%     k = input(sprintf('Enter a value for k between 1 and %d\n',k));
% 
    P = [];
    Pp = [];

    for i = 1:3
        x1 = rand_points(i,2);
        y1 = rand_points(i,3);
        x2 = rand_points(i,4);
        y2 = rand_points(i,5);


        P(size(P,1)+1,:) = [x1 y1 0 0 1 0];
        P(size(P,1)+1,:) = [0 0 x1 y1 0 1];

        Pp(size(Pp,1)+1,:) = x2;
        Pp(size(Pp,1)+1,:) = y2;


    end
    
    %compute affine transformation for 3 random points
    penny = P'*inv(P*P');
    affine = penny*Pp;
    
%     penny = (P'*P)'*inv((P'*P)*(P'*P)');
%     affine = penny*P'*Pp;
%     
    O = [];
    Op = [];
    for i = 1:size(matching_pointss, 1);
        x1 = matching_pointss(i,2);
        y1 = matching_pointss(i,3);
        x2 = matching_pointss(i,4);
        y2 = matching_pointss(i,5);
        
        O(size(O,1)+1,:) = [x1 y1 0 0 1 0];
        O(size(O,1)+1,:) = [0 0 x1 y1 0 1];
        
        Op(size(Op,1)+1,:) = x2;
        Op(size(Op,1)+1,:) = y2;
    end
    
    transform = O*affine;
    tformxy = [transform(1:2:length(transform)) transform(2:2:length(transform))];
    Opxy = [Op(1:2:length(Op)) Op(2:2:length(Op))];
    diff = abs(Opxy - tformxy);
    diff = diff(:,1) + diff(:,2);
%     diff = abs(Op - transform);
%     
    close = find(diff<=inl_thr);
%     yr = close(2:2:length(close));
%     xr = close(1:2:length(close));
    
    if max_matches < size(close, 1);
        max_matches = size(close,1);
        good_affine = affine;
        indices = close;
    end
    
   
end

if  max_matches <=3 
    good_points = [];
    good_affine = [];
elseif ~isempty(indices)
    good_points = matching_pointss(indices,:);
end

end 

