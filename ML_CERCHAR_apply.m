clear all; close all; clc
% Estimate CAI value from image data for Cerchar test
% Qi Zhao @ Glaser lab, UC Berkeley, 2019

%% loading data
load('CERCHAR_CNN.mat');
% choose folder
posttestfolder = uigetdir('.\');

imgnames = dir([posttestfolder '\*.jpg']);

for i = 1:length(imgnames)
    imgRaw = imread([posttestfolder '\' imgnames(i).name]);
    I = rgb2gray(imgRaw);
    J = imresize(I, 0.1);
    J = J(5:115,10:150);
    img(1:sz1,1:sz2,1,i) = J;
end

% apply ML model
YPredicted = predict(net,img);

%% saving

figure(1)
set(gcf,'Position',[100 100 800 900])
for i = 1:length(imgnames)
    subplot(5,3,i)
    imshow(img(:,:,:,i),[])
    text(5, 5,imgnames(i).name,'Interpreter','none');
    text(5, 20,['Predict: ' num2str(YPredicted(i),'%.4f')]);
    drawnow
end
avgCAI = mean(YPredicted)*10; % in Units of 0.1 mm
if avgCAI <= 0.5 % HRC = 55
    txt = ['                              Average CAI = ' num2str(avgCAI,'%.2f') ' (Very low abrasiveness)'];
elseif avgCAI >= 0.5 && avgCAI <= 1
    txt = ['                              Average CAI = ' num2str(avgCAI,'%.2f') ' (Low abrasiveness)'];
elseif avgCAI >= 1 && avgCAI <= 2
    txt = ['                              Average CAI = ' num2str(avgCAI,'%.2f') ' (Medium abrasiveness)'];
elseif avgCAI >= 2 && avgCAI <= 4
    txt = ['                              Average CAI = ' num2str(avgCAI,'%.2f') ' (High abrasiveness)'];
elseif avgCAI >= 4 && avgCAI <= 6
    txt = ['                              Average CAI = ' num2str(avgCAI,'%.2f') ' (Extreme abrasiveness)'];
elseif avgCAI >= 6
    txt = ['                              Average CAI = ' num2str(avgCAI,'%.2f') ' (Quartzitic)'];
end
currentFigure = gcf;
title(currentFigure.Children(end), txt);

print(figure(1),'-djpeg','-r300',[posttestfolder 'CNN_Results.jpg'])

