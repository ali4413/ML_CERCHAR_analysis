clear all; close all; clc
% Use CNN image analysis for Cerchar test
% Application: estimate d and CAI value from image data for Cerchar test
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
    J = double(imbinarize(J)); % convert to BW images
    img(1:sz1,1:sz2,1,i) = J;
    imgR{i} = imgRaw;
end
% apply ML model
YPredicted = predict(net,img);
YPredicted(YPredicted<0) = 0;

%% saving
figure(1)
set(gcf,'Position',[100 100 800 900])
for i = 1:length(imgnames)
    subplot(5,3,i)
    imshow(imgR{i},[])
    text(10, 50,imgnames(i).name,'Interpreter','none');
    text(10, 200,['d = ' num2str(YPredicted(i),'%.4f') ' mm']);
    drawnow
end
avgCAI = mean(YPredicted)*10; % in Units of 0.1 mm
avgCAI = round(avgCAI*100)/100;

if avgCAI <= 0.5 % HRC = 55
    txt = ['Average CAI = ' num2str(avgCAI,'%.2f') ' (Very low abrasiveness)'];
elseif avgCAI >= 0.5 && avgCAI <= 1
    txt = ['Average CAI = ' num2str(avgCAI,'%.2f') ' (Low abrasiveness)'];
elseif avgCAI >= 1 && avgCAI <= 2
    txt = ['Average CAI = ' num2str(avgCAI,'%.2f') ' (Medium abrasiveness)'];
elseif avgCAI >= 2 && avgCAI <= 4
    txt = ['Average CAI = ' num2str(avgCAI,'%.2f') ' (High abrasiveness)'];
elseif avgCAI >= 4 && avgCAI <= 6
    txt = ['Average CAI = ' num2str(avgCAI,'%.2f') ' (Extreme abrasiveness)'];
elseif avgCAI >= 6
    txt = ['Average CAI = ' num2str(avgCAI,'%.2f') ' (Quartzitic)'];
end
subplot(5,3,2)
title(txt,'FontSize',12)

print(figure(1),'-djpeg','-r300',[posttestfolder 'CNN_Results.jpg'])
