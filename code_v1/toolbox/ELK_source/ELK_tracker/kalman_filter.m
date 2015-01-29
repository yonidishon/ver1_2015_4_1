% Assuming:
%   H(k) = I (observation matrix)
%
% Abbriviations:
% x_prev    - xhat(k-1)
% y         - new measurement
% P_prev    - P(k-1) 
% Q         - Q(k) process noise
% R         - R(k) measurment noise
% F         - F(k-1,k) system dynamics

function [x,P] = kalman_filter(x_prev,y,P_prev,Q,R,F)

x_hat = F*x_prev;
% error est.
Pm = F*P_prev*F' + Q;
% kalman gain
G = Pm/(Pm+R);
% new predicted state
x = x_hat + G*(y-x_hat);
% final noise est.
P = (eye(size(G))-G)*Pm;
