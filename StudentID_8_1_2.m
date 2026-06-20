%% Project 8 - DTMF Communication System
% Part 8-1-2: Base implementation - Generate DTMF signal for student ID
% Output: StudentID_8_1_4.wav (DTMF tones + silence)

clc;
clear;
clear all;

%% initiallizing

fs = 8000; %communication standard
samples_per_sound = 1000;
samples_per_silence = 1000;
t = (0:samples_per_sound-1) / fs;

low_freq_list = [697, 770, 852, 941];
high_freq_list = [1209, 1336, 1477, 1633];

key_freq = containers.Map();
key_freq('1') = [1, 1];
key_freq('2') = [1, 2];
key_freq('3') = [1, 3];
key_freq('4') = [2, 1];
key_freq('5') = [2, 2];
key_freq('6') = [2, 3];
key_freq('7') = [3, 1];
key_freq('8') = [3, 2];
key_freq('9') = [3, 3];
key_freq('0') = [4, 2];

studentID = '402102081';
output = [];

%% main code

for i = 1:length(studentID)
    digit = studentID(i);
    index = key_freq(digit);
    low_freq_digit = low_freq_list(index(1));
    high_freq_digit = high_freq_list(index(2));
    sound_each_digit = cos(2 *pi *low_freq_digit *t) + sin(2 *pi *high_freq_digit *t);
    normalized_sound = sound_each_digit / max(abs(sound_each_digit)) * 0.9; % 0.9 is just for to making sure that not clipping will happen
    output = [output, normalized_sound];

    if i < length(studentID)
        output = [output, zeros(1, samples_per_silence)];
    end
end

output = output / max(abs(output)) * 0.95;
audiowrite("StudentID_8_1_2.wav", output, fs);

sound(output, fs);

figure('Name', 'DTMF Waveform (StudentID)');
plot(output(1:min(17000, length(output))));
grid on;
xlabel('Sample index');
ylabel('Amplitude');
title('DTMF signal waveform (StudentID)');