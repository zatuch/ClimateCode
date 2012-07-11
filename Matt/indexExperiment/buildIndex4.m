
function [index, cc, ccIndex, nYears, pYears] = buildIndex4(indexNum)
load /project/expeditions/lem/ClimateCode/Matt/matFiles/sstAnomalies.mat;
load /project/expeditions/lem/ClimateCode/Matt/matFiles/olrAnomalies.mat;
load /project/expeditions/lem/ClimateCode/Matt/matFiles/pressureAnomalies.mat;

year = 1;
for i = 1:12:(2010-1979+1)*12
   sstMean(:, :, year) = nanmean(sst(:, :, i+3 - 1:i+10 - 1), 3); 
   pMean(:, :,year) = nanmean(pressure(:, :, i+3-1:i+10-1), 3);
   olrMean(:, :, year) = nanmean(olr(:, :, i+3-1:i+10-1), 3);
   year = year+1;
end

box_north = sstLat(minIndex(sstLat, 35));
box_south = sstLat(minIndex(sstLat, -5));
box_west = sstLon(minIndex(sstLon, 140));
box_east = sstLon(minIndex(sstLon, 270));
box_row = 5;
box_col = 18;
[sstI, sstJ, sstValues] = buildIndexGeneric(sstMean, box_north, box_south, box_west, box_east, sstLat, sstLon, box_row, box_col, true);

sstLonRegion = sstLon(sstLon >= box_west & sstLon <= box_east);
sstLatRegion = sstLat(sstLat >=  box_south & sstLat <= box_north);


box_north = olrLat(minIndex(olrLat, 35));
box_south = olrLat(minIndex(olrLat, -5));
box_west = olrLon(minIndex(olrLon, 140));
box_east = olrLon(minIndex(olrLon, 270));

[olrI, olrJ, olrValues] = buildIndexGeneric(olrMean, box_north, box_south, box_west, box_east, olrLat, olrLon, box_row, box_col, false);
olrLonRegion = olrLon(olrLon >= box_west & olrLon <= box_east);
olrLatRegion = olrLat(olrLat >= box_south & olrLat <= box_north);

box_north = pressureLat(minIndex(pressureLat, 35));
box_south = pressureLat(minIndex(pressureLat, -5));
box_west = pressureLon(minIndex(pressureLon, 140));
box_east = pressureLon(minIndex(pressureLon, 270));
pressureLonRegion = pressureLon(pressureLon >= box_west & pressureLon <= box_east);
pressureLatRegion = pressureLat(pressureLat >= box_south & pressureLat <= box_north);

[pressureI, pressureJ, pressureValues] = buildIndexGeneric(pMean, box_north, box_south, box_west, box_east, pressureLat, pressureLon, box_row, box_col, false);

midpoint = box_west + ((box_east - box_west) / 2);

switch indexNum
    case 1
        index = sstLonRegion(sstJ.max); %-2.5984 correlation
    case 2
        indexMatrix = [sstLonRegion(sstJ.max), olrLonRegion(olrJ.min), pressureLonRegion(pressureJ.max)];
        index = zeros(length(sstJ.max), 1);
        for i = 1:length(sstJ.max)
            [~, ind] = max(abs(indexMatrix(i, :) - midpoint)); %correlation 1.5938
            index(i) = indexMatrix(ind);
        end
    case 3
        indexMatrix = [sstLonRegion(sstJ.max), olrLonRegion(olrJ.min), pressureLonRegion(pressureJ.max)];
        index = zeros(length(sstJ.max), 1);
        for i = 1:length(sstJ.max)
            [~, ind] = min(abs(indexMatrix(i, :) - midpoint)); %correlation -1.0646
            index(i) = indexMatrix(ind);
        end
    case 4
        indexMatrix = [sstLonRegion(sstJ.max), olrLonRegion(olrJ.min), pressureLonRegion(pressureJ.max)];
        index = mean(indexMatrix, 2); %correlation -2.439
    case 5
        index = sstLonRegion(sstJ.max) + olrLonRegion(olrJ.min) + pressureLatRegion(pressureI.max);%correlation -0.935
    case 6
        index = sqrt(sstLonRegion(sstJ.max) + olrLonRegion(olrJ.min) + pressureLatRegion(pressureI.max)); %correlation -.957
    case 7
        indexMatrix = [sstLonRegion(sstJ.max), olrLonRegion(olrJ.min), pressureLonRegion(pressureJ.max)];
        index = std(indexMatrix, 0, 2);  %correlation .9616
    case 8
        indexMatrix = [sstLonRegion(sstJ.max), olrLonRegion(olrJ.min), pressureLonRegion(pressureJ.max)];
        index = range(indexMatrix, 2); %correlation 1.04424
    case 9
        index = sstLonRegion(sstJ.max) - pressureLonRegion(pressureJ.max); %correlation .0476
    case 10
        index = sstLonRegion(sstJ.max) + pressureLatRegion(pressureI.max) .* pressureValues.min'; %correlation -3.01
    case 11
        index = pressureLatRegion(pressureI.max) .* pressureValues.min'; % correlation -2.620
    case 12
        index = sstLonRegion(sstJ.max) + pressureLatRegion(pressureI.max) .* pressureValues.min' .* olrLonRegion(olrJ.max); %correlation -2.4309
    case 13
        index = pressureLatRegion(pressureI.max) .* (pressureValues.min'./ norm(pressureValues.min));%correlation -2.6195
    case 14
        %weightIndex function is defined below.
        index = weightIndex(sstLonRegion(sstJ.max), pressureLatRegion(pressureI.max), pressureValues.min); %correlation -3.22
    case 15
        index = max(sstLonRegion(sstJ.max), olrLonRegion(olrJ.max)) + pressureLatRegion(pressureI.max) .* pressureValues.min'; %correlation -2.6494
    case 16
        index = min(sstLonRegion(sstJ.max), olrLonRegion(olrJ.max)) + pressureLatRegion(pressureI.max) .* pressureValues.min'; %correlation -2.0078
    case 17
        index = (sstLonRegion(sstJ.max) + olrLonRegion(olrJ.max) ./ 2) + pressureLatRegion(pressureI.max) .* pressureValues.min';% correlation -2.6691
    case 18
        index = sstLonRegion(sstJ.max) - sstLonRegion(sstJ.min); %correlation -3.0654
    case 19
        index = (sstLonRegion(sstJ.max) - sstLonRegion(sstJ.min)) + pressureLatRegion(pressureI.max) .* pressureValues.min';
    case 20
        index = weightIndex(sstLonRegion(sstJ.max) - sstLonRegion(sstJ.min), pressureLatRegion(pressureI.max), pressureValues.min); %correlation -3.5534
    case 21
        index = weightIndex(.5*(sstLonRegion(sstJ.max) - sstLonRegion(sstJ.min)), pressureLatRegion(pressureI.max), pressureValues.min); %correlation -3.6935
    case 22
        index = pressureLatRegion(pressureI.max) - pressureLatRegion(pressureI.min); %correlation 2.5159
    case 23
        index = weightIndex(.5*(sstLonRegion(sstJ.max) - .8*sstLonRegion(sstJ.min)), pressureLatRegion(pressureI.max), pressureValues.min);
    case 24
        index = pressureLatRegion(pressureI.max); %correlation 2.7049
    case 25
        index = olrLatRegion(olrI.max);
end

load /project/expeditions/haasken/data/stormData/atlanticStorms/HurDat_1851_2010.mat
load /project/expeditions/lem/ClimateCode/Matt/matFiles/condensedHurDat.mat;
year = 1979:2010;
aso_tcs = zeros(size(1979:2010, 2), 1);
aso_major_hurricanes = zeros(size(1979:2010, 2), 1);
aso_ace = zeros(size(1979:2010, 2), 1);
aso_pdi = zeros(size(1979:2010, 2), 1);
aso_ntc = zeros(size(1979:2010, 2), 1);
for i = 1:(2010-1979+1)
    aso_tcs(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=10 ,10));
    aso_major_hurricanes(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,10)>=4&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=10 ,10));
    aso_ace(i) = sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=10,12))/10^5;
    aso_pdi(i)=sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=10,11))/10^7;
    aso_ntc(i) = computeNTC(hurDat, [1950 2000 ], [ year(i) year(i) ], 'countDuplicates', true, 'months', 8:10); 
end
sstIndex = sstLonRegion(sstJ.max);
ccIndex(1) = corr(sstIndex, aso_tcs);
ccIndex(2) = corr(sstIndex, aso_major_hurricanes);
ccIndex(3) = corr(sstIndex, aso_ace);
ccIndex(4) = corr(sstIndex, aso_pdi);
ccIndex(5) = corr(sstIndex, aso_ntc);

cc(1) = corr(index, aso_tcs); 
cc(2) = corr(index, aso_major_hurricanes);
cc(3) = corr(index, aso_ace);
cc(4) = corr(index, aso_pdi);
cc(5) = corr(index, aso_ntc);
%{
plot(index, aso_ntc, 'x');
xlabel('index')
ylabel('aso_ntc');
%}
normalizedIndex = (index - mean(index)) ./ std(index);
nYears = find(normalizedIndex <= -1) + 1979 - 1;
pYears = find(normalizedIndex >= 1) + 1979 - 1;
end

function index = weightIndex(sstLoc, pressureLoc, pressureVals)
normalizedSST = (sstLoc - mean(sstLoc)) ./ std(sstLoc);
normalizedPressure = (pressureLoc - mean(pressureLoc)) ./ std(pressureLoc);
index = zeros(size(sstLoc));
for i = 1:length(sstLoc)
    if normalizedPressure(i) > normalizedSST(i)
        index(i) = sstLoc(i) + pressureLoc(i) * pressureVals(i) / 2;
    else
        index(i) = sstLoc(i) + pressureLoc(i) * pressureVals(i) * 2;
    end
        
end


end


function [I, J, values] = buildIndexGeneric(data,box_north,box_south,box_west,box_east,lat,lon,box_row,box_col, upsideDown)

addpath('/project/expeditions/lem/ClimateCode/sst_project/');

if ismember(box_north, lat)
   [~, northRow] = ismember(box_north, lat);
   [~, southRow] = ismember(box_south, lat);
else
    error('Bad lat input!');
end
if ismember(box_east, lon)
   [~, eastCol] = ismember(box_east, lon);
   [~, westCol] = ismember(box_west, lon);
else
    error('Bad lat input!');
end
if upsideDown == true
    annual_pacific = double(data(southRow:northRow,westCol:eastCol,:));
else
    annual_pacific = double(data(northRow:southRow, westCol:eastCol, :));
end



for t=1:size(annual_pacific,3)
   ss(:,:,t) = sub_sum(annual_pacific(:,:,t),box_row,box_col); 
end

mean_box_sst_pacific = ss(round(box_row/2)+1:end-round(box_row/2),round(box_col/2)+1:end-round(box_col/2),:)./(box_row*box_col);%sub_sum pads the matrix so we can ignore the outer rows/columns

for t = 1:size(mean_box_sst_pacific,3)
   current = mean_box_sst_pacific(:,:,t);
   [minValues(t) minLoc(t)] = min(current(:));
   [minI(t),minJ(t)] = ind2sub(size(current),minLoc(t));
   [maxValues(t), maxLoc(t)] = max(current(:));
   [maxI(t), maxJ(t)] = ind2sub(size(current), maxLoc(t));
end
I = struct('min', minI, 'max', maxI);
J = struct('min', minJ, 'max', maxJ);
values = struct('min', minValues, 'max', maxValues);



end


function i = minIndex(A, x)
[~, i] = min(abs(A -x));
end