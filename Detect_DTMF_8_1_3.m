%% Project 8 - DTMF Communication System
% Part 8-1-3: Recognize digits from DTMF signal
% Input: StudentID_8_1_2.wav (DTMF tones + silence)
% Output: Detected digits and frequency spectrum plots

clc;
clear; 
clear all;

%% test

test = detect_dtmf("StudentID_8_1_2.wav");
disp([test])

%% definition of function

function StudentID = detect_dtmf(audio_file)

    [signal , fs] = audioread(audio_file);

    figure('Name', 'DTMF Waveform (first segment)');
    plot(signal(1:min(17000, length(signal))));
    grid on;
    xlabel('Sample index');
    ylabel('Amplitude');
    title('DTMF signal waveform (first segment)');

    samples_per_digit = 1000;
    samples_per_silence = 1000;
    total_samples_per_digit = samples_per_digit + samples_per_silence;
    num_digits = floor(length(signal) / total_samples_per_digit) + 1;

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

%% remapping and recognizing digit

    freq_to_digit = containers.Map();
    key_list = keys(key_freq);

    for i = 1:length(key_list)
        digit = key_list{i};
        index = key_freq(digit);
        key_name = sprintf('%d_%d', index(1), index(2));
        freq_to_digit(key_name) = digit;
    end

    detected_digits = '';
    detected_digit = '';

    for i = 1:num_digits
        detected_digit = '';
        signal_segment = signal((i-1)*total_samples_per_digit +1 : min(length(signal), i*total_samples_per_digit));
        signal_segment_without_silence = signal_segment(1 : min(length(signal_segment), samples_per_digit));

        N = length(signal_segment_without_silence);
        f_shifted = (-N/2:N/2-1)*((fs)/N);
        y_fft = fft(signal_segment_without_silence);
        y_fft_shifted = fftshift(y_fft);
        magnitude = abs(y_fft_shifted) ./ N;

        subplot(3, 3, i);
        plot(f_shifted, magnitude, 'LineWidth', 1.8);
        xlabel('$Frequency (Hz)$', 'Interpreter', 'latex', 'FontSize', 12);
        ylabel('$|X(f)|$', 'Interpreter', 'latex', 'FontSize', 12);
        title('Magnitude Spectrum (using FFT \& fftshift)', 'Interpreter', 'latex', 'FontSize', 12);
        grid on; 
        ymin = min(abs(y_fft_shifted)./N) - 0.1; 
        ymax = max(abs(y_fft_shifted)./N) + 0.5; 
        ylim([ymin ymax]);
    
        positive_index = f_shifted > 0;
        f_positive = f_shifted(positive_index);

        [peaks, locs] = findpeaks(magnitude(positive_index), 'SortStr', 'descend', 'MinPeakHeight', 0.1*max(magnitude(positive_index)));

        f1 = 0;
        f2 = 0;

        if length(peaks) >= 2
            f1 = f_positive(locs(1));
            f2 = f_positive(locs(2));
            hold on;
            plot(f1, peaks(1), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
            plot(f2, peaks(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
            text(f1+50, peaks(1), sprintf('  %.0f Hz', f1), 'Color', 'red');
            text(f2+50, peaks(2), sprintf('  %.0f Hz', f2), 'Color', 'red');
            hold off;
        end

        low_freq_digit = min(f1, f2);
        high_freq_digit = max(f1, f2);

        [~, low_index] = min(abs(low_freq_list - low_freq_digit));
        [~, high_index] = min(abs(high_freq_list - high_freq_digit));

        low_error = abs(low_freq_list(low_index) - low_freq_digit);
        high_error = abs(high_freq_list(high_index) - high_freq_digit);

        if low_error < 30 && high_error < 30
            key_name = sprintf('%d_%d', low_index, high_index);
            if isKey(freq_to_digit, key_name)
                detected_digit = freq_to_digit(key_name);
            end
        end
        detected_digits = [detected_digits, detected_digit];
    end
    StudentID = detected_digits;
end

