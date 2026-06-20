%% Project 8 - DTMF Communication System
% Part 8-1-4: Demodulation
% Inout: ReceivedSignal.wav
% Output: Demodulated_DTMF_8_1_4.wav (DTMF tones + silence)

clc;
clear; 
clear all;

[signal , fs] = audioread('ReceivedSignal.wav');

N = length(signal);
f = (-N/2:N/2-1) * (fs/N);

f_shifted = (-N/2:N/2-1)*((fs)/N);
y_fft = fft(signal);
y_fft_shifted = fftshift(y_fft);
magnitude = abs(y_fft_shifted) ./ N;

figure(1);
plot(f_shifted, magnitude, 'LineWidth', 1.8);
xlabel('$Frequency (Hz)$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$|X(f)|$', 'Interpreter', 'latex', 'FontSize', 12);
title('Magnitude Spectrum (using FFT \& fftshift)', 'Interpreter', 'latex', 'FontSize', 12);
grid on; 
ymin = min(abs(y_fft_shifted)./N) - 0.1; 
ymax = max(abs(y_fft_shifted)./N) + 0.5; 
ylim([ymin ymax]);

bandpass_center = 100000;
bandpass_length = 10000;
bandpass_start = bandpass_center - bandpass_length ./2;
bandpass_end = bandpass_center + bandpass_length ./2;

mask = zeros(size(f));
mask(abs(f) >= bandpass_start& abs(f) <= bandpass_end) = 1;

signal_freq_filtered = y_fft_shifted .* mask';

signal_time_filtered = real(ifft(ifftshift(signal_freq_filtered)));

figure('Name', 'Filtered Spectrum');
plot(f/1000, abs(signal_freq_filtered)/N, 'LineWidth', 1.5);
xlabel('Frequency (kHz)', 'FontSize', 12);
ylabel('Magnitude', 'FontSize', 12);
title('After Band-pass Filter (95-105 kHz)', 'FontSize', 14);
grid on;
xlim([90, 110]);

%% Demodulation

t = (0:length(signal_time_filtered)-1)/fs;
carrier = cos(2*pi*100000*t') ;

signal_mixed = signal_time_filtered .* carrier;

fc_lp = 2000;   
[b,a] = butter(8, fc_lp/(fs/2), 'low');

signal_lowpass_filtered = filtfilt(b,a, signal_mixed);

signal_without_dc = signal_lowpass_filtered - mean(signal_lowpass_filtered);

signal_normallized = signal_without_dc / max(abs(signal_without_dc));

standard_fs = 8000;
signal_DTMF = resample(signal_normallized, standard_fs, fs);

audiowrite("Demodulated_DTMF_8_1_4.wav", signal_DTMF, standard_fs);
sound(signal_DTMF, standard_fs);



