% <span style="font-size:18px;">%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%Author: Ziheng H. Shen @Tsinghua Univ.  
%HybridGaussModel @Digital Image Process Practice  
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
clc;  
cd '...'
cntFrame = 500;  
% obj = VideoReader('768x576.avi');  
% numFrames = obj.NumberOfFrames;  
%  for k = 1 : cntFrame  
%      frame = read(obj,k);  
%       imwrite(frame,...  
%           strcat('C:\Users\Zi-Heng Shen\Documents\MATLAB\BackGroundModel\混合高斯背景建模\',...  
%           num2str(k),'.bmp'),'bmp');  
%  end  
%% 参数定义及初始化  
I = imread('seq00.avi0001.bmp');                    %读入第一帧作为背景帧  
fr_bw = I;       
[height,width] = size(fr_bw);           %求每帧图像大小  
width = width/3;                        %排除颜色通道数  
fg = zeros(height, width);              %定义前景和背景矩阵  
bg_bw = zeros(height, width);  
  
C = 3;                                  % 单高斯模型的个数(通常为3-5)  
M = 3;                                  % 代表背景的模型个数  
D = 2.5;                                % 偏差阈值  
alpha = 0.01;                           % 学习率  
thresh = 0.25;                          % 前景阈值  
sd_init = 15;                           % 初始化标准差  
w = zeros(height,width,C);              % 初始化权重矩阵  
mean = zeros(height,width,C);           % 像素均值  
sd = zeros(height,width,C);             % 像素标准差  
u_diff = zeros(height,width,C);         % 像素与某个高斯模型均值的绝对距离  
p = alpha/(1/C);                        % 初始化p变量，用来更新均值和标准差  
rank = zeros(1,C);                      % 各个高斯分布的优先级（w/sd)  
  
pixel_depth = 8;                        % 每个像素8bit分辨率  
pixel_range = 2^pixel_depth -1;         % 像素值范围[0,255]  
  
for i=1:height  
    for j=1:width  
        for k=1:C  
            mean(i,j,k) = rand*pixel_range;     %初始化第k个高斯分布的均值  
            w(i,j,k) = 1/C;                     % 初始化第k个高斯分布的权重  
            sd(i,j,k) = sd_init;                % 初始化第k个高斯分布的标准差             
        end  
    end  
end  
  
for n = 1:cntFrame  
%     frame=strcat(num2str(n),'.bmp');  
    if n<10
        frame = sprintf('seq00.avi000%d.bmp',n); % 根据实际图片序列信息进行修改
    elseif n<100
        frame = sprintf('seq00.avi00%d.bmp',n);
    else
        frame = sprintf('seq00.avi0%d.bmp',n);
    end
    I1 = imread(frame);  % 依次读入各帧图像  
    fr_bw = I1;         
    % 计算新像素与第m个高斯模型均值的绝对距离  
    for m=1:C  
        u_diff(:,:,m) = abs(double(fr_bw(:,:,m)) - double(mean(:,:,m)));  
    end  
    % 更新高斯模型的参数  
    for i=1:height  
        for j=1:width  
            match = 0;                                       %匹配标记;  
            for k=1:C                         
                if (abs(u_diff(i,j,k)) <= D*sd(i,j,k))       % 像素与第k个高斯模型匹配    
                    match = 1;                               %将匹配标记置为1  
                    % 更新权重、均值、标准差、p  
                    w(i,j,k) = (1-alpha)*w(i,j,k) + alpha;  
                    p = alpha/w(i,j,k);                    
                    mean(i,j,k) = (1-p)*mean(i,j,k) + p*double(fr_bw(i,j));  
                    sd(i,j,k) =   sqrt((1-p)*(sd(i,j,k)^2) + p*((double(fr_bw(i,j)) - mean(i,j,k)))^2);  
                else                                         % 像素与第k个高斯模型不匹配  
                    w(i,j,k) = (1-alpha)*w(i,j,k);           %略微减少权重     
                end  
            end        
            bg_bw(i,j)=0;  
            for k=1:C  
                bg_bw(i,j) = bg_bw(i,j)+ mean(i,j,k)*w(i,j,k);  
            end  
            % 像素值与任一高斯模型都不匹配，则创建新的模型  
            if (match == 0)  
                [min_w, min_w_index] = min(w(i,j,:));      %寻找最小权重  
                mean(i,j,min_w_index) = double(fr_bw(i,j));%初始化均值为当前观测像素的均值  
                sd(i,j,min_w_index) = sd_init;             %初始化标准差为6  
            end  
            rank = w(i,j,:)./sd(i,j,:);                    % 计算模型优先级  
            rank_ind = [1:1:C];%优先级索引         
            % 计算前景        
            fg(i,j) = 0;  
            while ((match == 0)&&(k<=M))           
                    if (abs(u_diff(i,j,rank_ind(k))) <= D*sd(i,j,rank_ind(k)))% 像素与第k个高斯模型匹配  
                        fg(i,j) = 0; %该像素为背景，置为黑色          
                    else  
                        fg(i,j) = 255;    %否则为前景，置为白色   
                    end                          
                k = k+1;  
            end  
        end  
    end  
    se = strel('disk',2);
    se2 = strel('line',6,90);
    se3 = strel('line',6,0);
    se4 = strel('disk',25);
%     se5 = strel('line',25,0);
    
    BW = imdilate(fg,se);
    BW2 = imerode(BW,se2);
    BW3 = imerode(BW2,se3);
    BW4 = imclose(BW3,se4);
    [L,num]=bwlabel(BW4);
    STATS = regionprops(L,'BoundingBox');
%     BW5 = imclose(BW3,se5);

    if n>330 & mod(n,5)==0 & n<355
        figure,
        imshow(frame) ,title(sprintf('混合高斯法—frame number %d',floor(n)));
        for i = 1:num
                rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
        end
    end
    if n>430 & mod(n,5)==0 & n<455
        figure,
        imshow(frame) ,title(sprintf('混合高斯法—frame number %d',floor(n)));
        for i = 1:num
                rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
        end
    end
    if n==340 | n==345 | n==350 | n==410 | n==415
        figure,
        imshow(fg) ,title(sprintf('混合高斯法—frame number %d',floor(n)));
    end
    if n==340 | n==345 | n==350 | n==410 | n==415 
        figure,
        imshow(BW4) ,title(sprintf('混合高斯法—frame number %d',floor(n)));
    end



%     imshow(frame);title(sprintf('混合高斯法—frame number %d',floor(n)));
%     for i = 1:num
%         rectangle('Position',STATS(i).BoundingBox,'EdgeColor','r');
%     end
    pause(0.000001);
%     %显示前景 imsh
end
% </span>