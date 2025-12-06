% Instrument Identification Functions
function identifyInstrument(fig, audioNum)
    try
        appData = guidata(fig);
        
        if audioNum == 1 && isempty(appData.x1)
            warndlg('Please load Audio 1 first.', 'Missing Data');
            return;
        elseif audioNum == 2 && isempty(appData.x2)
            warndlg('Please load Audio 2 first.', 'Missing Data');
            return;
        elseif audioNum == 0 && (isempty(appData.x1) || isempty(appData.x2))
            warndlg('Please load both audio files first.', 'Missing Data');
            return;
        end
        
        if appData.isProcessing
            warndlg('Please wait for current operation to complete.', 'Processing');
            return;
        end
        
        appData.isProcessing = true;
        guidata(fig, appData);
        
        if audioNum == 1 || audioNum == 0
            % Identify instruments in Audio 1
            x = appData.x1_filtered;
            if isempty(x)
                x = appData.x1;
            end
            fs = appData.fs1;
            
            [instruments, features, spectrum, f] = identifyInstruments(x, fs);
            appData.identified_instruments1 = instruments;
            
            % Update display for Audio 1
            page = appData.pages{6};
            if ishandle(page.UserData.ax1)
                plot(page.UserData.ax1, f, spectrum, 'b', 'LineWidth', 1.5);
                xlabel(page.UserData.ax1, 'Frequency (Hz)');
                ylabel(page.UserData.ax1, 'Magnitude');
                title(page.UserData.ax1, sprintf('Audio 1 Spectrum - %d Instruments Found', length(instruments)));
                grid(page.UserData.ax1, 'on');
            end
            
            % Update table
            if ishandle(page.UserData.tbl1)
                tblData = cell(length(instruments), 5);
                for i = 1:length(instruments)
                    tblData{i,1} = instruments(i).name;
                    tblData{i,2} = sprintf('%.1f%%', instruments(i).confidence * 100);
                    tblData{i,3} = sprintf('%.1f', instruments(i).peakFreq);
                    tblData{i,4} = sprintf('%.1f', instruments(i).centroid);
                    tblData{i,5} = sprintf('%.3f', instruments(i).harmonicRatio);
                end
                page.UserData.tbl1.Data = tblData;
            end
        end
        
        if audioNum == 2 || audioNum == 0
            % Identify instruments in Audio 2
            x = appData.x2_filtered;
            if isempty(x)
                x = appData.x2;
            end
            fs = appData.fs2;
            
            [instruments, features, spectrum, f] = identifyInstruments(x, fs);
            appData.identified_instruments2 = instruments;
            
            % Update display for Audio 2
            page = appData.pages{6};
            if ishandle(page.UserData.ax2)
                plot(page.UserData.ax2, f, spectrum, 'r', 'LineWidth', 1.5);
                xlabel(page.UserData.ax2, 'Frequency (Hz)');
                ylabel(page.UserData.ax2, 'Magnitude');
                title(page.UserData.ax2, sprintf('Audio 2 Spectrum - %d Instruments Found', length(instruments)));
                grid(page.UserData.ax2, 'on');
            end
            
            % Update table
            if ishandle(page.UserData.tbl2)
                tblData = cell(length(instruments), 5);
                for i = 1:length(instruments)
                    tblData{i,1} = instruments(i).name;
                    tblData{i,2} = sprintf('%.1f%%', instruments(i).confidence * 100);
                    tblData{i,3} = sprintf('%.1f', instruments(i).peakFreq);
                    tblData{i,4} = sprintf('%.1f', instruments(i).centroid);
                    tblData{i,5} = sprintf('%.3f', instruments(i).harmonicRatio);
                end
                page.UserData.tbl2.Data = tblData;
            end
        end
        
        appData.isProcessing = false;
        guidata(fig, appData);
        updateSystemInfo(fig);
        
        if audioNum == 0
            msgbox('Both audios analyzed successfully!', 'Instrument Identification Complete');
        else
            msgbox(sprintf('Audio %d analyzed successfully!', audioNum), 'Instrument Identification Complete');
        end
        
    catch ME
        appData = guidata(fig);
        appData.isProcessing = false;
        guidata(fig, appData);
        handleError(fig, ME, 'Instrument Identification Error');
    end
end

% Core instrument identification algorithm
function [instruments, features, spectrum, f] = identifyInstruments(x, fs)
    N = length(x);
    
    % Use smaller FFT size to prevent memory issues
    fftSize = min(8192, N);
    
    % Calculate spectrum with limited size
    spectrum = abs(fft(x, fftSize));
    spectrum = spectrum(1:floor(fftSize/2)+1);
    f = (0:floor(fftSize/2)) * fs / fftSize;
    
    % Find spectral peaks with conservative settings
    [peaks, locs] = findpeaks(spectrum, ...
        'MinPeakHeight', max(spectrum)*0.05, ...
        'MinPeakDistance', max(1, floor(length(spectrum)/50)));
    
    % Limit number of peaks to prevent memory issues
    maxPeaks = min(10, length(peaks));
    peaks = peaks(1:maxPeaks);
    locs = locs(1:maxPeaks);
    
    % Enhanced instrument database with better frequency ranges
    instrumentDB = {
        'Violin', [196, 2093], 0.8, 'Strings';
        'Flute', [261, 2093], 0.7, 'Woodwind';
        'Trumpet', [165, 988], 0.6, 'Brass';
        'Piano', [27.5, 4186], 0.9, 'Percussion';
        'Guitar', [82, 880], 0.7, 'Strings';
        'Drums', [50, 200], 0.5, 'Percussion';
        'Voice', [87, 1175], 0.6, 'Vocal';
        'Saxophone', [138, 830], 0.7, 'Woodwind';
        'Cello', [65, 698], 0.8, 'Strings';
        'Clarinet', [146, 1568], 0.6, 'Woodwind';
        'Violin High', [659, 4186], 0.7, 'Strings';
        'Bass', [41, 247], 0.8, 'Strings';
        'Harp', [32.7, 3136], 0.7, 'Strings';
        'Oboe', [233, 1397], 0.6, 'Woodwind';
        'French Horn', [87, 880], 0.6, 'Brass'
    };
    
    instruments = [];
    
    % Match peaks to instruments
    for i = 1:length(peaks)
        peakFreq = f(locs(i));
        peakMag = peaks(i);
        
        bestMatch = '';
        bestScore = 0;
        bestCategory = '';
        
        for j = 1:size(instrumentDB, 1)
            instName = instrumentDB{j,1};
            freqRange = instrumentDB{j,2};
            baseConfidence = instrumentDB{j,3};
            category = instrumentDB{j,4};
            
            if peakFreq >= freqRange(1) && peakFreq <= freqRange(2)
                % Calculate frequency match score
                freqCenter = (freqRange(1) + freqRange(2)) / 2;
                freqWidth = freqRange(2) - freqRange(1);
                freqScore = 1 - abs(peakFreq - freqCenter) / freqWidth;
                
                % Calculate magnitude score
                magScore = peakMag / max(peaks);
                
                % Combined score
                score = baseConfidence * freqScore * magScore;
                
                if score > bestScore && score > 0.3
                    bestScore = score;
                    bestMatch = instName;
                    bestCategory = category;
                end
            end
        end
        
        if bestScore > 0.3 && ~isempty(bestMatch)
            instrument = struct();
            instrument.name = bestMatch;
            instrument.confidence = bestScore;
            instrument.peakFreq = peakFreq;
            instrument.centroid = sum(f .* spectrum) / sum(spectrum);
            instrument.harmonicRatio = calculateHarmonicRatio(spectrum, f, peakFreq);
            instrument.category = bestCategory;
            instruments = [instruments, instrument];
        end
    end
    
    % Remove duplicates and keep highest confidence
    if ~isempty(instruments)
        [~, uniqueIdx] = unique({instruments.name});
        instruments = instruments(uniqueIdx);
    end
    
    % Sort by confidence
    if ~isempty(instruments)
        [~, sortIdx] = sort([instruments.confidence], 'descend');
        instruments = instruments(sortIdx);
    end
    
    % Limit to top 5 instruments
    if length(instruments) > 5
        instruments = instruments(1:5);
    end
    
    % Calculate features
    features.centroid = sum(f .* spectrum) / sum(spectrum);
    features.bandwidth = sqrt(sum((f - features.centroid).^2 .* spectrum) / sum(spectrum));
    
    if ~isempty(locs)
        features.peakFrequencies = f(locs(1:min(3, length(locs))));
    else
        features.peakFrequencies = [];
    end
end

% Calculate harmonic ratio for a given fundamental frequency
function harmonicRatio = calculateHarmonicRatio(spectrum, f, fundamentalFreq)
    if fundamentalFreq == 0 || isempty(spectrum)
        harmonicRatio = 0;
        return;
    end
    
    harmonicEnergy = 0;
    totalEnergy = sum(spectrum);
    
    % Look for harmonics (2nd to 5th)
    for harmonic = 2:5
        harmonicFreq = fundamentalFreq * harmonic;
        if harmonicFreq > max(f)
            break;
        end
        
        % Find bin closest to harmonic frequency
        [~, idx] = min(abs(f - harmonicFreq));
        if idx <= length(spectrum)
            harmonicEnergy = harmonicEnergy + spectrum(idx);
        end
    end
    
    if totalEnergy > 0
        harmonicRatio = harmonicEnergy / totalEnergy;
    else
        harmonicRatio = 0;
    end
end

% Find common instruments between two audio files
function findCommonInstruments(fig, ~, ~)
    try
        appData = guidata(fig);
        page = appData.pages{7};
        
        if isempty(appData.identified_instruments1) || isempty(appData.identified_instruments2)
            warndlg('Please identify instruments for both audios first.', 'Missing Data');
            return;
        end
        
        if appData.isProcessing
            warndlg('Please wait for current operation to complete.', 'Processing');
            return;
        end
        
        appData.isProcessing = true;
        guidata(fig, appData);
        
        % Update button text
        if ishandle(page.UserData.btnFindCommon)
            page.UserData.btnFindCommon.Text = '⏳ Processing...';
            drawnow;
        end
        
        % Extract instrument names
        instruments1 = {appData.identified_instruments1.name};
        instruments2 = {appData.identified_instruments2.name};
        
        % Find common instruments
        commonInstruments = intersect(instruments1, instruments2);
        appData.common_instruments = commonInstruments;
        
        % Find unique instruments
        unique1 = setdiff(instruments1, instruments2);
        unique2 = setdiff(instruments2, instruments1);
        
        % Update summary
        if ishandle(page.UserData.lblCommonCount)
            page.UserData.lblCommonCount.Text = ...
                sprintf('Common Instruments: %d shared', length(commonInstruments));
            page.UserData.lblTotal1.Text = ...
                sprintf('Audio 1 Total Instruments: %d', length(instruments1));
            page.UserData.lblTotal2.Text = ...
                sprintf('Audio 2 Total Instruments: %d', length(instruments2));
            page.UserData.lblUnique1.Text = ...
                sprintf('Unique to Audio 1: %s', strjoin(unique1, ', '));
            page.UserData.lblUnique2.Text = ...
                sprintf('Unique to Audio 2: %s', strjoin(unique2, ', '));
        end
        
        % Update common instruments table
        if ishandle(page.UserData.tblCommon)
            tblData = cell(length(commonInstruments), 3);
            for i = 1:length(commonInstruments)
                tblData{i,1} = commonInstruments{i};
                tblData{i,2} = '✓';
                tblData{i,3} = '✓';
            end
            page.UserData.tblCommon.Data = tblData;
        end
        
        % Update instrument lists
        if ishandle(page.UserData.txtList1)
            page.UserData.txtList1.Value = instruments1';
            page.UserData.txtList2.Value = instruments2';
        end
        
        % Create simple Venn diagram
        createVennDiagram(page, length(instruments1), length(instruments2), length(commonInstruments));
        
        % Reset button text
        if ishandle(page.UserData.btnFindCommon)
            page.UserData.btnFindCommon.Text = '🔍 Find Common Instruments';
        end
        
        appData.isProcessing = false;
        guidata(fig, appData);
        
    catch ME
        appData = guidata(fig);
        appData.isProcessing = false;
        guidata(fig, appData);
        
        % Reset button text on error
        try
            appData.pages{7}.UserData.btnFindCommon.Text = '🔍 Find Common Instruments';
        catch
        end
        
        handleError(fig, ME, 'Common Instruments Analysis Error');
    end
end

% Create Venn diagram visualization
function createVennDiagram(page, count1, count2, countCommon)
    if ~ishandle(page.UserData.ax)
        return;
    end
    
    ax = page.UserData.ax;
    cla(ax);
    
    % Simple Venn diagram visualization
    theta = linspace(0, 2*pi, 100);
    
    % Circle 1 (Audio 1)
    r1 = sqrt(count1 + 1) * 0.1;
    x1 = -0.5 + r1 * cos(theta);
    y1 = r1 * sin(theta);
    fill(ax, x1, y1, [0.2 0.4 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'b', 'LineWidth', 2);
    hold(ax, 'on');
    
    % Circle 2 (Audio 2)
    r2 = sqrt(count2 + 1) * 0.1;
    x2 = 0.5 + r2 * cos(theta);
    y2 = r2 * sin(theta);
    fill(ax, x2, y2, [0.8 0.4 0.2], 'FaceAlpha', 0.5, 'EdgeColor', 'r', 'LineWidth', 2);
    
    % Overlap area
    if countCommon > 0
        overlapCenter = 0;
        overlapRadius = sqrt(countCommon + 1) * 0.08;
        xo = overlapCenter + overlapRadius * cos(theta);
        yo = overlapRadius * sin(theta);
        fill(ax, xo, yo, [0.6 0.4 0.6], 'FaceAlpha', 0.7, 'EdgeColor', 'm', 'LineWidth', 2);
    end
    
    % Labels
    text(ax, -0.5, r1+0.1, sprintf('Audio 1\n(%d)', count1), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', 'b');
    text(ax, 0.5, r2+0.1, sprintf('Audio 2\n(%d)', count2), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', 'r');
    
    if countCommon > 0
        text(ax, 0, 0, sprintf('Common\n(%d)', countCommon), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', 'm');
    end
    
    hold(ax, 'off');
    axis(ax, 'equal');
    axis(ax, 'off');
    title(ax, 'Instruments Distribution');
end

% Update system information
function updateSystemInfo(fig)
    try
        appData = guidata(fig);
        infoText = 'Status: Ready';
        
        if ~isempty(appData.filename1)
            infoText = sprintf('%s\nAudio 1: ✓ Loaded', infoText);
        else
            infoText = sprintf('%s\nAudio 1: ✗ Not Loaded', infoText);
        end
        
        if ~isempty(appData.filename2)
            infoText = sprintf('%s\nAudio 2: ✓ Loaded', infoText);
        else
            infoText = sprintf('%s\nAudio 2: ✗ Not Loaded', infoText);
        end
        
        if ~isempty(appData.x1_filtered) || ~isempty(appData.x2_filtered)
            infoText = sprintf('%s\nFilter: ✓ Applied', infoText);
        else
            infoText = sprintf('%s\nFilter: ✗ Not Applied', infoText);
        end
        
        if ~isempty(appData.identified_instruments1) || ~isempty(appData.identified_instruments2)
            infoText = sprintf('%s\nInstruments: ✓ Identified', infoText);
        else
            infoText = sprintf('%s\nInstruments: ✗ Not Identified', infoText);
        end
        
        if ishandle(appData.lblSystemInfo)
            appData.lblSystemInfo.Text = infoText;
        end
    catch ME
    end
end

% Handle errors
function handleError(fig, ME, context)
    errordlg(sprintf('%s: %s', context, ME.message), 'Error');
    fprintf('Error in %s: %s\n', context, ME.message);
    
    appData = guidata(fig);
    appData.isProcessing = false;
    guidata(fig, appData);

end
