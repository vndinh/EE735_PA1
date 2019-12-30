function [Mp, Mf, FMs] = step2_focus_measure(warped_img)
  [height, width, channels] = size(warped_img);
  num_images = uint8(channels/3);
  
  % Create Optical Transfer Function (OTF)
  sigma1 = 1e-4;
  sigma2 = 1e-3;
  % kx, ky are spatial frequencies
  OTF = zeros(height, width);
  ky = -64;
  for c = 1:width
    kx = -36;
    for r = 1:height
      OTF(r, c) = exp(-sigma1*(kx^2+ky^2)) - exp(-sigma2*(kx^2+ky^2));
      kx = kx + 1e-1;
    end
    ky = ky + 1e-1;
  end
  figure; imshow(uint8(255*OTF/max(max(OTF)))); title('OTF');
  
  % Determine Focus Measure
  FMs = zeros(height, width, num_images);
  for n = 0:(num_images-1)
    wimg = warped_img(:,:,(3*n+1):(3*n+3));
    wimg = rgb2ycbcr(wimg);
    I = wimg(:,:,1);
    
    % Taking Fourier transform of image
    FI = fft2(I);
    FI = fftshift(FI);
    
    if n == 1
      max1 = max(FI);
      max2 = max(max1);
      fi = 255*FI/max2;
      figure; imshow(uint8(10*abs(fi))); title('The spectrum of the warped image');
    end
    
    % Process input image in the Fourier domain
    FHI = FI .* OTF;
    HI = ifft2(FHI);
  
    W = ones(3,3);
    reHI = abs(real(HI));
    FM = conv2(reHI, W, 'same');
    
    FMs(:,:,n+1) = FM;
  end
  
  % Labeling and take the sharpness
  [Mp, Mf] = max(FMs, [], 3);
  Mf = Mf - 1;
  
  %figure; imshow(uint8(255*Mp/max(max(Mp)))); title('Sharpness Image');
  figure; imshow(Mf/double(num_images)); colormap(gca, jet); title('Initial Focus Map');
end

