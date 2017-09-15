
%%I(x)=J(x)t(x)+A(1-t(x));   I(x)~hazed img  J(x)~output
%%t(x)~transmission rate;   A~airlight

img_name = imread('train.bmp');
figure,imshow(img_name);
I = double(img_name)/255 ;
[h,w,c] = size(I);   %size of the input img
w0  = 0.85;  %dehazing coefficient
img_size = w * h;
dehaze = zeros(h,w,c);
e = zeros(h,w,c);
%initialise dark channel
win_dark = zeros(h,w);
for i=1:h                 
    for j=1:w
        win_dark(i,j)=min(I(i,j,:));%the darkest part/smallest value in RGB,which is calculated by pixels
    end
end

win_dark = ordfilt2(win_dark,5,ones(15,15)); %do min filtering in 15*15 windows

dark_channel = win_dark;
A = max(max(dark_channel));  %calculate arilight value
[i,j] = find(dark_channel==A);
i = i(1);
j = j(1);
A = mean(I(i,j,:)); %the brightest value in RGB
%raw transmission map
transmission = 1 - w0 * win_dark / A;
%figure,imshow(transmission);
gray_I = rgb2gray(I);
%figure,imshow(gray_I);
p = transmission;
r = 80;
eps = 10^-3;
transmission_filter = guidedfilter(gray_I, p, r, eps); %refine transmission map by guided filtering
t0=0.1;
t1 = max(t0,transmission_filter);

%figure,
%imshow(t1);
for i=1:c
    for j=1:h
        for l=1:w
            dehaze(j,l,i)=(I(j,l,i)-A)/t1(j,l)+A;   %assembly colorized  img
        end
    end
end
figure,
imshow(dehaze);
