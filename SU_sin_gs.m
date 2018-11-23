% This M-file uses single Gaussian model for background pixels
cd '...'
N = 40;% N frames to train the Gaussian model
h = fspecial('gaussian');
imagedata = filter2(h,rgb2gray(imread('seq00.avi0001.bmp'))); %根据实际图片信息进行修改
mu = imagedata;
[m,n] = size(mu);
cov = zeros(m,n);
pro = zeros(m,n);
sav_mu = mu;
a = 0.01;
for i=1:N
    if i<10
        filename = sprintf('seq00.avi000%d.bmp',i); % 根据实际图片序列信息进行修改
    else
        filename = sprintf('seq00.avi00%d.bmp',i);
    end
    tmp =filter2(h,rgb2gray(imread(filename)));
    mu = (tmp+(i-1)*sav_mu)./i;
    cov = ((tmp-mu).^2+(i-1)*cov)./(i)+(mu-sav_mu).^2;
    sav_mu = mu;
end;
cov = cov+0.001; %防止cov为0
% test the new frame
for s = N+1:500
    if s<100
        filename = sprintf('seq00.avi00%d.bmp',s); % 根据实际图片序列信息进行修改
    else
        filename = sprintf('seq00.avi0%d.bmp',s);
    end
    imagedata = double(filter2(h,rgb2gray(imread(filename))));
    T=1e-15; % 阈值，可调节
    pro = (2*pi)^(-1/2)*exp(-0.5*(imagedata-mu).^2./cov)./sqrt(cov)< T;
    pro = mat2gray(pro);
    se1 = strel('line',25,0);
    se2 = strel('line',25,90);
    BW1 = imclose(pro,se1);
    BW2 = imclose(BW1,se2);
    [L,num]=bwlabel(BW2);
    STATS = regionprops(L,'BoundingBox');
    

    
    
    imshow(filename),title(sprintf('单高斯法—frame number %d',floor(s)));
    for i = 1:num
        rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
    end
    %% update covariance and mean
    mu = mu +a*(1-pro).*(imagedata-mu); %(1-a)*mu+a*(imagedata-mu);
    cov = cov + a*(1-pro).*((imagedata-mu).^2-cov);%(1-a)*cov+a*(imagedata-mu).^2;
    pause(0.000001);
end;