function matching_points = get_matches(I, Ib, threshold)


I = single(I) ;

Ib = single(Ib) ;

[f,d] = vl_sift(I) ;

[fb, db] = vl_sift(Ib) ;

d = double(d);
db = double(db);
euc= pdist2(d', db', 'euclidean');
sorted = sort(euc, 2);
ratios=sorted(:,1)./sorted(:,2);

matches = zeros(size(find(ratios<=threshold),1), 3);
for i = 1:size(euc,1)
    if ratios(i) < threshold
        matches(i,1) = ratios(i);
        matches(i,2)= i;
        matches(i,3)=find(euc(i,:)==sorted(i,1));
    end
end

matches( ~any(matches,2), : ) = [];
matching_points = zeros(size(matches,1), 5);

for i = 1:size(matches,1)
    matching_points(i,1) = matches(i,1);
    matching_points(i,2:3) = [f(1,matches(i,2)) f(2,matches(i,2))];
    matching_points(i,4:5) = [fb(1,matches(i,3)) fb(2,matches(i,3))];
    
end

end