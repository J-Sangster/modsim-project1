function [s_n, i_n, r_n, sr_n] = action_sir_reinfectivity(s, i, r, sr, beta, gamma, epsilon, zeta)
% Advance an SIR model one timestep
%
% Usage
%   [s_n, i_n, r_n] = action_sir(s, i, r, beta, gamma)
% 
% Arguments
%   s = current number of susceptible individuals
%   i = current number of infected individuals
%   r = current number of recovered individuals
%   
%   beta = infection rate parameter
%   gamma = recovery rate parameter
%   epsilon = resusceptibility rate parameter
%   zeta = infection rate for sr parameter
% 
% Returns
%   s_n = next number of susceptible individuals
%   i_n = next number of infected individuals
%   r_n = next number of recovered individuals

% compute new infections and recoveries
infected = min(beta * i * s,s) + min(zeta * i * sr, sr);
recovered = gamma * i;
susceptableRecovered = epsilon * r;


% Update state
s_n = s - infected;
i_n = i + infected - recovered;
r_n = r + recovered;
sr_n = sr + susceptableRecovered;

% Enforce invariants; necessary since we're doing a discrete approx.
s_n = max(s_n, 0);
i_n = max(i_n, 0);
r_n = max(r_n, 0);
sr_n = max(sr_n,0);

% s_n = min(s_n, 100 - i_n - r_n);
% i_n = min(i_n, 100 - s_n - r_n);
% r_n = min(r_n, 100 - i_n - s_n);


end