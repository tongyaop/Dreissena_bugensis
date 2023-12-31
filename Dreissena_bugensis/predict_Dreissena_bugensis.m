function [prdData, info] = predict_Dreissena_bugensis(par, data, auxData)
% file generated by prt_predict
% % modified by Tongyao Pu 2023/06/08

% unpack par, data, auxData
cPar = parscomp_st(par); vars_pull(par);
v2struct(par); v2struct(cPar); v2struct(data); v2struct(auxData);

%% compute temperature correction factors
pars_T = T_A;
if exist('T_L','var') && exist('T_AL','var')
    par_T = [T_A; T_L; T_AL];
end
if exist('T_H','var') && exist('T_AH','var')
    par_T = [T_A; T_H; T_AH];
end
if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    par_T = [T_A; T_L; T_H; T_AL; T_AH];
end

TC_ab = tempcorr(temp.ab, T_ref, pars_T);
TC_am = tempcorr(temp.am, T_ref, pars_T);
TC_tp = tempcorr(temp.tp, T_ref, pars_T);
TC_tj = tempcorr(temp.tj, T_ref, pars_T);
TC_Ri = tempcorr(temp.Ri, T_ref, pars_T);
tTC_tL1 = [temp.tL1(:,1), tempcorr(temp.tL1(:,2), T_ref, pars_T)]; % vector of T in time, K
TC_TF1 = tempcorr(C2K(TF1(:,1)), T_ref, pars_T);                   % temperature correction for temp-fr data (zebra acclimated to 8 dC)
TC_XJX = tempcorr(C2K(temp.X_FR), T_ref, pars_T);                            % assume temp = 20
TC_TJO1 = tempcorr(C2K(TJO1(:,1)), T_ref, pars_T);
TC_X_JX_TL = tempcorr(C2K(temp.X_JX_TL), T_ref, pars_T);
% customized filter
filterChecks = f_tL_high > 1 || f_tL_high <0 || f_tL_low > 1 || f_tL_low <0 || f_tF > 1 || f_tF < 0;
if filterChecks
    info = 0; prdData = []; return;
end
    
%% life cycle
pars_tj = [g; k; l_T; v_Hb; v_Hj; v_Hp];
[tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj(pars_tj, f);

if info == 0
    prdData = []; return;
end

% birth
L_b = L_m * l_b;                    % cm, structural length at birth
a_b = t_0 + tau_b/ k_M/ TC_ab;      % d, age at birth
Lw_b = L_b/ del_M;                  % cm, physical length at birth
Wd_b = L_b^3 * (1 + f * ome) * d_V; % g, dry weight at birth

% end of acceleration
L_j = L_m * l_j;                    % cm, structural length at end of acceleration
t_j = (tau_j - tau_b)/ k_M/ TC_tj;  % d, time since birth at end acceleration
Lw_j = L_j/ del_M;                  % cm, physical length at end acceleration
Wd_j = L_j^3 * (1 + f * ome) * d_V; % g, dry weight at end acceleration

% puberty
L_p = L_m * l_p;                    % cm, structural length at puberty
t_p = (tau_p - tau_b)/ k_M/ TC_tp;  % d, time since birth at puberty
Lw_p = L_p/ del_M;                  % cm, physical length at puberty
Wd_p = L_p^3 * (1 + f * ome) * d_V; % g, dry weight at puberty

% ultimate
L_i = L_m * l_i;                     % cm, ultimate structural length
Lw_i = l_i * L_m/ del_M;             % cm, ultimate physical length
Wd_i = L_i^3 * (1 + f * ome) * d_V;  % g, ultimate dry weight
pars_tm = [g; l_T; h_a/ k_M^2; s_G]; % compose parameter vector
tau_m = get_tm_s(pars_tm, f, l_b);   % -, scaled mean life span
a_m = tau_m/ k_M/ TC_am;             % d, mean life span

% reproduction
pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hj; U_Hp]; % compose parameter vector
R_i = TC_Ri * reprod_rate_j(L_i, f, pars_R);                  % #/d, ultimate reproduction rate

% pack to output
prdData.ab = a_b;
prdData.am = a_m;
prdData.tp = t_p;
prdData.tj = t_j;
prdData.Lb = Lw_b;
prdData.Lp = Lw_p;
prdData.Lj = Lw_j;
prdData.Li = Lw_i;
prdData.Wdb = Wd_b;
prdData.Wdj = Wd_j;
prdData.Wdp = Wd_p;
prdData.Wdi = Wd_i;
prdData.Ri = R_i;

%% ## Elgin2015 time (d) -length (cm)
% METHOD 1 default generated from AmPeps, constant temp condition,
% start from birth
% [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj(pars_tj, f_tL);
% r_B = TC_tL * rho_B * k_M; r_j = TC_tL * rho_j * k_M; t_j = (tau_j - tau_b)/ k_M/ TC_tL;
% L_b = L_m * l_b;  L_j = L_m * l_j; L_i = L_m * l_i;
% L_bj = L_b * exp(tL(tL(:,1) < t_j,1) * r_j/ 3);
% L_ji = L_i - (L_i - L_j) * exp( - r_B * (tL(tL(:,1) >= t_j,1) - t_j));
% tL = [L_bj; L_ji]/ del_M; % cm, physical length

% METHOD 2 model modified from Mastigias_papua, with advice from Bas. This
% model allows varying temperature but needs constant food. this model also
% does not consider starvation properly (in order to calculate starvation,
% a different method of calculating specific growth rate r is needed.
% Please refer to Tuesday lecture about starvation / corresponding
% starrlight and bas paper)

% r_j = rho_j * k_M; r_B = rho_B * k_M; % 1/d, exponential, von Bert growth rate
% L_initial = tL(1, 2).* del_M;

% E_initial = 0.005 .* E_m;
% L_initial = L_tL_high .* del_M;
% E_H_initial = E_Hp; % 10 mm mussel already matures?
% f = f_tL_high;
% [t ELH] = ode45(@dget_ELH, tL1(:,1), [E_initial; L_initial; E_H_initial], [], tTC, E_Hj, r_j, r_B, L_b, L_j, L_i, v, g, kap, k_J, E_m, f);
% ELw1 = ELH(:,2)/ del_M; % cm, bell diameter

% E_initial = 0.005 .* E_m;
% L_initial = L_tL_low .* del_M;
% E_H_initial = E_Hp; % 10 mm mussel already matures?
% f = f_tL_low;
% [t ELH] = ode45(@dget_ELH, tL2(:,1), [E_initial; L_initial; E_H_initial], [], tTC, E_Hj, r_j, r_B, L_b, L_j, L_i, v, g, kap, k_J, E_m, f);
% ELw2 = ELH(:,2)/ del_M; % cm, bell diameter

% METHOD 3 model modified from AmP trajectories/get_indDyn_mod with advice
% from Bas (varing food level) and starrlight (starvation). Refer to bas
% and starrlight paper about starvation. This methods includes full ODE for
% adj model that allows varing temperature and food level
pars_abj = [p_Am, v, p_M, k_J, kap, kap_G, E_G, E_Hb, E_Hj, E_Hp];
s_M = L_j/L_b;
L_initial = Linit.tL1 .* del_M;
E_initial = f .* E_m .* L_initial .^3;
E_H_initial = E_Hp;   % 10 mm mussel already matures?
R_initial = 0;
ELHRi = [E_initial, L_initial, E_H_initial, R_initial];
tf = f_tL_high;       % tf = [tT(1,1), f_tL_high]; % constant food level
tspan = tL1(:,1) - 7; % tspan need to be defined by tL vector, otherwise pred and plotting error
[tELHR]  = get_tELHR(tspan, pars_abj, tTC_tL1, tf, ELHRi, L_b, s_M);
L = tELHR(:, 3);      % cm, structural length
ELw1 = L ./del_M;     % cm, physical length

L_initial = Linit.tL2 .* del_M;
E_initial = f .* E_m .* L_initial .^3;
E_H_initial = E_Hp; % 10 mm mussel already matures?
R_initial = 0;
ELHRi = [E_initial, L_initial, E_H_initial, R_initial];
tf = f_tL_low;      % tf = [tT(1,1), f_tL_low]; % constant food level
tspan = tL2(:,1) - 7;
[tELHR]  = get_tELHR(tspan, pars_abj, tTC_tL1, tf, ELHRi, L_b, s_M);
L = tELHR(:, 3);    % cm, structural length
ELw2 = L ./del_M;   % cm, physical length

%% ## GLERL length (cm) - weight (g) % example Mytilus_trossulus
EWd_L = (LWd(:,1) * del_M).^3 * d_V * (1 + f_LWd * w); % g, dry weight including reserve (but not reproduction buffer)  
% What is w? what is the f_LWd * w term?

%% ## Lei1996 temperature (C), Filtration rate (mg/h.g)
% TC_TF2 = tempcorr(TF2(:,1), T_ref, pars_T); % temperature correction for temp-fr data (zebra acclimated to 8 dC)
Lp_TF = 2.2;                            % 2.0 - 2.4 cm; % shell length of this experiment
L_TF = Lp_TF * del_M;                   % cm, structual length
Wd_TF = L_TF^3 * d_V * (1 + f_tF * w);    % g, dry weight (includes structure, reserve, but not reprod. buffer)
J_X = L_TF^2 * J_X_Am * f_tF * TC_TF1;  % mol/d, food ingestion rate. Note that J_X_Am (from parscomp_st) has units cmol/d/cm2
EJX_TF1 = 1e3 * J_X * w_X / 24 / Wd_TF; % mg/h.g

%% ## Tyner2015 temperature - specific respiration % reference example Perna_perna (brown mussel)
p_ref = p_Am * L_m^2;                                           % J/d, max assimilation power at max size
L = Lphy.TJO1 * del_M;                                          % [cm], structural length
Wd = d_V * L^3 * (1 + f * w);                                   % [g], dry weight (includes structure, reserve, but not reprod. buffer)
pACSJGRD = p_ref * scaled_power_j(L, f, pars_R, l_b, l_j, l_p); % J/d, powers
pACSJGRD(:, 1) = 0;                                             % Assimilation is zero for starved animals
J_M = - (n_M\n_O) * eta_O * pACSJGRD(:, [1 7 5])';              % mol/d: J_C, J_H, J_O, J_N in rows
EjT_O1_umol = - J_M(3,:)' * TC_TJO1 * 1e6/ 24/ (Wd*1e3);        % umol O2/h.mg 

%% ## Lei1996 Feeding functional respons. This model only look at food truely ingested, without
% including overhead cost of assimilation (e.g. faeces, pseudofaeces, assimilation cost)
% food concentration [mg/L] (convert to cmol or J), clearance rate [L/g/h],
% filtration rate [mg/g/h]
L   = 2.2 * del_M;                            % [cm], mussel length in experiment (convert physical length to structural length)
Wd = d_V * L^3 * (1 + f * w) ;                % [g], dry weight (includes structure, reserve, but not reprod. buffer) 
X_g = X_FR(:,1) * 1e-03;                      % [g/L], food concentration.
X_cmol = X_g / w_X;                           % [C-mol/L], food concentration. molar mass of food (w_X) is 23.9 g/c-mol
X_J = X_cmol * mu_X ;                         % [J/L], food concentration. with energy unit
p_Xm = (1/kap_X)*(1/kap)*z * p_M;             % [J/d/cm2]. algebraically from z = L_m / L_m^ref(1cm). Lm = kap p_Am/p_M

% Sanity check: method 1 should provide the exact same output as method 2. They are the same algebraically
% method 1   
CR = TC_XJX * p_Xm * L^2 ./ (X_J + p_Xm/F_m); % [L/d], clearance rate
ECR_CR = CR / 24 / Wd;
EJX_FR = X_FR(:,1) .* ECR_CR;                 % [mg/h/g], filtration rate (how much food being filtred and ingested*)

% method 2
p_X = TC_XJX * p_Xm * L^2 * X_J ./ (X_J + p_Xm/F_m); % [J/d], food ingestion flux
EJX_FR = p_X * (w_X/mu_X) * 1e3 / 24 / Wd;        % [mg/h/g], filtration rate 
ECR_CR = EJX_FR ./ X_FR(:,1);                                % [L/h/g], clearance rate

%% ## GLERL 2008-11 Filtration
L   = Lphy.X_JX_TL * del_M;                            % [cm], mussel length in experiment (convert physical length to structural length)
Wd = d_V * L.^3 * (1 + f * w) ;                % [g], dry weight (includes structure, reserve, but not reprod. buffer) 
X_g = X_JX_TL(:,1) * 1e-06;                      % [g/L], food concentration.
X_cmol = X_g / w_X;                           % [C-mol/L], food concentration. molar mass of food (w_X) is 23.9 g/c-mol
X_J = X_cmol * mu_X ;                         % [J/L], food concentration. with energy unit
p_Xm = (1/kap_X)*(1/kap)*z * p_M;             % [J/d/cm2]. algebraically from z = L_m / L_m^ref(1cm). Lm = kap p_Am/p_M
K = p_Xm / F_m; 

% p_XJ = p_Xm * TC_X_JX_TL .* L.^2;
% CR = p_XJ ./ (X_J + K);
CR = (p_Xm * TC_X_JX_TL .* L.^2) ./ (X_J + p_Xm/F_m); % [L/d], clearance rate
EJX_GLERL2008_CR = CR ./ Wd ./ 24;                % [mL/mg/h], milli cancels out
EJX_GLERL2008_FR = CR .* X_JX_TL(:,1) ./ (Wd .* 1e3) ./ 24; % [ug/mg/h], filtration rate (how much food being filtred and ingested*)

%% pack to output
prdData.tL1 = ELw1;    % time - length
prdData.tL2 = ELw2;    % time - length
prdData.LWd = EWd_L;   % length - dry weight
prdData.TF1 = EJX_TF1; % temperature - filtration rate
prdData.X_FR = EJX_FR; % food concentration - filtration rate
prdData.X_CR = ECR_CR; % food concentration - clearance rate
prdData.TJO1 = EjT_O1_umol; % temperature - oxygen consumption
prdData.X_CR_TL = EJX_GLERL2008_CR; % [mL/mg/h]
prdData.X_JX_TL = EJX_GLERL2008_FR; % [ug/mg/h]

save('prdData.mat', 'prdData')
end

% function dELH = dget_ELH(t, ELH, tTC, E_Hj, r_j, r_B, L_b, L_j, L_i, v, g, kap, k_J, E_m, f)
%     E = ELH(1); L = ELH(2); E_H = ELH(3); % cm, J: structural length, maturity
%     % scaled reserve density
%     e = E / L^3 /E_m;
%     de = (f - e) * v / L;
%     % s_M = min(L, L_j)/ L_b; % -, acceleration factor
%     s_M = L_j / L_b;
%     r = v * s_M * (e/ L - 1/ L_i)/ (e + g); % 1/d, spec growth rate
%     p_C = L^3 * E_m * e * (s_M * v/ L - r); % J/d, mobilisation rate
%     dE_H = 0; %(1 - kap) * p_C - k_J * E_H; % change in maturity at T_ref
%
%     % if E_H < E_Hj
%     %     dL = L * r_j/3; % cm/d, change in length before metam at T_ref
%     % else
%     %     dL = r_B * (L_i - L); % cm/d, change in length after metam at T_ref
%     % end
%     %
%     % dL = r_B * (L_i - L); % cm/d, change in length after metam at T_ref? L is
%     % not at T_ref. This way, L will increase
%
%
%     % if kap * p_C - p_S > 0
%     %     r = v * s_M * (e/ L - 1/ L_i)/ (e + g); % 1/d, spec growth rateelse % starvation
%     %     r = ()/()
%     % end
%     % p_C = L^3 * E_m * e * (s_M * v/ L - r); % J/d, mobilisation rate
%     dL = L * r/3; % only this could make L decrease?
%
%     dE = L^2 * (L * de + e * 3 * dL) * E_m;
%
%
%     dELH = spline1(t, tTC) * [dE; dL; dE_H]; % cm/d, J/d: changes at T
%
% end

function [tELHR]  = get_tELHR(tspan, pars_abj, tTC, tf, ELHRi, Lb, s_M)
% modified from get_indDyn_mod
% Edited 2023/06/12 by Tongyao

% tspan = tTC(:,1); % set simulation time
% options = odeset('Events',@stage_events_abj, 'AbsTol',1e-9, 'RelTol',1e-9);

% if size(tf, 1) == 1
%     tf = [tspan(1) tf(1,2); tspan(end) tf(1,2)];
% end

options = [];
% % the following simulates from metamorphosis to the end of simulation
% L_b = NaN;
% s_M = NaN; % this cannot be NaN, otherwise the predicted length will explode
isterminal =[0,0,0];
[t, ELHR] = ode45(@dget_ELHR_abj, tspan, ELHRi, options, pars_abj, tTC, tf, Lb, s_M, isterminal);

% pack output
tELHR = [t, ELHR];
end

function dELHR = dget_ELHR_abj(t, ELHR, p, tTC, tf, Lb, s_M, isterminal)
% this is got from AmP code
% Define changes in the state variables for abj model
% t: time
% ELHR: 4-vector with state variables
%         E , J, reserve energy
%         L , cm, structural length
%         E_H , J , cumulated energy inversted into maturity (E_H in Kooijman 2010)
%         E_R , J, reproduction buffer (E_R in Kooijman 2010)
%
% dELHR: 4-vector with change in E, L, H, R

% unpack state variables

E = ELHR(1); L = ELHR(2); E_H = ELHR(3);

% unpack par
p_Am = p(1); v = p(2); p_M = p(3); k_J = p(4);
kap = p(5); kap_G = p(6);
E_G = p(7); E_Hb = p(8); E_Hj = p(9); E_Hp = p(10);

TC = spline1(t, tTC);  % C, temperature at t
% f_t = spline1(t, tf);  % -, scaled functional response at t
if size(tf,1) > 1
    f_t = spline1(t, tf);  % -, scaled functional response at t
else
    f_t = tf;
end
    
% temp correction
pT_Am = TC * p_Am ; % maximium assimilation rate (per area)
vT = TC * v; % conductance (not rate but corrected?)
pT_M = TC * p_M; % somatic maintenance (per volume)
kT_J = TC * k_J; % maturity maint. rate coefficient

% Fluxes
if isnan(s_M) % if uss calculation, l was simulated to be infinite.
    s_M = L/Lb;  % -, acceleration factor. multiplication factor for v and {p_Am}
end

pA = (pT_Am * s_M * f_t * L^2) * (E_H >= E_Hb);

if  kap * E * s_M * vT >= pT_M * L^4 % section 4.1.5 comments to Kooy2010
    r = (E * s_M * vT/ L - pT_M * L^3/ kap)/ (E + E_G * L^3/ kap); % d^-1, specific growth rate
else
    r = (E * s_M * vT/ L - pT_M * L^3/ kap)/ (E + kap_G * E_G * L^3/ kap); % d^-1, specific growth rate
end
pC  = E * (s_M * vT/ L - r); % J/d, mobilized energy flux
% generate derivatives
dE    = pA - pC;  % J/d, change in energy in reserve
dL    = r * L / 3;    % cm^3/d, change in structural volume
dE_H  = ((1 - kap) * pC - kT_J * E_H) * (E_H<E_Hp);     % J/d, change in cumulated energy invested in maturation
dE_R  = ((1 - kap) * pC - kT_J * E_Hp) * (E_H >= E_Hp); % J/d, change in reproduction buffer

% pack derivatives
dELHR = [dE; dL; dE_H; dE_R];
end


% function [value,isterminal,direction] = stage_events_abj(t, ELHR, p, tTC, tf, Lb, s_M, isterminal)
%     E_Hb = p(8); E_Hj = p(9); E_Hp = p(10);
%     value = [E_Hb, E_Hj, E_Hp] - [ELHR(3), ELHR(3), ELHR(3)];
%     direction = 0;
% end
