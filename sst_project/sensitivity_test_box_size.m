%builds the new pacific index 
%use evince to view pdf's
tic
clear
close all
load('/project/expeditions/haasken/data/stormData/atlanticStorms/condensedHurDat.mat');

load /project/expeditions/haasken/data/stormData/atlanticStorms/HurDat_1851_2010.mat


file_name = '/project/expeditions/jfagh/data/ersstv3/ersstv3_1948_2010_mon_anomalies.nc';
ncid = netcdf.open(file_name,'NC_NOWRITE');
varid_sst = netcdf.inqVarID(ncid,'sst');
sst_1971_2010 =  squeeze(netcdf.getVar(ncid,varid_sst));
sst_1971_2010(sst_1971_2010==-999)=NaN;
sst_1971_2010 = permute(sst_1971_2010,[2 1 3])./100;
sst_1971_2010 = sst_1971_2010(:,:,(23*12)+1:end);
netcdf.close(ncid);

count = 1;
for i =1:12:size(sst_1971_2010,3)
    annual_sst(:, :, count) = nanmean(sst_1971_2010(:,:,i+(4-1):i+(11-1)),3);
    count = count+1;
end


box_north = 36;
box_south = -6;
box_west = 140;
box_east = 270;
box_row =5;

lat=-88:2:88;
lon=0:2:358;

count = 1;
index = cell(26, 1);
for box_col = 5:30
    index{count} = buildIndex(annual_sst, box_north, box_south, box_west, box_east, lat, lon, box_row, box_col);
    index{count} = index{count}(9:end);
    count = count+1;
end
year = 1979:2010;
parfor i=1:length(year)
    %seasonal = 6,7,8,9,10 (June-Oct)
    seasonal_pdi(i)=sum(condensedHurDat(condensedHurDat(:,1)==year(i),11))/10^7;
    seasonal_ace(i) = sum(condensedHurDat(condensedHurDat(:,1)==year(i),12))/10^5;
    seasonal_major_hurricanes(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,10)>=4 ,10));
    seasonal_tcs(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=6&condensedHurDat(:,2)<=10 ,10));
    seasonal_ntc(i) = computeNTC(hurDat, [1950 2000 ], [ year(i) year(i) ], 'countDuplicates', true, 'months', 6:10);
    
    %as = Aug-Sep
    %jaso = July-October
    as_tcs(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=9 ,10));
    aso_tcs(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=10 ,10));
    jaso_tcs(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=7&condensedHurDat(:,2)<=10 ,10));
    jas_tcs(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=7&condensedHurDat(:,2)<=9 ,10));
    
    as_major_hurricanes(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,10)>=4&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=9 ,10));
    aso_major_hurricanes(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,10)>=4&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=10 ,10));
    jaso_major_hurricanes(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,10)>=4&condensedHurDat(:,2)>=7&condensedHurDat(:,2)<=10 ,10));
    jas_major_hurricanes(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,10)>=4&condensedHurDat(:,2)>=7&condensedHurDat(:,2)<=9 ,10));
    
    as_ace(i) = sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=9,12))/10^5;
    aso_ace(i) = sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=10,12))/10^5;
    jaso_ace(i) = sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=7&condensedHurDat(:,2)<=10,12))/10^5;
    jas_ace(i) = sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=7&condensedHurDat(:,2)<=9,12))/10^5;
    
    as_pdi(i)=sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=9,11))/10^7;
    aso_pdi(i)=sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=10,11))/10^7;
    jaso_pdi(i)=sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=7&condensedHurDat(:,2)<=10,11))/10^7;
    jas_pdi(i)=sum(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=7&condensedHurDat(:,2)<=9,11))/10^7;
    
    as_ntc(i) = computeNTC(hurDat, [1950 2000 ], [ year(i) year(i) ], 'countDuplicates', true, 'months', 8:9);
    aso_ntc(i) = computeNTC(hurDat, [1950 2000 ], [ year(i) year(i) ], 'countDuplicates', true, 'months', 8:10);
    jaso_ntc(i) = computeNTC(hurDat, [1950 2000 ], [ year(i) year(i) ], 'countDuplicates', true, 'months', 7:10);
    jas_ntc(i) = computeNTC(hurDat, [1950 2000 ], [ year(i) year(i) ], 'countDuplicates', true, 'months', 7:9);
    
    seasonal_mdr_tcs(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=6&condensedHurDat(:,2)<=10&condensedHurDat(:,6)>=5&condensedHurDat(:,6)<=30&condensedHurDat(:,7)>=-80&condensedHurDat(:,7)<=-15 ,10));
    as_mdr_tcs(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=9&condensedHurDat(:,6)>=5&condensedHurDat(:,6)<=30&condensedHurDat(:,7)>=-80&condensedHurDat(:,7)<=-15 ,10));
    aso_mdr_tcs(i) = length(condensedHurDat(condensedHurDat(:,1)==year(i)&condensedHurDat(:,2)>=8&condensedHurDat(:,2)<=10&condensedHurDat(:,6)>=5&condensedHurDat(:,6)<=30&condensedHurDat(:,7)>=-80&condensedHurDat(:,7)<=-15 ,10));
     
end
for i=1:size(index,1)
    cc11(i) = corr(index{i}', aso_tcs');
    cc12(i) = corr(index{i}', aso_major_hurricanes');
    cc13(i) = corr(index{i}', aso_ace');
    cc14(i) = corr(index{i}', aso_pdi');
    cc15(i) = corr(index{i}', aso_ntc');
    
end
toc