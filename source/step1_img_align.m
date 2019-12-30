function wimg = step1_img_align(dataset, tmpID)
  switch dataset
    case 1
      num_images = 25;
      if (tmpID < 0) || (tmpID >= num_images)
        disp('ERROR: Index of the templated image must be from 0 to 24');
      end
      tmp = imread(strcat('..\data\PA1_dataset1_balls\', num2str(tmpID), '.jpg'));
    case 2
      num_images = 32;
      if (tmpID < 0) || (tmpID >= num_images)
        disp('ERROR: Index of the templated image must be an integer from 0 to 31');
      end
      tmp = imread(strcat('..\data\PA1_dataset2_keyboard\', num2str(tmpID), '.jpg'));
    otherwise
      disp('ERROR: dataset must equal to 1 or 2');
  end
  
  [M, N, ~] = size(tmp);
  wimg = zeros(M, N, 3*num_images);
  wimg(:,:,(3*tmpID+1):(3*tmpID+3)) = double(tmp);
  
  for i = 0:(num_images-1)
    if i ~= tmpID
      % Read images
      imgID = num2str(i);
      if dataset == 1
        load_path = strcat('..\data\PA1_dataset1_balls\', imgID, '.jpg');
      elseif dataset == 2
        load_path = strcat('..\data\PA1_dataset2_keyboard\', imgID, '.jpg');
      else
        disp('Error: dataset must equal to 1 or 2');
      end
      img = imread(load_path);
  
      % Extract SURF descriptors
      [d1, l1] = iat_surf(img);
      [d2, l2] = iat_surf(tmp);
    
      % Match keypoints
      [~, ~, imgInd, tmpInd] = iat_match_features(d1, d2, 0.9);
    
      X1 = l1(imgInd, 1:2);
      X2 = l2(tmpInd, 1:2);
      X1h = iat_homogeneous_coords(X1');
      X2h = iat_homogeneous_coords(X2');
    
      % RANSAC
      transform = 'affine';
      [inliers, ransacWarp] = iat_ransac(X2h, X1h, transform, 'tol', 0.05, 'maxInvalidCount', 10);
    
      % Plot filtered correspondences
      iat_plot_correspondences(img, tmp, X1(inliers,:)', X2(inliers,:)');
    
      % Compute the warped and error images
      [wimage, support] = iat_inverse_warping(img, ransacWarp, transform, 1:N, 1:M);
      [imerr_before] = iat_error2gray(double(tmp), double(img), support);
      [imerr_after] = iat_error2gray(double(tmp), double(wimage), support);
      
      wimg(:,:,(3*i+1):(3*i+3)) = wimage;
    
      % Display images and error of alignment
      figure('Name', 'Image and Error of Alignment');
      subplot(2,3,1); imshow(tmp); title(strcat('Frame ', num2str(tmpID)));
      subplot(2,3,2); imshow(img); title(strcat('Frame ', imgID));
      subplot(2,3,3); imshow(uint8(wimage)); title('Warped Image');
      subplot(2,3,4); imshow(uint8(imerr_before)); title('Error Before Alignment');
      subplot(2,3,5); imshow(uint8(imerr_after)); title('Error After Alignment'); 
    end
  end
end


