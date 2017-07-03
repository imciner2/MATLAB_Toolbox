%% Generate a test image
x = -1:0.1:1;
figure;
h = plot(x, zeros(1, length(x)), 'b');
hold on;
h(2) = plot(x, x, 'r');
h(3) = plot(x, x.^2, 'g');
h(4) = plot(x, x.^3, 'k');
title('Test Image');
xlabel('Independant');
ylabel('Dependant');

legend(h, 'Constant', 'Linear', 'Quadratic', 'Cubic');

%% Test the import
data = ImportDataFromFigure('TestImage.fig');

figure;
hold on;
for (i=1:1:data.numSeries)
    h(i) = plot(data.(['series', num2str(i)]).x, data.(['series', num2str(i)]).y);
    leg{i} = data.(['series', num2str(i)]).name;
end

xlabel(data.xLabel);
ylabel(data.yLabel);
legend(h, leg);