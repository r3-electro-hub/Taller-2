%% ARIAS ALFONSO, OSCAR FELIPE
%% UNAL
%% DIEE

clear
close all
clc

%% ==========================================================
% Problema 4.17 - Johnk
% Capacitor de placas paralelas con dieléctrico de polietileno
%% ==========================================================

%% Geometría [mm]

L = 1000;          % altura de las placas
d = 1;             % separación entre caras internas
t = 1;           % espesor de las placas

HV = 100;          % voltaje aplicado [V]

er = 2.26;         % permitividad relativa del polietileno

%% Región exterior

margen = 50;

xmin = -t-margen;
xmax = d+t+margen;

ymin = -margen;
ymax = L+margen;

%% ==========================================================
% Abrir FEMM
%% ==========================================================

openfemm
newdocument(1)

ei_probdef('millimeters','planar',1e-8,1,30)

%% ==========================================================
% Frontera exterior
%% ==========================================================

ei_drawrectangle(xmin,ymin,xmax,ymax);

%% ==========================================================
% Placa izquierda (100 V)
%% ==========================================================

ei_drawrectangle(-t,0,0,L);

%% ==========================================================
% Placa derecha (0 V)
%% ==========================================================

ei_drawrectangle(d,0,d+t,L);

%% ==========================================================
% Materiales
%% ==========================================================

ei_addmaterial('Polietileno',er,er,0);

%% ==========================================================
% Conductores (No Mesh)
%% ==========================================================

% Placa izquierda

ei_addblocklabel(-t/2,L/2);

ei_selectlabel(-t/2,L/2);

ei_setblockprop('<No Mesh>',0,1,0);

ei_clearselected;


% Placa derecha

ei_addblocklabel(d+t/2,L/2);

ei_selectlabel(d+t/2,L/2);

ei_setblockprop('<No Mesh>',0,1,0);

ei_clearselected;

%% ==========================================================
% Polietileno (todo el dominio)
%% ==========================================================

ei_addblocklabel(d/2,L/2);

ei_selectlabel(d/2,L/2);

ei_setblockprop('Polietileno',0,1,0);

ei_clearselected;

%% ==========================================================
% Conductores
%% ==========================================================

ei_addconductorprop('HV',HV,0,1);

ei_addconductorprop('GND',0,0,1);

%% ==========================================================
% Placa izquierda (100 V)
%% ==========================================================

ei_selectsegment(-t/2,0);
ei_selectsegment(-t/2,L);
ei_selectsegment(0,L/2);

ei_setsegmentprop('<None>',1,0,0,0,'HV');

ei_clearselected;

%% ==========================================================
% Placa derecha (0 V)
%% ==========================================================

ei_selectsegment(d+t/2,0);
ei_selectsegment(d+t/2,L);
ei_selectsegment(d,L/2);

ei_setsegmentprop('<None>',1,0,0,0,'GND');

ei_clearselected;

%% ==========================================================
% Resolver
%% ==========================================================

ei_saveas('Problema_4_17.fee')

ei_createmesh

ei_analyze

ei_loadsolution

%% ==========================================================
% Obtener potencial y campo
%% ==========================================================

N = 500;

xx = linspace(0.001,d-0.001,N);

Phi_num = zeros(size(xx));

E_num = zeros(size(xx));

y0 = L/2;

for k = 1:N

    p = eo_getpointvalues(xx(k),y0);

    Phi_num(k) = p(1);

    Ex = p(4);
    Ey = p(5);

    E_num(k) = sqrt(Ex^2+Ey^2);

end

%% ==========================================================
% Solución analítica
%% ==========================================================

Phi_ana = HV*(d-xx)/d;

E_ana = (HV/d)*ones(size(xx));
%% ==========================================================
% Gráfica del potencial
%% ==========================================================

figure('Position',[100 100 1100 800])

plot(xx,Phi_num,'LineWidth',4)

xlabel('Posición x [mm]','FontSize',22)

ylabel('\Phi [V]','FontSize',22)

title('Distribución del potencial eléctrico entre las placas','FontSize',26)

legend('FEMM',...
       'FontSize',20,...
       'Location','northeast')

grid on

set(gca,'FontSize',20,'LineWidth',1.5)

box on


%% ==========================================================
% Gráfica del campo eléctrico
%% ==========================================================

figure('Position',[150 150 1100 800])

plot(xx,E_num,'LineWidth',4)

xlabel('Posición x [mm]','FontSize',22)

ylabel('|E| [V/mm]','FontSize',22)

title('Campo eléctrico entre las placas','FontSize',26)

legend('FEMM',...
       'FontSize',20,...
       'Location','northeast')

grid on

set(gca,'FontSize',20,'LineWidth',1.5)

box on
%% ==========================================================
% Cerrar FEMM
%% ==========================================================

closefemm
