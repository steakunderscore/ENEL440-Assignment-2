clear all;
clc;

%  Ahah! I think I have sussed just what the states are (why was that not
%  documented??).
%  
%  x = [x_pos
%       y_pos
%       x_vel
%       y_vel]
%  
%  Believe it or not that was harder than it looks to figure out..

% Compute background image.
background = get_background(5);
[cols, rows, dim] = size(background);

% Initialise parameters.

% The covariance of the observation noise - a property of the sensor.
R = [0.2845*1 0.0045; 0.0045 0.0455*1];

% The observation model (easy to understand from
% ENME433) - simply says we can see the first two
% states, i.e., the position of the ball.
H = [1 0 0 0; 0 1 0 0];

% Process noise covariance.
Q = 0.01 * eye(4);

% The a posteriori error covariance matrix (a measure of the
% estimated accuracy of the state estimate).
P = 100 * eye(4); 

dt = 1; % ?? Fuck knows.

A = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];
g = 6; % Pixels per time step. I.e., gravity :)
Bu = [0; 0; 0; g];

x = zeros(4, 100);
x_freerun = zeros(2, 100);
z = zeros(2, 100);

first_time = 1;

for i = 1:60,
    
    % Load frame into memory.
    filename = strcat('data/basketball/', int2str(i), '.jpg');
    frame = imread(filename);
    imshow(frame);
    frame = double(frame);

    % Sensor measurement - find the center of the ball.
    [cc(i), cr(i), radius, flag, stats] = extract_ball(frame, background);
    z(:,i) = [cc(i); cr(i)];
    if flag == 0,
        continue
    end

    hold on;
    %% Print position of ball
    for c = (-1 * radius) : (radius / 20) : (1 * radius),
        r = sqrt(radius^2 - c^2);
        plot(cc(i)+c,cr(i)+r,'g.')
        plot(cc(i)+c,cr(i)-r,'g.')
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Predict:

    if (first_time == 1),
        xp = [cols/2; rows/2; 0; 0]; % Set inital state to the center of the image.
        first_time = 0;
    else,
        xp = A * x(:,i-1) + Bu; % predicted state estimate
    end
    
    PP = A*P*A' + Q; % Estimate covariance update.

    %% Update:
    
    K = PP * H' * inv(H * PP * H' + R); % Optimal Kalman gain.
    x(:,i) = (xp + K*(z(:,i) - H*xp) ); % Updated state estimate.
    P = (eye(4) - K*H)*PP; % Updated estimate covariance.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    hold on;

    % Show estiamted state.
    hold on
    for c = -1*radius: radius/20 : 1*radius
      r = sqrt(radius^2-c^2);
      plot(x(1,i)+c,x(2,i)+r,'r.')
      plot(x(1,i)+c,x(2,i)-r,'r.')
    end
    x(:,i);
    
%      [N, m] = size(stats);
%      for j = 1:N
%          plot(stats(j).Centroid(1), stats(j).Centroid(2), 'bo');
%      end

    % Slow mo!
    pause(0.3)

end

    
    

