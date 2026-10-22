% =========================================================================
% ALGORITMO DE CONTROL SIGE - MICRORED HÍBRIDA
% Eduardo Barros
% Software para Ingeniería
% =========================================================================

clear; clc; close all;

%% DEFINICIÓN DEL VECTOR TIEMPO
tiempo = 1:24;

%% GENERACIÓN SOLAR (Vector de 24 posiciones)
P_solar = zeros(1, 24);
horas_luz = 6:18;
P_solar(horas_luz) = 25 * sin(pi * (horas_luz - 6) / 12);

%% GENERACIÓN EÓLICA (Vector de 24 posiciones)
P_eolica = [8, 7, 9, 11, 10, 6, 5, 8, 12, 10, 7, 9, 11, 13, 14, 10, 8, 6, 9, 11, 12, 10, 9, 8];

%% GENERACIÓN HÍBRIDA TOTAL (E_gen)
E_gen = P_solar + P_eolica;

%% DEMANDA DE LA COMUNIDAD (E_dem)
E_dem = [3, 2, 3, 4, 3, 6, 7, 8, 9, 8, 7, 6, 12, 15, 14, 11, 5, 4, 6, 9, 11, 12, 10, 9];

%% CONFIGURACIÓN INICIAL DE LA BATERÍA
capacidad = 100;       % Capacidad total en kWh
SOC_actual = 50;       % Estado de Carga inicial en porcentaje (%)

n = length(E_gen);
SOC = zeros(1, n);
Escuela = zeros(1, n);
Bombeo = zeros(1, n);
Alumbrado = zeros(1, n);

%% CABECERA DEL REPORTE POR CONSOLA
fprintf('=================================================================================\n');
fprintf(' Hora | E_Gen(kW) | E_Dem(kW) | Balance    | SOC(%%)  | Escuela | Bombeo | Alumbrado \n');
fprintf('=================================================================================\n');

%% BUCLE DE SIMULACIÓN DE 24 HORAS (ALGORITMO SIGE)
for t = 1:n
    
    if E_gen(t) >= E_dem(t)
        % ===================================================
        % ESCENARIO: SUPERÁVIT ENERGÉTICO
        % ===================================================
        Excedente = E_gen(t) - E_dem(t);
        SOC(t) = SOC_actual + (Excedente / capacidad) * 100;
        
        if SOC(t) > 100
            SOC(t) = 100;
        end
        
        Escuela(t) = 1;
        Bombeo(t) = 1;
        Alumbrado(t) = 1;
        estado_txt = 'Superavit ';
        
    else
        % ===================================================
        % ESCENARIO: DÉFICIT ENERGÉTICO
        % ===================================================
        Faltante = E_dem(t) - E_gen(t);
        SOC(t) = SOC_actual - (Faltante / capacidad) * 100;
        
        if SOC(t) < 0
            SOC(t) = 0;
        end
        
        % Estructura condicional de umbrales del SOC (Control de Cargas)
        if SOC(t) > 40
            Escuela(t) = 1; Bombeo(t) = 1; Alumbrado(t) = 1;
            estado_txt = 'Deficit-Seg';
        elseif SOC(t) > 20
            Escuela(t) = 1; Bombeo(t) = 1; Alumbrado(t) = 0;
            estado_txt = 'Deficit-Ale';
        else
            Escuela(t) = 1; Bombeo(t) = 0; Alumbrado(t) = 0;
            estado_txt = 'Deficit-Eme';
        end
        
    end
    
    % Imprimir reporte por hora exigido por la guía en la consola
    fprintf('  %2d  |   %5.1f   |   %5.1f   | %s |  %5.1f  |    %d    |   %d    |     %d     \n', ...
        t, E_gen(t), E_dem(t), estado_txt, SOC(t), Escuela(t), Bombeo(t), Alumbrado(t));
    
    SOC_actual = SOC(t);
end
fprintf('=================================================================================\n');

%% VISUALIZACIÓN Y GRÁFICAS DE RESULTADOS
figure('Name', 'Simulación Algoritmo SIGE', 'Color', 'none');

% Gráfica 1: Comportamiento del Estado de Carga de la Batería (SOC)
subplot(2,1,1);
plot(tiempo, SOC, '-mo', 'LineWidth', 2, 'MarkerFaceColor', 'y');
grid on;
title('Comportamiento del Estado de Carga de la Batería (SOC) - 24 Horas', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Tiempo (Horas)', 'FontSize', 10);
ylabel('SOC (%)', 'FontSize', 10);
ylim([0 105]);

% Gráfica 2: Control Operativo de Cargas (Separadas visualmente)
subplot(2,1,2);
stairs(tiempo, Escuela + 0.1, '-r', 'LineWidth', 2); hold on;
stairs(tiempo, Bombeo, '-b', 'LineWidth', 2);
stairs(tiempo, Alumbrado - 0.1, '-g', 'LineWidth', 1.5);
grid on;
title('Control Operativo de Cargas de la Comunidad (Load Shedding)', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Tiempo (Horas)', 'FontSize', 10);
ylabel('Estado (1 = Activo, 0 = Apagado)', 'FontSize', 10);
legend({'Escuela Rural', 'Bombeo Agrícola', 'Alumbrado Público'}, 'Location', 'southwest', 'FontSize', 9);
ylim([-0.3 1.4]);