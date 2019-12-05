% Image analysis for Cerchar test
% Application: estimate d and CAI value from image data for Cerchar test
% Hard-coded steps: (1) find the tip (2) fitting (3) estimation
% Input: (through prompt) folder for post-test images
% Output: d, CAI, and print image
%    Solid line - boundary of the tip
%    Dotted line - boundary used for fitting
% Qi Zhao @ Glaser lab, UC Berkeley, 2019

clear all;close all;clc
%% TODO: toggle auto or manual

rez = 0.001; % image resolution [mm/pixel]

posttestfolder = uigetdir('.\');
imgnames = dir([posttestfolder '\*.jpg']);
dnscale = 0.2;
upscale = round(1/dnscale);

figure(1)
set(gcf,'Position',[100 100 1600 900])
for i = 1:length(imgnames)
    imgRaw = imread([posttestfolder '\' imgnames(i).name]);
    
    I = rgb2gray(imgRaw);% convert to grayscale
    img1 = imresize(I, dnscale); % reduce to small size and find the tip
    img1 = imbinarize(img1); % convert to BW images
    
%     % find top tip
%     [n,m] = size(img1);   
%     for ii = 1:n
%         Nnz = find(img1(ii,:) == 0);
%         if ~isempty(Nnz)
%             tipCol = round(mean(Nnz));
%             tipRow = ii;  % "height" of the tip
%             break
%         end
%     end

    % find all boundary points
    img1 = bwareafilt(~img1, 1);
    boundary = bwboundaries(img1);
    boundary = boundary{1,1};
    boundary(boundary(:,2)==max(boundary(:,2)),:) = [];
    boundary(boundary(:,2)==min(boundary(:,2)),:) = [];
    boundary(boundary(:,1)==max(boundary(:,1)),:) = [];
    
    lth = length(boundary);
    tipCol = round((min(boundary(:,2))+max(boundary(:,2)))/2);
    tipRow = boundary(round(mean(find(boundary(:,2)==tipCol))),1);
    
    n = find(boundary(:,1)==tipRow+round(upscale/2)); % empirically chosen upscale/2 to cut the tip
    X1 = boundary(round(0.2*lth):n(1),2);
    Y1 = boundary(round(0.2*lth):n(1),1);
    X2 = boundary(n(end):round(lth*0.8),2);
    Y2 = boundary(n(end):round(lth*0.8),1);

%     X1 = boundary(round(0.1*lth):round(lth*0.4),2);
%     Y1 = boundary(round(0.1*lth):round(lth*0.4),1);
%     X2 = boundary(round(0.6*lth):round(lth*0.9),2);
%     Y2 = boundary(round(0.6*lth):round(lth*0.9),1); 

    % for line y=m*x+b, where m = +-1, the intercept is b_fit = mean(y-m*x);
    interLeft  = round(mean(Y1+X1));
    interRight = round(mean(Y2-X2));

    YY1fit = -boundary(:,2)+interLeft;
    YY2fit =  boundary(:,2)+interRight;
    leftd   =  boundary(round(mean(find(YY1fit==tipRow))),2);
    rightd =  boundary(round(mean(find(YY2fit==tipRow))),2);

    d(i) = (rightd - leftd)*rez;

    subplot(3,5,i)
    imshow(imgRaw,[])
    text(20, 50,imgnames(i).name,'Interpreter','none');
    text(20, 200,['d = ' num2str(d(i),'%.4f') ' mm']);
    hold on
    axis on
    plot(boundary(:,2)*upscale,(-boundary(:,2)+interLeft)*upscale,'b:','LineWidth',2)
    plot(boundary(:,2)*upscale,(boundary(:,2)+interRight)*upscale,'r:','LineWidth',2)
    
    plot(X1*upscale,Y1*upscale,'b-','LineWidth',2)
    plot(X2*upscale,Y2*upscale,'r-','LineWidth',2)
    
    % plot(boundary(:,2)*10,ones(length(boundary(:,2)))*tipRow*10,'r--','LineWidth',1)
    plot(tipCol*upscale,tipRow*upscale,'rs')
    plot([leftd,rightd]*upscale,[tipRow,tipRow]*upscale,'LineWidth',2)
    
    drawnow
end

avgCAI = mean(d)*10; % in Units of 0.1 mm
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
subplot(3,5,3)
title(txt,'FontSize',12)

print(figure(1),'-djpeg','-r300',[posttestfolder 'Fit_Results.jpg'])





