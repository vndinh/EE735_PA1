function refined_depth = step5_depth_refine(aif, labels, dataset)
  if dataset == 1
    num_images = 25;
  elseif dataset == 2
    num_images = 32;
  else
    disp('ERROR: dataset must equal to 1 or 2');
  end
  
  aif = uint8(aif);
  labels = uint8(labels);
  refined_depth = weighted_median_filter_approx(labels, aif, 5, 0.01, num_images);
  figure; imshow(255*refined_depth/num_images); colormap(gca, jet); title('Refined Depth');
end
