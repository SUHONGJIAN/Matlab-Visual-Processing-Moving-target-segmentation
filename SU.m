tic;
mov = VideoReader('raw.avi');
x = read(mov,2);
x = rgb2gray(x);
fr_size = size(x);
width = fr_size(2);
height = fr_size(1);
c =zeros(height, width);
for k=1 : 1 : mov.NumberOfFrames-1
x = read(mov,k);
y = read(mov,k+1); % 可将1改为其它值，观察结果的不同
m = rgb2gray(x);
n = rgb2gray(y);
q=im2double(n);
w=im2double(m);
c = q - w ;
t=20; %%阈值，此值可以调节
t=t/255;%%转化为double型数据
id = c > t;
cc =zeros(fr_size);
cc(id) = 1;
se = strel('line',3,90);
se2 = strel('disk',25);
BW = imerode(cc,se);
BW2 = imclose(BW, se2);
[L,num]=bwlabel(BW2);
STATS = regionprops(L,'BoundingBox');
% BW1 = edge(cc3, 'sobel'); 
% BW2 = imfill(BW1,'holes');
figure(1),
%subplot(2,2,1),imshow(m)
%subplot(2,2,2),imshow(n);
%subplot(2,2,3),imshow(c);
%subplot(2,2,4),
% if k>330 & mod(k,2)==0 & k<360
%     figure,
%     imshow(y) ,title(sprintf('帧差法—frame number %d',floor(k)));
%     for i = 1:num
%             rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
%     end
% end
% if k==340 | k==345 | k==350 | k==410 | k==415 | k==450 | k==455
%     figure,
%     imshow(cc) ,title(sprintf('帧差法—frame number %d',floor(k)));
%     for i = 1:num
%             rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
%     end
% end
if k==340 | k==345 | k==350 | k==410 | k==415 
    figure,
    imshow(cc) ,title(sprintf('帧差法—frame number %d',floor(k)));
end
pause(0.000001);
end