clear all
close all

%script for loading thermal images from one excel file.
%the excel file is the export from the keysight thermal image software
%this script loads the images and find the absolute maximum
%then it creats a profile to compare different parameters

filename = 'JetE.txt';

p = gcp('nocreate'); % If no pool, create new one.
if isempty(p)
    poolsize = 0;
    forparallel = parpool('local',feature('numcores')-1);
else
    poolsize = p.NumWorkers
end



firstimage = 1;
lastimage = 18;


%thermalimg = zeros(240,320);

%open excel file
tic
parfor i=firstimage:lastimage

    thermalimg = xlsread('thermalimagesall.xlsx',i,'B9:LI248');
    thermalimgtemp = imgaussfilt(thermalimg,2);
    [row,col]=find(abs(thermalimgtemp)==max(abs(thermalimgtemp(:))));
    heatprofile(:,i) = thermalimg(row(1),col(1)-90:col(1)+90);
    maxtemp(i) = max(heatprofile(:,i));

end
toc

heatprofile(:,1:lastimage-firstimage+1)=heatprofile(:,firstimage:lastimage);
maxtemp(1:lastimage-firstimage+1) = maxtemp(firstimage:lastimage);

hold on
plot(mean(heatprofile(:,1:3),2))
%std(heatprofile(:,1:3),0,2)
plot(mean(heatprofile(:,4:6),2))
plot(mean(heatprofile(:,7:9),2))
plot(mean(heatprofile(:,10:12),2))
plot(mean(heatprofile(:,13:15),2))
plot(mean(heatprofile(:,16:18),2))
hold off

tic
for i=1:(lastimage+1-firstimage)/3

    statistics(:,:,i) = [mean(heatprofile(:,1*i:3*i),2),std(heatprofile(:,1*i:3*i),0,2)];
    maxtempstats(:,i) = [mean(maxtemp(1*i:3*i)),std(maxtemp(1*i:3*i))];

end
toc

dlmwrite(filename,statistics,'delimiter','\t');
dlmwrite(strcat(filename,'maxtempstats'),maxtempstats,'delimiter','\t')
