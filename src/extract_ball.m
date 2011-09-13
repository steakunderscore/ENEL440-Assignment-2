% Extract the centre (cc, cr) and radius of the largest blob.
function [cc, cr, radius, flag, stats] = extract_ball(frame, background)

    cc = 0;
    cr = 0;
    radius = 0;
    flag = 0;
    [rows, cols, dim] = size(background);

    % Subtract background and select pixels with a big difference ???
    % The aim seems to be to get a white sillouette where the ball was.
    foreground = zeros(rows, cols);
    foreground = (abs(frame(:,:,1) - background(:,:,1)) > 10) ...
        |        (abs(frame(:,:,2) - background(:,:,2)) > 10) ...
        |        (abs(frame(:,:,3) - background(:,:,3)) > 10);

    % Clean up the image to get an even more circular sillouette.
    foreground = bwmorph(foreground, 'erode', 2);
    
    % Select largest object.

    % OK. I think I get how bwlabel works.
    % 1. assume you have a black and white image (i.e., 1's and 0's).
    % 2. it will labels serperate regions.
    labeled = bwlabel(foreground, 4);

    % Now extract info (area etc) from each white blob.
    stats = regionprops(labeled, ['basic']);

    % Do we even have one object? If not, get out.
    [N,W] = size(stats);
    if N < 1
        return
    end
    
    % Find largest blob., bubble sort

    %% REQUIRED %%%
      id = zeros(N);
    for i = 1 : N
        id(i) = i;
    end
    for i = 1 : N-1
        for j = i+1 : N
        if stats(i).Area < stats(j).Area
            tmp = stats(i);
            stats(i) = stats(j);
            stats(j) = tmp;
            tmp = id(i);
            id(i) = id(j);
            id(j) = tmp;
        end
        end
    end
    
    % [...]
    
    % make sure that there is at least 1 big region
    if stats(1).Area < 100
        return
    end
    

    % Get center of mass and radius of blob.
    centroid = stats(1).Centroid;

    radius = sqrt(stats(1).Area / pi);
    cc = centroid(1);
    cr = centroid(2);

    addnoise = 0;
    if addnoise == 1,
        cc = centroid(1) + 10*randn();
        cr = centroid(2) + 10*randn();
    end
    
    flag = 1;
    
    return