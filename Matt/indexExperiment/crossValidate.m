function [YVals, actual, cc] = crossValidate(indices, target, k, varType, indexType, years)
%Performs cross validation using the multivariate linear regression
%function.
%   Indices should be a matrix where each column is one of the indices that
%   we have created.  Target should be one of the hurricane statstics that
%   we are trying to correlate against

c = cvpartition(length(target), 'kfold', k);
addpath('../') %for fig.m
YVals = [];
actual = [];
if any(isnan(indices))
    cc = 0;
    return
end
parfor i = 1:k
    mask = training(c, i);
    mdl = LinearModel.fit(indices(mask, :), target(mask)); %#ok<PFBNS>
    Y = predict(mdl, indices(~mask, :));
    YVals = [YVals; Y];
    actual = [actual; target(~mask)]; 
end
if nargin > 3
    plotCrossVal(YVals, actual, varType, indexType, years);
end
cc = corr(YVals, actual);
end


function[] = plotCrossVal(yVals, actuals, t, indexType, years)
    fig(figure(1), 'units', 'inches', 'width', 9.5, 'height', 8)
    %bar(years, [yVals, actuals]);
    plot(years, yVals, years, actuals);
    legend('Predictions', 'Actual');
    c = corr(yVals, actuals);
    title(strcat('Cross Validation ', indexType, ' correlation = ', num2str(c), ' (', t, ')'));
    ylabel(t);
    xlabel('Year');
    print(gcf, '-dpdf', '-r400', ['/project/expeditions/lem/ClimateCode/Matt/', ...
        'indexExperiment/results/comboIndex349/' indexType t ...
        'CrossValidationCorrelations.pdf']);
end