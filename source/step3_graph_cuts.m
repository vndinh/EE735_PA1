function labels = step3_graph_cuts(Mp, Mf, FMs, dataset)
  [height, width] = size(Mp);
  num_pixels = height * width;
  
  if dataset == 1
    num_labels = 25;
  elseif dataset == 2
    num_labels = 32;
  else
    disp('ERROR: dataset must equal to 1 or 2');
  end
  
  Mf = Mf(:)';
  init_labels = uint8(Mf+1);
  Mf = repmat(Mf, num_labels, 1);
  
  % Restoration Intensity of initial focus map
  % L1 loss of initial focus map
  for i = 1:num_labels
    Mf(i,:) = abs(Mf(i,:) - i + 1);
    max1 = max(Mf(i,:));
    Mf(i,:) = 255*Mf(i,:)/max1;
  end
  
  % Normalize the sharpness
  max1 = max(Mp);
  max2 = max(max1);
  Mp = Mp * 255 / max2;
  
  Mps = zeros(num_labels, num_pixels);
  FM = zeros(num_labels, num_pixels);
  for i = 1:num_labels
    Mps(i,:) = (reshape(Mp,[],1))';
    FM(i,:) = (reshape(FMs(:,:,i),[],1))';
    
    max1 = max(FM(i,:));
    FM(i,:) = FM(i,:) * 255 / max1;
    
  end
  
  % Data Cost
  max_dc = 128;
  dc = abs(FM-Mps);   % L1 loss between optical focus measure and sharpness
  DC = min(dc, Mf);
  DC = min(DC, max_dc);
  
  % Smoothness Cost
  SC = zeros(num_labels, num_labels);
  max_smoothness = 15;
  for i = 1:num_labels
    for j = 1:num_labels
      SC(i,j) = min(abs(i-j), max_smoothness);
    end
  end
  
  % Neighboring Relation
  E = edges4connected(height, width);
  N = sparse(E(:,1), E(:,2), 1, num_pixels, num_pixels, 4*num_pixels);
  
  % Grap-cuts Optimization
  handle = GCO_Create(num_pixels, num_labels);
  GCO_SetDataCost(handle, DC);
  GCO_SetSmoothCost(handle, SC);
  GCO_SetNeighbors(handle, N);
  GCO_SetLabeling(handle, init_labels);
  GCO_Expansion(handle);
  labels = GCO_GetLabeling(handle);
  GCO_Delete(handle);
  
  labels = reshape(labels, height, width);
  labels = labels - 1;
  figure('Name', 'Graph-cuts Result');
  imshow(uint8(255*labels/(num_labels-1))); colormap(gca, jet); title('Graph-cuts Result');
  
end
