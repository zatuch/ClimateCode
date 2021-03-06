%forecast June-Oct S-ENSO
load('ersstv3_1854_2012_raw.mat')
[sstA sstA_dates] = getMonthlyAnomalies(sst,sstDates,1948,2010);
annualSST = getAnnualSSTAnomalies(6,10, 1979, 2010, sstA, sstA_dates);
%build June-Oct index
[index_jun_oct, maxI__jun_oct, maxJ__jun_oct, minI__jun_oct, minJ__jun_oct, maxValues__jun_oct, minValues__jun_oct] = buildSSTLon(annualSST, sstLat, sstLon);
%monthly S-ENSO
[index, maxI, maxJ, minI, minJ, maxValues, minValues] = buildSSTLon(sstA, sstLat, sstLon);

%specific range of S-ENSO
count = 1;
for i=1:5
    for j=i:5
        sstA_year = getAnnualSSTAnomalies(i,j,1979,2010,sstA,sstA_dates);
        [ii{count}, maxI, maxJ, minI, minJ] = buildSSTLon(sstA_year, sstLat, sstLon);
        count = count+1;
    end
end

for i=1:length(ii)
   predictors(:,i) = ii{i}'; 
end

data = [predictors index_jun_oct];
%norm_data = (data - min(min(data))) ./ (max(max(data)) - min(min(data)));

%[cc, ypred, actuals] = kfoldCrossValidate(norm_data(:,1:end-1), norm_data(:,end), 4);

[ypred, model, cc, mse, Bmat, intercepts] = lassoCrossVal(data(:,1:end-1), data(:,end), 4);



%get the predictors
count =1;
for i=1:12:384
   predictors(count,:) = index(i:i+5); 
   count = count +1;
end

data = ([predictors index_jun_oct]);
%normalize
norm_data = (data - min(min(data))) ./ (max(max(data)) - min(min(data)));

x = [norm_data(:,1:end-1)];
yy = norm_data(:,end);

[cc, ypred, actuals] = kfoldCrossValidate(x, yy, 4);



%xx = diff(dd,1,2);
%[y,actual,cc] = crossValidate(xx(:,1:5),xx(:,6),2);

% for i =1:32
%     figure
%    bar(x(i,:))
%    hold on
%    bar(7,yy(i),'r')
%    pause
% end