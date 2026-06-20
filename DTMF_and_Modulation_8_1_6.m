%% Project 8 - DTMF Communication System
% Part 8-2: Modulation
% Output: StudentID.wav (DTMF tones + silence)

clc;
clear;
close all;

%% initiallizing

fs = 8000; 
samples_per_sound = 1000;
samples_per_silence = 1000;
t = (0:samples_per_sound-1) / fs;

low_freq_list = [697, 770, 852, 941];
high_freq_list = [1209, 1336, 1477, 1633];

key_freq = containers.Map();
key_freq('1') = [1, 1];
key_freq('2') = [1, 2];
key_freq('3') = [1, 3];
key_freq('A') = [1, 4];
key_freq('4') = [2, 1];
key_freq('5') = [2, 2];
key_freq('6') = [2, 3];
key_freq('B') = [2, 4];
key_freq('7') = [3, 1];
key_freq('8') = [3, 2];
key_freq('9') = [3, 3];
key_freq('C') = [3, 4];
key_freq('*') = [4, 1];
key_freq('0') = [4, 2];
key_freq('#') = [4, 3];
key_freq('D') = [4, 4];

Number = '99101234';
Number_sound = [];

%% main code

for i = 1:length(Number)
    digit = Number(i);
    index = key_freq(digit);
    low_freq_digit = low_freq_list(index(1));
    high_freq_digit = high_freq_list(index(2));
    sound_each_digit = cos(2 *pi *low_freq_digit *t) + sin(2 *pi *high_freq_digit *t);
    normalized_sound = sound_each_digit / max(abs(sound_each_digit)) * 0.9;
    Number_sound = [Number_sound, normalized_sound];

    if i < length(Number)
        Number_sound = [Number_sound, zeros(1, samples_per_silence)];
    end
end

Number_sound = Number_sound / max(abs(Number_sound)) * 0.95;

sound(Number_sound, fs);
audiowrite("Number_sound_8_1_6.wav", Number_sound, fs);

figure('Name', 'DTMF Waveform (StudentID)');
plot(Number_sound(1:min(17000, length(Number_sound))));
grid on;
xlabel('Sample index');
ylabel('Amplitude');
title('DTMF signal waveform (Number)');

%% Modulation

t_total = (0:length(Number_sound)-1) / fs;
f_carrier = 100000;
carrier = cos(2 *pi *f_carrier *t_total);

noise_rate = 0.85;
modulation_rate = 0.8;

Number_sound_normalized = Number_sound / max(abs(Number_sound));
Number_sound_with_offset = Number_sound_normalized .* modulation_rate + 1;

modulated_signal = Number_sound_with_offset .* carrier;
noise = noise_rate * randn(1, length(modulated_signal));
output = modulated_signal + noise;

output_normalized = output / max(abs(output)) * 0.95;

audiowrite("Received_Modulated_Number_8_1_6.wav", output_normalized, fs);
%sound(output, fs);

figure('Name', 'DTMF Waveform (Number) with noise');
plot(output_normalized(1:min(17000, length(output_normalized))));
grid on;
xlabel('Sample index');
ylabel('Amplitude');
title('DTMF Waveform (Number) with noise');
