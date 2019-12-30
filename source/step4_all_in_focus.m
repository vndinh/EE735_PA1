function aif = step4_all_in_focus(labels, wimg)
  [height, width, channels] = size(wimg);
  num_images = channels / 3;
  
  aif = zeros(height, width, 3);
  L = zeros(height, width, 3);
  for i = 1:3
    L(:,:,i) = labels;
  end
  
  for i = 0:(num_images-1)
    img = wimg(:,:,(3*i+1):(3*i+3));
    aif(L==i) = img(L==i);
  end
  figure('Name', 'All-in-focus Image'); imshow(uint8(aif)); title('All-in-focus Image');
end