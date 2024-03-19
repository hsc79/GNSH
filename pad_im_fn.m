function [Bxy,dif_y,dif_x,px,py] = pad_im_fn(I_raw,im_size,re_Y,re_X)

pad_value = 0;
dif_y = (re_Y - im_size(1,1))/2;
dif_y_f = floor((re_Y - im_size(1,1))/2);

if (abs(dif_y - dif_y_f) > 0)
    By_x = padarray(I_raw,[dif_y_f,0],pad_value,'both');
    By = padarray(By_x,[1,0],pad_value,'post');
    py = 1;
else
    By = padarray(I_raw,[dif_y_f,0],pad_value,'both');
    py = 0;
end

dif_x = (re_X - im_size(1,2))/2;
dif_x_f = floor((re_X - im_size(1,2))/2);

if (abs(dif_x - dif_x_f) > 0)
    Bx_x = padarray(By,[0,dif_x_f],pad_value,'both');
    Bxy = padarray(Bx_x,[0,1],pad_value,'post');
    px = 1;
else
    Bxy = padarray(By,[0,dif_x_f],pad_value,'both');
    px = 0;
end