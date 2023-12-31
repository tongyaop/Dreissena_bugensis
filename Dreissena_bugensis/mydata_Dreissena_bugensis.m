function [data, auxData, metaData, txtData, weights] = mydata_Dreissena_bugensis
% file generated by prt_mydata
% modified by Tongyao Pu 2023/06/08, added data:
% tL, TF, TJO2, 

% global tT % temperature vector for Ashley2015 growth data tL1 and tL2
% global tf1 tf2 % functional response for Ashley2015 growth data tL1 and tL2

%% set metaData
metaData.phylum     = 'Mollusca';
metaData.class      = 'Bivalvia';
metaData.order      = 'Myida';
metaData.family     = 'Dreissenidae';
metaData.species    = 'Dreissena_bugensis';
metaData.species_en = 'quagga mussel';

metaData.ecoCode.climate = {'C','D'};
metaData.ecoCode.ecozone = {'TH'};
metaData.ecoCode.habitat = {'0iF'};
metaData.ecoCode.embryo  = {'Fpf'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'biPp'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(10); % K, body temp

metaData.data_0     = {'ab','am','tp','tj','Lb','Lp','Lj','Li','Wdb','Wdj','Wdp','Wdi','Ri'};
metaData.data_1     = {'tL', 'LWd', 'TF', 'XF'};

metaData.COMPLETE   = 2; % using criteria of LikaKear2011

metaData.author     = {'Shay Keretz', 'Tongyao Pu'};
metaData.date_subm  = [2023 6 6];
metaData.email      = {'skeretz@umich.edu', 'tongyaop@umich.edu'};
metaData.address    = {'CIGLR, NOAA GLERL'};

metaData.curator    = {'Dina Lika'};
metaData.email_cur  = {'lika@uoc.gr'};
metaData.date_acc   = [2023 6 6];

%% set zero-variate data
data.ab = 3; units.ab = 'd'; label.ab = 'age at birth'; bibkey.ab = {'Vander1996'};
  temp.ab = C2K(10); units.temp.ab = 'K'; label.temp.ab = 'temperature';
  comment.ab = '3d is the minimum';
data.tj = 15; units.tj = 'd'; label.tj = 'time since birth at end acceleration'; bibkey.tj = {'Ackerman1994'};
  temp.tj = C2K(10); units.temp.tj = 'K'; label.temp.tj = 'temperature';
  comment.tj = '18 days since fertilization minus 3 days of fertilization';
data.tp = 180; units.tp = 'd'; label.tp = 'time since birth at puberty'; bibkey.tp = {'Ashley'};
  temp.tp = C2K(10); units.temp.tp = 'K'; label.temp.tp = 'temperature';
  comment.tp = 'Ashley estim';
data.am = 1095; units.am = 'd'; label.am = 'life span'; bibkey.am = {'Wiki_TY'};
  temp.am = C2K(10); units.temp.am = 'K'; label.temp.am = 'temperature';
  comment.am = '1095 is the minimum';

data.Lb = 0.01; units.Lb = 'cm'; label.Lb = 'length at birth'; bibkey.Lb = {'Bowen2018'};
data.Lj = 0.03; units.Lj = 'cm'; label.Lj = 'length at end acceleration'; bibkey.Lj = {'Bowen2018'};
data.Lp = 0.7; units.Lp = 'cm'; label.Lp = 'length at puberty'; bibkey.Lp = {'Ashley'};
  comment.Lp = 'Ashley estim';
data.Li = 4.5; units.Li = 'cm'; label.Li = 'ultimate length'; bibkey.Li = {'Ashley'};
  comment.Li = 'Ashley estim';

data.Wdb = 1.98e-08; units.Wdb = 'g'; label.Wdb = 'dry weight at birth'; bibkey.Wdb = {'Bowen2018'};
data.Wdj = 1.47e-07; units.Wdj = 'g'; label.Wdj = 'dry weight at end acceleration'; bibkey.Wdj = {'Bowen2018'};
data.Wdp = 0.00063; units.Wdp = 'g'; label.Wdp = 'dry weight at puberty'; bibkey.Wdp = {'Ashley'};
  comment.Wdp = 'Ashley estim';
data.Wdi = 0.168; units.Wdi = 'g'; label.Wdi = 'ultimate dry weight'; bibkey.Wdi = {'Ashley'};
  comment.Wdi = 'Ashley estim';

data.Ri = 2740; units.Ri = '#/d'; label.Ri = 'ultimate reproduction rate'; bibkey.Ri = {'Wiki_TY'};
  temp.Ri = C2K(10); units.temp.Ri = 'K'; label.temp.Ri = 'temperature';

%% set uni-variate data

%% Elgin 2015
% ## time - length data
load ../data/Elgin2015_data_high_food_exp.mat
load ../data/Elgin2015_data_low_food_exp.mat
load ../data/Elgin2015_food_sim_J.mat

% model modified from Mastigias_papua, with advice from Bas

% time varying temperature (remember to make this a global variable)
% tT = [double(data_high_food_exp.week) .* 7, data_high_food_exp.temp_C]; % time (d), temperature (C)
% tT = [tT(:,1), C2K(tT(:,2))]; % convert Celsius to Kelvin

% tX1 = [double(food_sim_J.week).*7, food_sim_J.food_var_high];
% tX2 = [double(food_sim_J.week).*7, food_sim_J.food_var_low];

% tf1 = tX1;
% tf2 = tX2;

data.tL1 = [double(data_high_food_exp.week .* 7), data_high_food_exp.length_mm_expmean.*0.1]; % Time (d) shell length (cm)
units.tL1   = {'d','cm'};  label.tL1 = {'time', 'shell length'};  
bibkey.tL1 = 'Ashley';
temp.tL1 = double([data_high_food_exp.week .* 7, data_high_food_exp.temp_C]); % time (d), temperature (C)
temp.tL1 = [temp.tL1(:,1), C2K(temp.tL1(:,2))]; % convert Celsius to Kelvin
units.temp.tL1 = {'d','K'}; label.temp.tL = {'time','temperature'};
Linit.tL1 = 1.0441;    units.Linit.tL1  = 'cm';  label.Linit.tL1 = 'initial length high food';

data.tL2 = [double(data_high_food_exp.week .* 7), data_low_food_exp.length_mm_expmean.*0.1]; % Time (d) shell length (cm)
units.tL2   = {'d','cm'};  label.tL2 = {'time', 'shell length'};  
bibkey.tL2 = 'Ashley';
Linit.tL2 = 1.05148;    units.Linit.tL2  = 'cm';  label.Linit.tL2 = 'initial length low food';

%% GLERL length-weight
% ## length-weight data
load('../data/GLERL_lengthweight.mat');
data.LWd = [GLERL_lengthweight.shell_length .* 0.1, GLERL_lengthweight.tissue_ash_free_dry_wt .* 1e-3];
units.LWd   = {'cm','g'};  label.LWd = {'shell length', 'tissue AFDW'};  
bibkey.LWd = 'GLERL';

%% Tyner2015
% ## Temperature vs oxygen consumption
%  % temperature (C), Oxygen consumption (umol/h.mg)
%  % watch out for units.

Tyner2015_O2resp_temp_profundamorph_lab = readmatrix('../data/Tyner2015_O2resp_temp_profundamorph_lab.csv');
Tyner2015_O2resp_temp_shallowmorph_insitu = readmatrix('../data/Tyner2015_O2resp_temp_shallowmorph_insitu.csv');
Tyner2015_O2resp_temp_shallowmorph_lab = readmatrix('../data/Tyner2015_O2resp_temp_shallowmorph_lab.csv');

data.TJO1 = Tyner2015_O2resp_temp_profundamorph_lab;
units.TJO1   = {'C', 'umol/h.mg'};  label.TJO1 = {'temperature', 'spec dioxygen consumption'};  
bibkey.TJO1 = 'Tyner2015';
comment.TJO1 = 'profundamorph lab';
Lphy.TJO1 = 2.0;  units.Lphy.TJO1 = 'cm'; label.Lphy.TJO1 = 'physical length profundamorph';

% data.TJO2 = Tyner2015_O2resp_temp_shallowmorph_insitu;
% units.TJO2   = {'C', 'umol/h.mg'};  label.TJO2 = {'temperature', 'spec dioxygen consumption'};  
% bibkey.TJO2 = 'Tyner2015';
% comment.TJO2 = 'shallowmorph insitu';
%Lphy.TJ02 = 1.7;  units.Lphy.TJ02 = 'cm'; Label.Lphy.TJ02 = 'physical length shallow morph'; 

% data.TJO3 = Tyner2015_O2resp_temp_shallowmorph_lab;
% units.TJO3   = {'C', 'umol/h.mg'};  label.TJO3 = {'temperature', 'spec dioxygen consumption'};  
% bibkey.TJO3 = 'Tyner2015';
% comment.TJO3 = 'shallowmorph lab';
% Lphy.TJ01 = 1.7;  units.Lphy.TJ01 = 'cm'; Label.Lphy.TJ01 = 'physical length shallow morph';


% ## shell vs oxygen consumption at differet temp

%% Lei1996
% ## Filtration and clearance rate vs temperature. Lei1996 is zebra mussel
% data
% watch out for units. Crassostrea_corteziensis filtration rate has unit in
% L/g/h
% modified from Crassostrea_corteziensis 
Lei1996_Temp_FR_acclimated8C = readmatrix('../data/Lei1996_Temp_FR_acclimated8C.txt');
Lei1996_Temp_FR_acclimated20C = readmatrix('../data/Lei1996_Temp_FR_acclimated20C.txt');
% temperature (C), Filtration rate (mg/h.g)
data.TF1 = Lei1996_Temp_FR_acclimated8C;
units.TF1   = {'C', 'mg/h.g'};  label.TF1 = {'temperature', 'spec filtration rate'};  
bibkey.TF1 = 'Lei1996';
comment.TF1 = 'zebra mussel, acclimation to 8 dC, only mussels between 20 and 24 mm shell length were used, constant food';

% data.TF2 = Lei1996_Temp_FR_acclimated20C;
% units.TF2   = {'C', 'mg/h.g'};  label.TF2 = {'temperature', 'spec filtration rate'};  
% bibkey.TF2 = 'Lei1996';
% comment.TF2 = 'zebra mussel, acclimation to 20 dC, only mussels between 20 and 24 mm shell length were used';

% ## food concentration versus filtration and clearance rate (zebra mussel data)
Lei1996_X_FiltrationRate = readmatrix('../data/Lei1996_X_FiltrationRate.txt');
Lei1996_X_ClearanceRate = readmatrix('../data/Lei1996_X_ClearanceRate.txt');
% modified from Pinctada_margaritifera 
% food density [mg/L], filtration rate [mg/g/h]
data.X_FR = Lei1996_X_FiltrationRate;
units.X_FR   = {'mg/L', 'mg/g.h'};  label.X_FR = {'Microsohere concentration', 'filtration rate'};  
bibkey.X_FR = 'Lei1996';
comment.X_FR = 'zebra data. not sure if ere concentration is dry weight. assume it is';
temp.X_FR = 20; 
units.temp.X_FR = 'C'; label.temp.X_FR = 'temperature';

% food density [mg/L], clerance rate [L/g/h]
data.X_CR = Lei1996_X_ClearanceRate;
units.X_CR   = {'mg/L', 'L/g.h'};  label.X_CR = {'Microsohere concentration', 'clearance rate'};  
bibkey.X_CR = 'Lei1996';
comment.X_CR = 'zebra data. not sure if microsphere concentration is dry weight. assume it is';

%% GLERL 2008-11 Filtration
GLERL_2013Feeding_Co_ind = readmatrix('../data/GLERL_2013Feeding_Co_ind.csv');
%"Temp..C.","length..mm.","ind.Dw..mg.","AFDW..mg.","Z0..ug.chlorophyll.L.",
%"F..mL.mg.h.","FI..mL.mg.h.","CR..ug.mg.h.","IR..ug.mg.h.","X"
Z0 = GLERL_2013Feeding_Co_ind(:, 5); % Z0 [ug/L], initial concentration (C. ozolini)
FI = GLERL_2013Feeding_Co_ind(:, 7); % FI [mL/mg/h], water being filtered per dw per hr
IR = GLERL_2013Feeding_Co_ind(:, 9); % IR [ug/mg/h], food being filtered per dw per hr
ET = GLERL_2013Feeding_Co_ind(:, 1); % [C]
EL = 0.1 * GLERL_2013Feeding_Co_ind(:, 2); % [cm]

% GLERL_2013Feeding_Co = readmatrix('../data/GLERL_2013Feeding_Co.csv');
% % "Temp..C.","length_mm","length_se","dw_mg","dw_se",
% % "afdw_mg","afdw_se","Z0_ug_L","Z0_se","F_ml_mg.h",
% % "F_se","FI_mL_mg.h","FI_se","CR_ug_mg.h","CI_se",
% % "IR_ug_mg.h","IR_se","MDR_gC_gc.d","MDR_se"
% Z0 = GLERL_2013Feeding_Co(:, 8); % Z0 [ug/L], initial concentration (C. ozolini)
% FI = GLERL_2013Feeding_Co(:, 12); % FI [mL/mg/h], water being filtered per dw per hr
% IR = GLERL_2013Feeding_Co(:, 16); % IR [ug/mg/h], food being filtered per dw per hr
% ET = GLERL_2013Feeding_Co(:, 1); % [C], temp
% EL = 0.1 * GLERL_2013Feeding_Co(:, 2); % [cm], mussel length

data.X_CR_TL = [Z0 FI];
units.X_CR_TL = {'ug/L', 'mL/mg.h'};
label.X_CR_TL = {'Cryptomonas ozolini concentration', 'FI'};
bibkey.X_CR_TL = 'GLERL2013';
comment.X_CR_TL = 'GLERL filtration experiment from 2008 - 2011';

data.X_JX_TL = [Z0 IR];
units.X_JX_TL = {'ug/L', 'ug/mg.h'};
label.X_JX_TL = {'Cryptomonas ozolini concentration', 'IR'};
bibkey.X_JX_TL = 'GLERL2013';
comment.X_JX_TL = 'GLERL filtration experiment from 2008 - 2011';

temp.X_JX_TL = ET;
units.temp.X_JX_TL = 'C'; label.temp.X_JX_TL = 'temperature';

Lphy.X_JX_TL = EL;
units.Lphy.X_JX_TL = 'cm'; label.Lphy.X_JX_TL = 'physical length';

% avoid interpolate prediction
treat.X_CR_TL = {0};
treat.X_JX_TL = {0};
% data: length [mm], afdw [mg]

%% set weights for all real data
weights = setweights(data, []);
% weights.tL1 = weights.tL1 .* 0;
% weights.tL2 = weights.tL2 .* 0;
% weights.TF1 = weights.TF1 .* 1;
% weights.TF2 = weights.TF2 .* 0;
% weights.TJO1 = 0;
% weights.TJO2 = 0;
% weights.X_FR = 0;
% weights.X_IR = 0;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);

%% pack auxData and txtData for output
auxData.temp = temp;
auxData.Linit = Linit;
auxData.Lphy = Lphy;
auxData.treat = treat;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Links
metaData.links.id_CoL = ''; % Cat of Life
metaData.links.id_EoL = '63666377'; % Ency of Life
metaData.links.id_Wiki = 'Dreissena_bugensis'; % Wikipedia
metaData.links.id_ADW = 'Dreissena_bugensis'; % Anim Div. Web
metaData.links.id_Taxo = '361527'; % Taxonomicon
metaData.links.id_WoRMS = '505319';
metaData.links.id_molluscabase = '505319';

%% References
bibkey = 'Ackerman1994'; type = 'article'; bib = [ ...
''];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ', bib, '}'';'];
%
bibkey = 'Ashley'; type = 'misc'; bib = [ ...
''];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ', bib, '}'';'];
%
bibkey = 'Bowen2018'; type = 'article'; bib = [ ...
''];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ', bib, '}'';'];
%
bibkey = 'Kooy2010'; type = 'Book'; bib = [ ...  % used in setting of chemical parameters and pseudodata
'author = {Kooijman, S.A.L.M.}, ' ...
'year = {2010}, ' ...
'title  = {Dynamic Energy Budget theory for metabolic organisation}, ' ...
'publisher = {Cambridge Univ. Press, Cambridge}, ' ...
'pages = {Table 4.2 (page 150), 8.1 (page 300)}, ' ...
'howpublished = {\url{http://www.bio.vu.nl/thb/research/bib/Kooy2010.html}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Vander1996'; type = 'article'; bib = [ ...
''];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ', bib, '}'';'];
%
bibkey = 'Wiki_TY'; type = 'misc'; bib = [ ...
''];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ', bib, '}'';'];
bibkey = 'Lei1996'; type = 'misc'; bib = [ ...
''];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ', bib, '}'';'];
bibkey = 'Tyner2015'; type = 'misc'; bib = [ ...
''];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ', bib, '}'';'];
%
