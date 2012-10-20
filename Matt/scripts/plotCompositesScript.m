%-----------------------Plot Hurricane Counts-----------------------------
clear
if ~exist('vars', 'var')
    vars = load('/project/expeditions/ClimateCodeMatFiles/compositeVariables.mat');
end
addpath('/project/expeditions/lem/ClimateCode/Matt/');
addpath('/project/expeditions/lem/ClimateCode/Matt/indexExperiment/');

load /project/expeditions/ClimateCodeMatFiles/asoHurricaneStats.mat
[nYears, pYears] = getPosNegYearsFromVector(aso_tcs, 1, true, 1979);

plotIndividualComposites(vars, nYears, pYears, 'hurricaneCounts', 'AugOct');
plotIndividualComposites(vars, nYears, pYears, 'hurricaneCounts', 'MarOct');

%% -----------Aug-Oct-Atlantic EOF PC 1------------------------------------

if ~exist('vars', 'var')
    vars = load('/project/expeditions/ClimateCodeMatFiles/compositeVariables.mat');
end

load /project/expeditions/ClimateCodeMatFiles/augOctAtlanticBasinEOFPCs.mat
[nYears, pYears] = getPosNegYearsFromVector(PCs(:, 1), 1, true, 1979);
plotIndividualComposites(vars, nYears, pYears, 'AtlanticBasinEOF1stPC', 'AugOct');

%% ---------------Aug-Oct Pacific EOF PC1----------------------------------
if ~exist('vars', 'var')
    vars = load('/project/expeditions/ClimateCodeMatFiles/compositeVariables.mat');
end

load /project/expeditions/ClimateCodeMatFiles/augOctPacificBasinEOFPCs.mat;
[nYears, pYears] = getPosNegYearsFromVector(PCs(:, 1), 1, true, 1979);
plotIndividualComposites(vars, nYears, pYears, 'PacificBasinEOF1stPC', 'AugOct');

%% ---------------Aug-Oct Joint Basins PC 1-------------------------------
if ~exist('vars', 'var')
    vars = load('/project/expeditions/ClimateCodeMatFiles/compositeVariables.mat');
end
load /project/expeditions/ClimateCodeMatFiles/augOctJointBasinsEOFPCs.mat;
[nYears, pYears] = getPosNegYearsFromVector(PCs(:, 1), 1, true, 1979);
plotIndividualComposites(vars, nYears, pYears, 'JointBasinsEOF1stPC', 'AugOct');

%% ----------------Mar-Oct Atlantic EOF PC1-------------------------------
if ~exist('vars', 'var')
    vars = load('/project/expeditions/ClimateCodeMatFiles/compositeVariables.mat');
end
load /project/expeditions/ClimateCodeMatFiles/marOctAtlanticBasinEOFPCs.mat;
[nYears, pYears] = getPosNegYearsFromVector(PCs(:, 1), 1, true, 1979);
plotIndividualComposites(vars, nYears, pYears, 'AtlanticBasinEOF1stPC', 'MarOct');

%% --------------Mar-Oct PacificEOF PC1-----------------------------------
if ~exist('vars', 'var')
    vars = load('/project/expeditions/ClimateCodeMatFiles/compositeVariables.mat');
end
load /project/expeditions/ClimateCodeMatFiles/marOctPacificBasinEOFPCs.mat
[nYears, pYears] = getPosNegYearsFromVector(PCs(:, 1), 1, true, 1979);
plotIndividualComposites(vars, nYears, pYears, 'PacificBasinEOF1stPC', 'MarOct');

%% ----------------Mar-Oct Joint Basins PC 1------------------------------
if ~exist('vars', 'var')
    vars = load('/project/expeditions/ClimateCodeMatFiles/compositeVariables.mat');
end
load /project/expeditions/ClimateCodeMatFiles/marOctJointBasinsEOFPCs.mat
[nYears, pYears] = getPosNegYearsFromVector(PCs(:, 1), 1, true, 1979);
plotIndividualComposites(vars, nYears, pYears, 'JointBasinsEOF1stPC', 'MarOct');



