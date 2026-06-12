## PROBLEMA 4.20
## Línea coaxial RG-213/U
## Verificación FEMM vs solución analítica

clear
close all
clc

%% ==========================
%% Datos geométricos [mm]
%% ==========================

a = 2.475;      % radio conductor interno
b = 9.14;       % radio interior conductor externo

Rext = 3*b;

%% ==========================
%% Propiedades
%% ==========================

er = 2.26;      % polietileno

%% Voltaje de prueba
%% (puede usarse 1000 V para verificar linealidad)

HV = 153000;

%% ==========================
%% FEMM
%% ==========================

openfemm;
newdocument(1);

ei_probdef('millimeters','planar',1e-8,1,30);

%% ==========================
%% Geometría
%% ==========================

% conductor interno

ei_drawarc([0,-a;0,a],180,2.5);
ei_drawarc([0,a;0,-a],180,2.5);

% conductor externo

ei_drawarc([0,-b;0,b],180,2.5);
ei_drawarc([0,b;0,-b],180,2.5);

% frontera exterior

ei_drawarc([0,-Rext;0,Rext],180,2.5);
ei_drawarc([0,Rext;0,-Rext],180,2.5);

%% ==========================
%% Materiales
%% ==========================

ei_addmaterial('Air',1,1,0);

ei_addmaterial('Polyethylene',er,er,0);

%% ==========================
%% Región interior
%% ==========================

ei_addblocklabel(0,a/2);

ei_selectlabel(0,a/2);

ei_setblockprop('<No Mesh>',0,1,0);

ei_clearselected;

%% ==========================
%% Dieléctrico
%% ==========================

ei_addblocklabel(0,(a+b)/2);

ei_selectlabel(0,(a+b)/2);

ei_setblockprop('Polyethylene',0,1,0);

ei_clearselected;

%% ==========================
%% Aire exterior
%% ==========================

ei_addblocklabel(0,(b+Rext)/2);

ei_selectlabel(0,(b+Rext)/2);

ei_setblockprop('Air',0,1,0);

ei_clearselected;

%% ==========================
%% Conductores
%% ==========================

ei_addconductorprop('HV',HV,0,1);

ei_addconductorprop('GND',0,0,1);

%% Conductor interior

ei_selectarcsegment(a,0);
ei_selectarcsegment(-a,0);

ei_setarcsegmentprop(1,'<None>',0,0,'HV');

ei_clearselected;

%% Conductor exterior

ei_selectarcsegment(b,0);
ei_selectarcsegment(-b,0);

ei_setarcsegmentprop(1,'<None>',0,0,'GND');

ei_clearselected;

%% ==========================
%% Resolver
%% ==========================

ei_saveas('Problema_4_20.fee');

ei_createmesh;

ei_analyze;

ei_loadsolution;



%% ==========================
%% Obtener E(rho)
%% ==========================

N = 500;

rho = linspace(a+0.05,b-0.05,N);

E_FEMM = zeros(size(rho));

theta = pi/4;

for k=1:N

    x = rho(k)*cos(theta);
    y = rho(k)*sin(theta);

    p = eo_getpointvalues(x,y);

    Ex = p(4);
    Ey = p(5);

    E_FEMM(k) = sqrt(Ex^2 + Ey^2);

end
Emax_FEMM = max(E_FEMM);

fprintf('\n');
fprintf('Campo máximo FEMM = %.4e V/m\n',Emax_FEMM);
fprintf('Campo ruptura     = %.4e V/m\n',4.72e7);

error_Emax = abs(Emax_FEMM-4.72e7)/4.72e7*100;

fprintf('Error             = %.4f %%\n',error_Emax);

closefemm;

%% ==========================
%% Solución analítica
%% ==========================

rho_m = rho*1e-3;

a_m = a*1e-3;

b_m = b*1e-3;

E_ANALITICA = HV ./ ...
              (rho_m .* log(b_m/a_m));

%% ==========================
%% Error porcentual
%% ==========================

error_rel = abs(E_FEMM-E_ANALITICA) ...
            ./E_ANALITICA*100;

fprintf('\n')
fprintf('Error máximo = %.4f %%\n',max(error_rel))
fprintf('Error medio  = %.4f %%\n',mean(error_rel))
fprintf('\n')

%% ==========================
%% Gráfica campo eléctrico
%% ==========================

figure('Position',[100 100 1000 700])

plot(rho,E_ANALITICA,'--',...
    'LineWidth',3)

hold on

plot(rho,E_FEMM,...
    'LineWidth',3)

xlabel('\rho [mm]','FontSize',18)

ylabel('|E| [V/m]','FontSize',18)

title('Campo eléctrico en línea coaxial RG-213/U',...
      'FontSize',22)

legend('Analítico',...
       'FEMM',...
       'Location','northeast')

grid on

set(gca,'FontSize',16,...
        'LineWidth',1.5)

box on


box on
