% Spring-cart dampner system.

clear

runtime = 30 % seconds


m = 1; % kg
c = 1; % unsure of units
k = 4; % ditto

A = [0 1; -k/m -c/m];
C = [1 0; 0 1];

dt = 0.001;
iterations = runtime / dt;

F = dt * A + eye(2);
H = C;

%Initialise
for i = (1:iterations),
    x{i} = [0; 0];
    z{i} = [0; 0];
end

x{1} = [3; 0];
x_{1} = x{1}
z{1} = x{1};
pos(1) = z{1}(1);

for k = (2:iterations),
    x_{k} = F*x_{k-1};
    true_state(k) = x_{k}(1);
end

[b, a] = butter(5, [0.0009], 'low');
noise = randn(1, iterations);
noise = filter(b, a, noise);

% time reverse the noise
noise = noise(end:-1:1);

for k = (2:iterations),
    x{k} = F*x{k-1} + noise(k)/200;
    z{k} = H*x{k-1};% + randn/10;
    pos(k) = z{k}(1);
    vel(k) = z{k}(2);
end

t = 0:dt:runtime-dt;

% Plots
subplot(2,1,1);
plot(t, pos, t, true_state);
ylabel('Position');
xlabel('Time (s)');
subplot(2,1,2);
plot(t, vel);
ylabel('Speed');
xlabel('Time (s)');
