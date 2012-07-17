function [cc] = buildSSTIndex(sstType, anomalyNum, startMonth, endMonth)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
addpath('/project/expeditions/lem/ClimateCode/sst_project/');
addpath('/project/expeditions/lem/ClimateCode/Matt/');
switch sstType
    case 1
        sst = ncread('/project/expeditions/lem/data/sst_slp_eraInterim_1979-2010.nc', 'var34');
        sst = permute(sst, [2, 1, 3]);
        sstLat = ncread('/project/expeditions/lem/data/sst_slp_eraInterim_1979-2010.nc', 'lat');
        sstLon = ncread('/project/expeditions/lem/data/sst_slp_eraInterim_1979-2010.nc', 'lon');
        time = ncread('/project/expeditions/lem/data/sst_slp_eraInterim_1979-2010.nc', 'time');
        sstDates = zeros(length(time), 4);
        for i = 1:length(sstDates)
            sstDates(i, :) = hoursToDate(time(i), 1,1, 1979);
        end
        switch anomalyNum
            case 1
                for i = 1:12
                    current = sst(:, :, sstDates(:, 3) == i);
                    sst(:, :, sstDates(:, 3) == i) = current ./ repmat(std(current, 0, 3), [1, 1, size(current, 3)]);
                end
            case 2
                for i = 1:12
                    current = sst(:, :, sstDates(:, 3) == i);
                    sst(:, :, sstDates(:, 3) == i) = current - repmat(mean(current, 3), [1, 1, size(current, 3)]);
                end
            case 3
                for i = 1:12
                    current = sst(:, :, sstDates(:, 3) == i);
                    sst(:, :, sstDates(:, 3) == i) = (current - ...
                        repmat(mean(current, 3), [1, 1, size(current, 3)])) ./ ...
                        repmat(std(current, 0, 3), [1, 1, size(current, 3)]);
                end
        end
        
    case 2
        load /project/expeditions/lem/ClimateCode/Matt/matFiles/sstAnomalies.mat;
end


sstMean = zeros(size(sst, 1), size(sst, 2), size(sst, 3)/12);
count = 1;
for i = 1:12:size(sst, 3)
    sstMean(:, :, count) = nanmean(sst(:, :, i+startMonth-1:i+endMonth-1), 3);
    count = count+1;
end

box_north = sstLat(minIndex(sstLat, 35));
box_south = sstLat(minIndex(sstLat, -5));
box_west = sstLon(minIndex(sstLon, 140));
box_east = sstLon(minIndex(sstLon, 270));

box_row = 5;
box_col = 18;
switch sstType
    case 1
        index = buildIndexHelper(sstMean, box_north, box_south, box_west, box_east, sstLat, sstLon, box_row, box_col, false);
    case 2
        index = buildIndexHelper(sstMean, box_north, box_south, box_west, box_east, sstLat, sstLon, box_row, box_col, true);
   
end
baseYear = 1979;
stdDev = std(index);
normalizedIndex = (index - mean(index)) ./ stdDev;

posYears = find(normalizedIndex >= 1) + baseYear - 1;
negYears = find(normalizedIndex <= -1) + baseYear - 1;

load /project/expeditions/lem/ClimateCode/Matt/matFiles/asoHurricaneStats.mat;

cc(1) = corr(index, aso_tcs);
cc(2) = corr(index, aso_major_hurricanes);
cc(3) = corr(index, aso_ace);
cc(4) = corr(index, aso_pdi);
cc(5) = corr(index, aso_ntc);


end

function index = minIndex(A, x)
    [~, index] = min(abs(A - x));
end

function index = buildIndexHelper(sst_a,box_north,box_south,box_west,box_east,lat,lon,box_row,box_col, upsideDown)

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
if upsideDown == false
    annual_pacific = double(sst_a(northRow:southRow,westCol:eastCol,:));
else
    annual_pacific = double(sst_a(southRow:northRow,westCol:eastCol,:));
end

for t=1:size(annual_pacific,3)
   ss(:,:,t) = sub_sum(annual_pacific(:,:,t),box_row,box_col); 
end
 
mean_box_sst_pacific = ss(box_row:end-box_row+1,box_col:end-box_col+1,:)./(box_row*box_col);%sub_sum pads the matrix so we can ignore the outer rows/columns

for t = 1:size(mean_box_sst_pacific,3)
   current = mean_box_sst_pacific(:,:,t);
   [values(t) loc(t)] = max(current(:));
   [I(t),J(t)] = ind2sub(size(current),loc(t));
   [minValues(t), minLoc(t)] = min(current(:));
   [minI(t), minJ(t)] = ind2sub(size(current), minLoc(t));
end


lon_region = lon(lon >= box_west & lon <= box_east);
lat_region = lat(lat >= box_south & lat <= box_north);
index = lon_region(J);

end