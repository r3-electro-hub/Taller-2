## ARIAS ALFONSO, OSCAR FELIPE
## UNAL
## DIEE
clear
close al0
clc

%%El script la simulación de FEMM el problema 4.9 del libro de jhonk en ingles

%% Geometría [mm]

a = 10;
b = 20;
c = 30;

Rext = 2*c;

HV = 1000;

%% Casos

er1_vec = [20 10];
er2_vec = [10 20];

for n = 1:2

    %% Abrir FEMM
    openfemm;
    newdocument(1);

    ei_probdef('millimeters','planar',1e-8,1,30);

    er1 = er1_vec(n);
    er2 = er2_vec(n);

    %% Geometría

    % Conductor interior
    ei_drawarc([0,-a;0,a],180,2.5);
    ei_drawarc([0,a;0,-a],180,2.5);

    % Interfaz
    ei_drawarc([0,-b;0,b],180,2.5);
    ei_drawarc([0,b;0,-b],180,2.5);

    % Conductor exterior
    ei_drawarc([0,-c;0,c],180,2.5);
    ei_drawarc([0,c;0,-c],180,2.5);

    % Exterior
    ei_drawarc([0,-Rext;0,Rext],180,2.5);
    ei_drawarc([0,Rext;0,-Rext],180,2.5);

    %% Materiales

    ei_addmaterial('Air',1,1,0);
    ei_addmaterial('dielectrico1',er1,er1,0);
    ei_addmaterial('dielectrico2',er2,er2,0);

    %% Región interior

    ei_addblocklabel(0,a/2);
    ei_selectlabel(0,a/2);
    ei_setblockprop('<No Mesh>',0,1,0);
    ei_clearselected;

    %% Dieléctrico 1

    ei_addblocklabel(0,(a+b)/2);
    ei_selectlabel(0,(a+b)/2);
    ei_setblockprop('dielectrico1',0,1,0);
    ei_clearselected;

    %% Dieléctrico 2

    ei_addblocklabel(0,(b+c)/2);
    ei_selectlabel(0,(b+c)/2);
    ei_setblockprop('dielectrico2',0,1,0);
    ei_clearselected;

    %% Aire

    ei_addblocklabel(0,(c+Rext)/2);
    ei_selectlabel(0,(c+Rext)/2);
    ei_setblockprop('Air',0,1,0);
    ei_clearselected;

    %% Conductores

    ei_addconductorprop('HV',HV,0,1);
    ei_addconductorprop('GND',0,0,1);

    %% Conductor interior

    ei_selectarcsegment(a,0);
    ei_selectarcsegment(-a,0);

    ei_setarcsegmentprop(1,'<None>',0,0,'HV');

    ei_clearselected;

    %% Conductor exterior

    ei_selectarcsegment(c,0);
    ei_selectarcsegment(-c,0);

    ei_setarcsegmentprop(1,'<None>',0,0,'GND');

    ei_clearselected;

    %% Resolver

    if n==1
        ei_saveas('Caso1.fee');
    else
        ei_saveas('Caso2.fee');
    end

    ei_createmesh;
    ei_analyze;
    ei_loadsolution;

    %% Obtener E(rho)

    N = 500;

    rho = linspace(a+0.2,c-0.2,N);

    E = zeros(size(rho));

    theta = pi/4;

    for k = 1:N

        x = rho(k)*cos(theta);
        y = rho(k)*sin(theta);

        p = eo_getpointvalues(x,y);

        Ex = p(4);
        Ey = p(5);

        E(k) = sqrt(Ex^2+Ey^2);

    end

    %% Guardar resultados

    if n==1
        E1 = E;
    else
        E2 = E;
    end

    closefemm;

end

%% =======================
% Gráfica
%% =======================

figure('Position',[100 100 1000 700])

plot(rho,E1,'LineWidth',3)

hold on

plot(rho,E2,'LineWidth',3)

xline(b,'k--','LineWidth',2)

xlabel('\rho [mm]','FontSize',18)
ylabel('|E| [V/m]','FontSize',18)

title('Campo eléctrico en función de \rho','FontSize',22)

legend('\epsilon_1=2\epsilon_2', ...
       '\epsilon_1=\epsilon_2/2', ...
       'Interfaz \rho=b', ...
       'FontSize',16, ...
       'Location','northeast')

grid on

set(gca,'FontSize',16,'LineWidth',1.5)

xlim([a c])

box on
