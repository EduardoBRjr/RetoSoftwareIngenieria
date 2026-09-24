%% ========================================
% Software para Ingeniería 
% RETO 2: Modelado del balance híbrido 
% Eduardo Barros
% =========================================

% Limpio la ventana de comandos, el espacio de trabajo y cerrar figuras previas
clc;
clear;
close all;

%% DEFINICIÓN DEL VECTOR TIEMPO
% Creo un vector fila que representa las 24 horas del día (de 1 a 24).
tiempo = 1:24;

%% GENERACIÓN SOLAR (Vector de 24 posiciones)
% Restricción: 0 en la noche (horas 1 a 5 y 19 a 24), curva ascendente 
% durante el día con un pico máximo de 25 kW a las 12 del mediodía.
P_solar = zeros(1, 24); % Inicializo un vector de ceros de 1x24

% Defino la curva solar usando una función matemática (campana) para las horas de luz (6 a 18)
% Uso el operador punto (.) para operaciones elemento a elemento
horas_luz = 6:18;
P_solar(horas_luz) = 25 * sin(pi * (horas_luz - 6) / 12);

%% GENERACIÓN EÓLICA (Vector de 24 posiciones)
% Restricción: Fluctúa irregularmente durante las 24 horas sin superar 15 kW.
% Defino valores manuales o pseudo-aleatorios controlados para simular el viento:
P_eolica = [8, 7, 9, 11, 10, 6, 5, 8, 12, 10, 7, 9, 11, 13, 14, 10, 8, 6, 9, 11, 12, 10, 9, 8];

%% GENERACIÓN HÍBRIDA TOTAL
% Suma matemática elemento a elemento de los vectores solar y eólico.
P_hibrida_total = P_solar + P_eolica;

%% DEMANDA DE LA COMUNIDAD (Vector de 24 posiciones)
% Restricciones:
% - Nocturno (1-5 y 22-24): 2 kW a 4 kW.
% - Diurno (6-17): 6 kW a 10 kW.
% - Pico máximo (18-21): hasta 15 kW.
P_demanda = [3, 2, 3, 4, 3,  ...  % Horas 1 a 5 (Nocturno base)
    6, 7, 8, 9, 8, 7, 8, 9, 10, 9, 8, 7, 6, ... % Horas 6 a 17 (Diurno)
    12, 15, 14, 11, ... % Horas 18 a 21 (Pico máximo)
    5, 4,];              % Horas 22 a 24 (Retorno a nocturno)

%% VISUALIZACIÓN GRÁFICA
figure('Name', 'Balance Híbrido de la Micro-red', 'Color', 'None');

% Graficar Generación Híbrida Total
plot(tiempo, P_hibrida_total, '-m', 'LineWidth', 3);
hold on; % Mantiene la gráfica actual para superponer la siguiente

% Graficar Demanda de la Comunidad
plot(tiempo, P_demanda, '--y', 'LineWidth',2.5);

% Personalización de la gráfica exigida por la guía
title('Simulación del Balance Energético: Generación Híbrida vs Demanda (24 Horas)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Tiempo (Horas)', 'FontSize', 11);
ylabel('Potencia (Kilovatios)', 'FontSize', 11);

% Configurar límites de los ejes y cuadrícula
xlim([1 24]);
ylim([0 40]);
grid on;

% Añadir leyenda para identificar cada curva
legend({'Generación Híbrida Total', 'Demanda de la Comunidad'}, 'Location', 'northeast', 'FontSize', 10);

hold off;