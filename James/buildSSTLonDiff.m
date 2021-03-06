%-------------------------------------------------------------------------
%This function builds an index that is the distance between the warmest
%anomaly box, and the coolest anomaly box. 
%
%----------------------------Input----------------------------------------
%-->sst_a - sea surface temperature anomalies that have been averaged over
%a particular month range (see getAnnualSSTAnomalies function). 
%-->lat - latitude values that correspond to sst_a
%-->lon - longitued values that correspond to sst_a
%
%--------------------------Output-----------------------------------------
%-->index - an index based on the distance between the warmest and coolest
%sst anomaly boxes.
%
%----------------------------Usage----------------------------------------
%   index = buildSSTLonDiff(getAnnualSSTAnomalies(3, 10, 1979, 2010)
%
%-->This will return the sstLonDiff index for the March-October month range
%with years 1979-2010


function [index, maxI, maxJ, minI, minJ] = buildSSTLonDiff(sst_a, lat, lon)
%-------------------------Adjustable Constants----------------------------
boxNorth = 36;
boxSouth = -6;
boxWest = 120;
boxEast = 260;
%must adjust to grid size
boxRow = 10;
boxCol = 40;
%-------------------------------------------------------------------------

addpath('/project/expeditions/lem/ClimateCode/sst_project/');

northRow = closestIndex(lat, boxNorth);
southRow = closestIndex(lat, boxSouth);
eastCol = closestIndex(lon, boxEast);
westCol = closestIndex(lon, boxWest);

annual_pacific = double(sst_a(northRow:southRow,westCol:eastCol,:));

for t=1:size(annual_pacific,3)
   ss(:,:,t) = sub_sum(annual_pacific(:,:,t),boxRow,boxCol); 
end

mean_box_sst_pacific = ss(boxRow:end-boxRow+1, boxCol:end-boxCol+1, :) ./ (boxRow * boxCol);

for t = 1:size(mean_box_sst_pacific,3)
   current = mean_box_sst_pacific(:,:,t);
   [maxValues(t) maxLoc(t)] = max(current(:));
   [maxI(t),maxJ(t)] = ind2sub(size(current),maxLoc(t));
   
   [minValues(t), minLoc(t)] = min(current(:));
   [minI(t), minJ(t)] = ind2sub(size(current), minLoc(t));
end

lon_region = lon(lon >= boxWest & lon <= boxEast);

index = lon_region(minJ) - lon_region(maxJ);



end

function [index] = closestIndex(A, x)
    [~,index] = min(abs(A-x));
end