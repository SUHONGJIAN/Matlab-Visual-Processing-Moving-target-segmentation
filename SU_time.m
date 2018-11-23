cd '...'
N = 40;% N frames to train the Gaussian model
h = fspecial('gaussian');
imagedata = filter2(h,rgb2gray(imread('seq00.avi0001.bmp'))); % 根据实际图片序列信息进行修改
mu = imagedata;
[m,n] = size(mu);
pro = zeros(m,n);
for i=1:N
    if i<10
        filename = sprintf('seq00.avi000%d.bmp',i); % 根据实际图片序列信息进行修改
    else
        filename = sprintf('seq00.avi00%d.bmp',i);
    end
    tmp =filter2(h,rgb2gray(imread(filename)));
    mu = mu+tmp;%(tmp+(i-1)*sav_mu)./i;%
end;
mu=mu./N;
figure(1),imshow(uint8(mu));
% test the new frame
for s = N+1:500
    if s<100
        filename = sprintf('seq00.avi00%d.bmp',s); % 根据实际图片序列信息进行修改
    else
        filename = sprintf('seq00.avi0%d.bmp',s);
    end
    imagedata = filter2(h,rgb2gray(imread(filename)));
    t=20; % 阈值，可调节
    pro = abs(imagedata-mu)> t;
    
    se = strel('line',7,90);
    se2 = strel('line',2,0);
    se3 = strel('line',25,0);
    se4 = strel('line',25,90);
    
    BW = imopen(pro,se);
    BW2 = imopen(BW,se2);
    BW3 = imclose(BW2,se3);
    BW4 = imclose(BW3,se4);
    [L,num]=bwlabel(BW4);
    STATS = regionprops(L,'BoundingBox');
    imshow(filename),title(sprintf('时间平均法—frame number %d',floor(s)));
    for i = 1:num
        rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
    end
    mu = (mu*(s-1) +imagedata)/s; %(1-a)*mu+a*(imagedata-mu);
    pause(0.000001);
end;