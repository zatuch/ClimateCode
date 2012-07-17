function [index, c] = buildIndexOLR(indexNum, startMonth, endMonth)

    olr = ncread('/project/expeditions/lem/data/olr.mon.mean.nc', 'olr');
    time = ncread('/project/expeditions/lem/data/olr.mon.mean.nc', 'time');
    lat = ncread('/project/expeditions/lem/data/olr.mon.mean.nc', 'lat');
    lon = ncread('/project/expeditions/lem/data/olr.mon.mean.nc', 'lon');
    if matlabpool('size') == 0
        matlabpool open
    end
    olr = permute(olr, [2, 1, 3]);
    addpath('/project/expeditions/lem/ClimateCode/Matt/');
    addpath('/project/expeditions/lem/ClimateCode/sst_project/');
    
    dates = zeros(size(olr, 3), 4);
    parfor i = 1:size(dates, 1);
        dates(i, :) = hoursToDate(time(i), 1,  1, 1);
    end
    
    olr = olr(:, :, dates(:, 4) >= 1979);
    dates = dates(dates(:, 4) >= 1979, :);
    lastYear = find(dates(:, 4) == 2010);
    olr = olr(:, :, 1:lastYear(end));
    dates = dates(1:lastYear(end), :);
    
    for i = 1:12
        currentMonth = olr(:, :, dates(:, 3) == i);
        olr(:, :, dates(:, 3) == i) = (currentMonth - repmat(nanmean(currentMonth, 3), [1, 1, size(currentMonth, 3)]))...
            ./ repmat(nanstd(currentMonth, 0, 3), [1, 1, size(currentMonth, 3)]);
    end
    
    startYear = find(dates(:, 4) == 1979);
    count = 1;
    annualOLR = zeros(size(olr, 1), size(olr, 2), size(olr, 3)/12);
    for i = startYear(1):12:size(olr, 3)
        annualOLR(:, :, count) = nanmean(olr(:, :, i+(startMonth-1):i+(endMonth-1)), 3);
        count = count+1;
    end
    box_north = 35;
    box_south = -35;
    
    box_west = 140;
    box_east = 270;
    box_row =5;
    box_col = 10;

    index = buildIndexHelper(annualOLR, box_north, box_south, box_west, box_east, lat, lon, box_row, box_col, indexNum);
    
    load /project/expeditions/lem/ClimateCode/Matt/matFiles/asoHurricaneStats.mat;
        
    c(1) = corr(index, aso_tcs);
    c(2) = corr(index, aso_major_hurricanes);
    c(3) = corr(index, aso_ntc);
    c(4) = corr(index, aso_pdi);
    c(5) = corr(index, aso_ace);
end


function index = buildIndexHelper(sst_a,box_north,box_south,box_west,box_east,lat,lon,box_row,box_col, indexNum)

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

if northRow >= southRow || westCol >= eastCol
    eastCol
    westCol
    northRow
    southRow
    error('latitude or longitude error');
end

annual_pacific = double(sst_a(northRow:southRow,westCol:eastCol,:));

for t=1:size(annual_pacific,3)
   ss(:,:,t) = sub_sum(annual_pacific(:,:,t),box_row,box_col); 
end

%mean_box_sst_pacific = ss(round(box_row/2)+1:end-round(box_row/2),round(box_col/2)+1:end-round(box_col/2),:)./(box_row*box_col);%sub_sum pads the matrix so we can ignore the outer rows/columns
mean_box_sst_pacific = ss(box_row:end-box_row+1, box_col:end-box_col+1, :) ./ (box_row * box_col);
for t = 1:size(mean_box_sst_pacific,3)
   current = mean_box_sst_pacific(:,:,t);
   [values(t) loc(t)] = max(current(:));
   [I(t),J(t)] = ind2sub(size(current),loc(t));
   [minValues(t), minLoc(t)] = min(current(:));
   [minI(t), minJ(t)] = ind2sub(size(current), minLoc(t));
   
end

lon_region = lon(lon >= box_west & lon <= box_east);
lat_region = lat(lat >= box_south & lat <= box_north);
switch indexNum
    case 1
        index = lon_region(J);
    case 2
        index = lon_region(minJ);
    case 3
        index = lat_region(I);
    case 4
        index = lat_region(minI);
end

end
