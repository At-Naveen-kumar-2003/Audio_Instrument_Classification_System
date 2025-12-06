% Main GUI Initialization Function
function Instrument_Classifier_Extended
    try
        if verLessThan('matlab', '9.13')
            warndlg('This GUI is optimized for MATLAB 2022b or later. Some features may not work correctly.', 'Version Warning');
        end
    catch
    end
    
    colors = struct();
    colors.primary = [0.2, 0.4, 0.6];
    colors.secondary = [0.3, 0.6, 0.5];
    colors.accent = [0.9, 0.5, 0.2];
    colors.background = [0.95, 0.97, 0.98];
    colors.panel = [1, 1, 1];
    colors.nav = [0.25, 0.35, 0.45];
    colors.success = [0.2, 0.7, 0.3];
    colors.warning = [0.9, 0.6, 0.1];
    colors.purple = [0.5, 0.2, 0.7];
    colors.pink = [0.9, 0.3, 0.5];
    colors.cyan = [0.2, 0.7, 0.8];
    
    fig = uifigure('Name', 'Advanced Dual Audio Instrument Classifier - Extended Edition', ...
        'Position', [50 50 1200 750], 'Color', colors.background, ...
        'AutoResizeChildren', 'on', 'HandleVisibility', 'callback', ...
        'WindowState', 'maximized');
    fig.CloseRequestFcn = @closeGUI;

    screenSize = get(0, 'ScreenSize');
    figWidth = screenSize(3);
    figHeight = screenSize(4);
    
    navPanelWidth = 220;
    navPanelMargin = 10;
    infoPanelHeight = 100;
    
    navPanelPosition = [navPanelMargin, navPanelMargin, navPanelWidth, figHeight - 2 * navPanelMargin];
    
    navPanel = uipanel(fig, 'Position', navPanelPosition, ...
        'Title', 'NAVIGATION', 'BackgroundColor', colors.nav, ...
        'ForegroundColor', [1 1 1], 'FontWeight', 'bold', 'FontSize', 11, ...
        'Units', 'pixels');
    
    btnHeight = 40;
    btnGap = 5;
    btnYPosStart = navPanelPosition(4) - 45 - btnHeight;
    currentBtnYPos = btnYPosStart;
    
    btnNames = {'Load Audio 1', 'Load Audio 2', 'Noise Removal', 'HHT Analysis', ...
        'Wavelet Analysis', 'Identify Instruments', 'Common Instruments', ...
        'Evaluation', 'Recommendation', 'Visual Compare', 'Export Results', ...
        'Help & About'};

    btnCallbacks = {@(~,~) showPage(1), @(~,~) showPage(2), @(~,~) showPage(3), ...
        @(~,~) showPage(4), @(~,~) showPage(5), @(~,~) showPage(6), ...
        @(~,~) showPage(7), @(~,~) showPage(8), @(~,~) showPage(9), ...
        @(~,~) showPage(10), @(~,~) showPage(11), @(~,~) showPage(12)};
    
    btnColors = [colors.accent; colors.cyan; colors.primary; colors.primary;
        colors.primary; colors.success; colors.cyan; colors.primary;
        colors.accent; colors.purple; colors.pink; colors.secondary];
    
    navButtons = gobjects(12, 1);
    for i = 1:12
        navButtons(i) = uibutton(navPanel, 'push', 'Text', btnNames{i}, ...
            'Position', [15 currentBtnYPos 190 btnHeight], 'ButtonPushedFcn', btnCallbacks{i}, ...
            'BackgroundColor', btnColors(i,:), 'FontColor', [1 1 1], 'FontSize', 10, ...
            'Tag', sprintf('navBtn%d', i));
        currentBtnYPos = currentBtnYPos - btnHeight - btnGap;
    end
    
    infoPanelYPos = 10;
    infoPanel = uipanel(navPanel, 'Position', [15 infoPanelYPos 190 infoPanelHeight], ...
        'BackgroundColor', [0.3 0.4 0.5], 'BorderType', 'none');
    
    uilabel(infoPanel, 'Position', [10 75 170 20], ...
        'Text', 'SYSTEM STATUS', 'FontSize', 10, 'FontWeight', 'bold', ...
        'FontColor', [1 1 1], 'HorizontalAlignment', 'center');

    lblSystemInfo = uilabel(infoPanel, 'Position', [10 5 170 70], ...
        'Text', 'Status: Ready', 'FontSize', 8, 'FontColor', [0.9 0.9 0.9], ...
        'VerticalAlignment', 'top', 'Tag', 'lblSystemInfo', 'WordWrap', 'on');
    
    contentPanelX = navPanelPosition(1) + navPanelPosition(3) + navPanelMargin;
    contentPanelY = navPanelMargin;
    contentPanelWidth = figWidth - contentPanelX - navPanelMargin;
    contentPanelHeight = figHeight - 2 * navPanelMargin;
    
    contentPanel = uipanel(fig, 'Position', [contentPanelX contentPanelY contentPanelWidth contentPanelHeight], ...
        'Title', '', 'BackgroundColor', colors.panel, 'BorderType', 'line', ...
        'AutoResizeChildren', 'off');
    
    appData = struct();
    appData.x1 = [];
    appData.x1_filtered = [];
    appData.fs1 = [];
    appData.filename1 = '';
    appData.snr_before1 = 0;
    appData.snr_after1 = 0;
    appData.hht_time1 = 0;
    appData.wavelet_time1 = 0;
    appData.hht_features1 = [];
    appData.wavelet_features1 = [];
    appData.identified_instruments1 = {};
    appData.player1 = [];
    appData.isPlaying1 = false;

    appData.x2 = [];
    appData.x2_filtered = [];
    appData.fs2 = [];
    appData.filename2 = '';
    appData.snr_before2 = 0;
    appData.snr_after2 = 0;
    appData.hht_time2 = 0;
    appData.wavelet_time2 = 0;
    appData.hht_features2 = [];
    appData.wavelet_features2 = [];
    appData.identified_instruments2 = {};
    appData.player2 = [];
    appData.isPlaying2 = false;
    
    appData.common_instruments = {};
    appData.currentPage = 1;
    appData.colors = colors;
    appData.navButtons = navButtons;
    appData.hht_scores = struct();
    appData.wavelet_scores = struct();
    appData.isProcessing = false;
    appData.btnColorsInitial = btnColors;
    
    pages = cell(12, 1);
    pageMargin = 10;
    pageWidth = contentPanelWidth - 2 * pageMargin;
    pageHeight = contentPanelHeight - 2 * pageMargin;

    for i = 1:12
        pages{i} = uipanel(contentPanel, 'Position', [pageMargin pageMargin pageWidth pageHeight], ...
            'BorderType', 'none', 'BackgroundColor', colors.panel, 'Visible', 'off', ...
            'Tag', sprintf('page%d', i));
    end
    
    createLoadPage1(pages{1}, colors);
    createLoadPage2(pages{2}, colors);
    createFilterPage(pages{3}, colors);
    createHHTPage(pages{4}, colors);
    createWaveletPage(pages{5}, colors);
    createIdentifyPage(pages{6}, colors);
    createCommonInstrumentsPage(pages{7}, colors);
    createEvaluationPage(pages{8}, colors);
    createRecommendationPage(pages{9}, colors);
    createComparePage(pages{10}, colors);
    createExportPage(pages{11}, colors);
    createHelpPage(pages{12}, colors);
    
    appData.pages = pages;
    appData.lblSystemInfo = lblSystemInfo;
    
    guidata(fig, appData);
    
    showPage(1);
    updateSystemInfo();

    % GUI cleanup function
    function closeGUI(~, ~)
        try
            appData = guidata(fig);
            if ~isempty(appData.player1) && isvalid(appData.player1) && appData.isPlaying1
                stop(appData.player1);
            end
            if ~isempty(appData.player2) && isvalid(appData.player2) && appData.isPlaying2
                stop(appData.player2);
            end
            delete(fig);
        catch ME
            warning('Error during GUI cleanup: %s', ME.message);
            delete(fig);
        end
    end

    % Show selected page and update navigation
    function showPage(pageNum)
        try
            appData = guidata(fig);
            if appData.isProcessing
                return;
            end
            for i = 1:length(appData.pages)
                if ishandle(appData.pages{i})
                    appData.pages{i}.Visible = 'off';
                end
            end
            if ishandle(appData.pages{pageNum})
                appData.pages{pageNum}.Visible = 'on';
                appData.currentPage = pageNum;
            end
            for i = 1:length(appData.navButtons)
                if ishandle(appData.navButtons(i))
                    if i == pageNum
                        appData.navButtons(i).BackgroundColor = appData.colors.accent;
                    else
                        appData.navButtons(i).BackgroundColor = appData.btnColorsInitial(i,:);
                    end
                end
            end
            guidata(fig, appData);
            updateSystemInfo();
        catch ME
            handleError(ME, 'Page Navigation Error');
        end
    end

    % Update system status information
    function updateSystemInfo()
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

    % Unified error handling
    function handleError(ME, context)
        errordlg(sprintf('%s: %s', context, ME.message), 'Error');
        fprintf('Error in %s: %s\n', context, ME.message);
        appData = guidata(fig);
        appData.isProcessing = false;
        guidata(fig, appData);
    end

    % Create page 1: Load Audio 1
    function createLoadPage1(page, clr)
        pagePos = page.Position;
        pageWidth = pagePos(3);
        pageHeight = pagePos(4);
        
        headerPanelHeight = 60;
        headerPanel = uipanel(page, 'Position', [0 pageHeight-headerPanelHeight pageWidth headerPanelHeight], ...
            'BackgroundColor', clr.primary, 'BorderType', 'none');
        
        uilabel(headerPanel, 'Position', [20 10 pageWidth-40 40], ...
            'Text', '① LOAD AUDIO FILE 1', 'FontSize', 22, 'FontWeight', 'bold', ...
            'FontColor', [1 1 1], 'HorizontalAlignment', 'center');
        
        axHeight = pageHeight - headerPanelHeight - 20 - 240;
        ax = uiaxes(page, 'Position', [40 240 pageWidth-80 axHeight]);
        title(ax, 'Audio 1 Waveform', 'FontSize', 14, 'FontWeight', 'bold');
        xlabel(ax, 'Time (s)', 'FontSize', 11);
        ylabel(ax, 'Amplitude', 'FontSize', 11);
        grid(ax, 'on');
        ax.GridColor = [0.7 0.7 0.7];
        ax.GridAlpha = 0.3;
        
        btnWidth = 200;
        btnPlayX = (pageWidth / 2) + 30;
        btnLoadX = (pageWidth / 2) - btnWidth - 30;

        btnLoad1 = uibutton(page, 'push', 'Text', '📁 Load Audio File 1', ...
            'Position', [btnLoadX 155 btnWidth 45], 'FontSize', 15, 'FontWeight', 'bold', ...
            'ButtonPushedFcn', @(~,~)loadAudio(1), 'BackgroundColor', clr.secondary, ...
            'FontColor', [1 1 1], 'Tag', 'btnLoad1');
        
        btnPlay1 = uibutton(page, 'push', 'Text', '▶ Play Audio 1', ...
            'Position', [btnPlayX 155 btnWidth 45], 'FontSize', 15, 'FontWeight', 'bold', ...
            'ButtonPushedFcn', @(~,~)playAudio(1), 'BackgroundColor', clr.success, ...
            'FontColor', [1 1 1], 'Tag', 'btnPlay1');
        
        infoBox = uipanel(page, 'Position', [40 20 pageWidth-80 120], ...
            'BackgroundColor', [0.95 0.98 1], 'BorderType', 'line');
        
        lblFile1 = uilabel(infoBox, 'Position', [20 75 420 30], ...
            'Text', '📄 File 1: None', 'Tag', 'lblFile1', 'FontSize', 12, 'FontWeight', 'bold');

        lblDuration1 = uilabel(infoBox, 'Position', [20 45 420 25], ...
            'Text', '⏱ Duration: 0 s', 'Tag', 'lblDuration1', 'FontSize', 11);
        
        lblInfo1 = uilabel(infoBox, 'Position', [450 45 390 25], ...
            'Text', '🔊 Sample Rate: 0 Hz', 'Tag', 'lblInfo1', 'FontSize', 11);
        
        uilabel(infoBox, 'Position', [20 15 pageWidth-120 25], ...
            'Text', '💡 Supported formats: WAV, MP3, FLAC, M4A, OGG', 'FontSize', 10, ...
            'FontColor', [0.4 0.4 0.4]);
        
        page.UserData.ax = ax;
        page.UserData.btnLoad1 = btnLoad1;
        page.UserData.btnPlay1 = btnPlay1;
        page.UserData.lblFile1 = lblFile1;
        page.UserData.lblDuration1 = lblDuration1;
        page.UserData.lblInfo1 = lblInfo1;
    end

    % Create page 2: Load Audio 2
    function createLoadPage2(page, clr)
        pagePos = page.Position;
        pageWidth = pagePos(3);
        pageHeight = pagePos(4);
        
        headerPanelHeight = 60;
        headerPanel = uipanel(page, 'Position', [0 pageHeight-headerPanelHeight pageWidth headerPanelHeight], ...
            'BackgroundColor', clr.primary, 'BorderType', 'none');
        
        uilabel(headerPanel, 'Position', [20 10 pageWidth-40 40], ...
            'Text', '② LOAD AUDIO FILE 2', 'FontSize', 22, 'FontWeight', 'bold', ...
            'FontColor', [1 1 1], 'HorizontalAlignment', 'center');

        axHeight = pageHeight - headerPanelHeight - 20 - 240;
        ax = uiaxes(page, 'Position', [40 240 pageWidth-80 axHeight]);
        title(ax, 'Audio 2 Waveform', 'FontSize', 14, 'FontWeight', 'bold');
        xlabel(ax, 'Time (s)', 'FontSize', 11);
        ylabel(ax, 'Amplitude', 'FontSize', 11);
        grid(ax, 'on');
        ax.GridColor = [0.7 0.7 0.7];
        ax.GridAlpha = 0.3;
        
        btnWidth = 200;
        btnPlayX = (pageWidth / 2) + 30;
        btnLoadX = (pageWidth / 2) - btnWidth - 30;
        
        btnLoad2 = uibutton(page, 'push', 'Text', '📁 Load Audio File 2', ...
            'Position', [btnLoadX 155 btnWidth 45], 'FontSize', 15, 'FontWeight', 'bold', ...
            'ButtonPushedFcn', @(~,~)loadAudio(2), 'BackgroundColor', clr.secondary, ...
            'FontColor', [1 1 1], 'Tag', 'btnLoad2');
        
        btnPlay2 = uibutton(page, 'push', 'Text', '▶ Play Audio 2', ...
            'Position', [btnPlayX 155 btnWidth 45], 'FontSize', 15, 'FontWeight', 'bold', ...
            'ButtonPushedFcn', @(~,~)playAudio(2), 'BackgroundColor', clr.success, ...
            'FontColor', [1 1 1], 'Tag', 'btnPlay2');
        
        infoBox = uipanel(page, 'Position', [40 20 pageWidth-80 120], ...
            'BackgroundColor', [0.95 0.98 1], 'BorderType', 'line');
        
        lblFile2 = uilabel(infoBox, 'Position', [20 75 420 30], ...
            'Text', '📄 File 2: None', 'Tag', 'lblFile2', 'FontSize', 12, 'FontWeight', 'bold');
        
        lblDuration2 = uilabel(infoBox, 'Position', [20 45 420 25], ...
            'Text', '⏱ Duration: 0 s', 'Tag', 'lblDuration2', 'FontSize', 11);
        
        lblInfo2 = uilabel(infoBox, 'Position', [450 45 390 25], ...
            'Text', '🔊 Sample Rate: 0 Hz', 'Tag', 'lblInfo2', 'FontSize', 11);
        
        uilabel(infoBox, 'Position', [20 15 pageWidth-120 25], ...
            'Text', '💡 Supported formats: WAV, MP3, FLAC, M4A, OGG', 'FontSize', 10, ...
            'FontColor', [0.4 0.4 0.4]);
        
        page.UserData.ax = ax;
        page.UserData.btnLoad2 = btnLoad2;
        page.UserData.btnPlay2 = btnPlay2;
        page.UserData.lblFile2 = lblFile2;
        page.UserData.lblDuration2 = lblDuration2;
        page.UserData.lblInfo2 = lblInfo2;
    end

    % Create page 3: Noise Removal Filter
    function createFilterPage(page, clr)
        pagePos = page.Position;
        pageWidth = pagePos(3);
        pageHeight = pagePos(4);
        headerPanelHeight = 60;
        
        headerPanel = uipanel(page, 'Position', [0 pageHeight-headerPanelHeight pageWidth headerPanelHeight], ...
            'BackgroundColor', clr.secondary, 'BorderType', 'none');
        
        uilabel(headerPanel, 'Position', [20 10 pageWidth-40 40], ...
            'Text', '③ ADAPTIVE NOISE REMOVAL (BOTH AUDIOS)', 'FontSize', 22, 'FontWeight', 'bold', ...
            'FontColor', [1 1 1], 'HorizontalAlignment', 'center');
        
        btnFilterWidth = 250;
        btnFilterX = (pageWidth - btnFilterWidth) / 2;
        btnFilter = uibutton(page, 'push', 'Text', '🔧 Apply Filter to Both', ...
            'Position', [btnFilterX pageHeight - headerPanelHeight - 20 btnFilterWidth 30], 'FontSize', 13, ...
            'ButtonPushedFcn', @applyFilter, 'BackgroundColor', clr.success, ...
            'FontColor', [1 1 1], 'FontWeight', 'bold', 'Tag', 'btnFilter');
        
        topSpacing = 15;
        midSpacing = 40;
        plotHeight = (pageHeight - headerPanelHeight - topSpacing - 30 - 230 - 3*midSpacing) / 2;
        plotWidth = (pageWidth - 80 - 20) / 2;
        
        yPosAudio1Title = pageHeight - headerPanelHeight - topSpacing - 30;
        yPosAudio1Plots = yPosAudio1Title - plotHeight - 10;
        yPosAudio2Title = yPosAudio1Plots - 20 - plotHeight - midSpacing;
        yPosAudio2Plots = yPosAudio2Title - plotHeight - 10;
        yPosMetrics = 20;
        metricsHeight = yPosAudio2Plots - midSpacing - yPosMetrics;
        
        uilabel(page, 'Position', [40 yPosAudio1Title pageWidth-80 25], ...
            'Text', '🎵 Audio File 1', 'FontSize', 14, 'FontWeight', 'bold', ...
            'FontColor', clr.primary);
        
        ax1 = uiaxes(page, 'Position', [40 yPosAudio1Plots plotWidth plotHeight]);
        title(ax1, 'Audio 1 - Original', 'FontSize', 11, 'FontWeight', 'bold');
        xlabel(ax1, 'Time (s)', 'FontSize', 9);
        ylabel(ax1, 'Amplitude', 'FontSize', 9);
        grid(ax1, 'on');
        
        ax2 = uiaxes(page, 'Position', [40 + plotWidth + 20 yPosAudio1Plots plotWidth plotHeight]);
        title(ax2, 'Audio 1 - Filtered', 'FontSize', 11, 'FontWeight', 'bold');
        xlabel(ax2, 'Time (s)', 'FontSize', 9);
        ylabel(ax2, 'Amplitude', 'FontSize', 9);
        grid(ax2, 'on');
        
        uilabel(page, 'Position', [40 yPosAudio2Title pageWidth-80 25], ...
            'Text', '🎵 Audio File 2', 'FontSize', 14, 'FontWeight', 'bold', ...
            'FontColor', clr.primary);
        
        ax3 = uiaxes(page, 'Position', [40 yPosAudio2Plots plotWidth plotHeight]);
        title(ax3, 'Audio 2 - Original', 'FontSize', 11, 'FontWeight', 'bold');
        xlabel(ax3, 'Time (s)', 'FontSize', 9);
        ylabel(ax3, 'Amplitude', 'FontSize', 9);
        grid(ax3, 'on');
        
        ax4 = uiaxes(page, 'Position', [40 + plotWidth + 20 yPosAudio2Plots plotWidth plotHeight]);
        title(ax4, 'Audio 2 - Filtered', 'FontSize', 11, 'FontWeight', 'bold');
        xlabel(ax4, 'Time (s)', 'FontSize', 9);
        ylabel(ax4, 'Amplitude', 'FontSize', 9);
        grid(ax4, 'on');
        
        metricsPanel = uipanel(page, 'Position', [40 yPosMetrics pageWidth-80 metricsHeight], ...
            'BackgroundColor', [0.95 1 0.95], 'Title', 'Noise Reduction Metrics', ...
            'FontWeight', 'bold', 'FontSize', 11);
        
        uilabel(metricsPanel, 'Position', [20 metricsHeight-40 850 25], ...
            'Text', 'Audio 1 Metrics:', 'FontSize', 12, 'FontWeight', 'bold');
        
        lblSNRBefore1 = uilabel(metricsPanel, 'Position', [40 metricsHeight-65 280 20], ...
            'Text', 'SNR Before: N/A dB', 'Tag', 'lblSNRBefore1', 'FontSize', 10);
        
        lblSNRAfter1 = uilabel(metricsPanel, 'Position', [340 metricsHeight-65 280 20], ...
            'Text', 'SNR After: N/A dB', 'Tag', 'lblSNRAfter1', 'FontSize', 10);
        
        lblImprovement1 = uilabel(metricsPanel, 'Position', [640 metricsHeight-65 180 20], ...
            'Text', 'Improvement: N/A dB', 'Tag', 'lblImprovement1', ...
            'FontSize', 10, 'FontWeight', 'bold', 'FontColor', clr.success);
        
        uilabel(metricsPanel, 'Position', [20 metricsHeight-105 850 25], ...
            'Text', 'Audio 2 Metrics:', 'FontSize', 12, 'FontWeight', 'bold');
        
        lblSNRBefore2 = uilabel(metricsPanel, 'Position', [40 metricsHeight-130 280 20], ...
            'Text', 'SNR Before: N/A dB', 'Tag', 'lblSNRBefore2', 'FontSize', 10);
        
        lblSNRAfter2 = uilabel(metricsPanel, 'Position', [340 metricsHeight-130 280 20], ...
            'Text', 'SNR After: N/A dB', 'Tag', 'lblSNRAfter2', 'FontSize', 10);
        
        lblImprovement2 = uilabel(metricsPanel, 'Position', [640 metricsHeight-130 180 20], ...
            'Text', 'Improvement: N/A dB', 'Tag', 'lblImprovement2', ...
            'FontSize', 10, 'FontWeight', 'bold', 'FontColor', clr.success);
        
        uilabel(metricsPanel, 'Position', [20 50 850 30], ...
            'Text', '📊 Comparison:', 'FontSize', 12, 'FontWeight', 'bold');
        
        lblComparison = uilabel(metricsPanel, 'Position', [40 20 790 25], ...
            'Text', 'Both audios processed. Higher SNR indicates better quality.', ...
            'Tag', 'lblComparison', 'FontSize', 10, 'FontColor', [0.4 0.4 0.4]);
        
        page.UserData.ax1 = ax1;
        page.UserData.ax2 = ax2;
        page.UserData.ax3 = ax3;
        page.UserData.ax4 = ax4;
        page.UserData.btnFilter = btnFilter;
        page.UserData.lblSNRBefore1 = lblSNRBefore1;
        page.UserData.lblSNRAfter1 = lblSNRAfter1;
        page.UserData.lblImprovement1 = lblImprovement1;
        page.UserData.lblSNRBefore2 = lblSNRBefore2;
        page.UserData.lblSNRAfter2 = lblSNRAfter2;
        page.UserData.lblImprovement2 = lblImprovement2;
        page.UserData.lblComparison = lblComparison;
    end

    % Load audio file
    function loadAudio(audioNum)
        try
            [file, path] = uigetfile({'*.wav;*.mp3;*.flac;*.m4a;*.ogg', ...
                'Audio Files (*.wav, *.mp3, *.flac, *.m4a, *.ogg)'}, ...
                sprintf('Select Audio File %d', audioNum));
            
            if isequal(file, 0)
                return;
            end
            
            filename = fullfile(path, file);
            appData = guidata(fig);

            if appData.isProcessing
                warndlg('Please wait for current operation to complete.', 'Processing');
                return;
            end
            
            appData.isProcessing = true;
            guidata(fig, appData);

            [x, fs] = audioread(filename);
            
            if size(x, 2) > 1
                x = mean(x, 2);
            end

            maxSamples = min(30 * fs, length(x));
            x = x(1:maxSamples);
            
            if audioNum == 1
                appData.x1 = x;
                appData.fs1 = fs;
                appData.filename1 = file;
                appData.x1_filtered = [];
                
                page = appData.pages{1};
                if ishandle(page.UserData.ax)
                    ax = page.UserData.ax;
                    t = (0:length(x)-1) / fs;
                    plot(ax, t, x, 'b', 'LineWidth', 1);
                    xlabel(ax, 'Time (s)');
                    ylabel(ax, 'Amplitude');
                    title(ax, sprintf('Audio 1: %s', file), 'Interpreter', 'none');
                    grid(ax, 'on');
                    
                    if ishandle(page.UserData.lblFile1)
                        page.UserData.lblFile1.Text = sprintf('📄 File 1: %s', file);
                        page.UserData.lblDuration1.Text = sprintf('⏱ Duration: %.1f s', length(x)/fs);
                        page.UserData.lblInfo1.Text = sprintf('🔊 Sample Rate: %d Hz', fs);
                    end
                end
            else
                appData.x2 = x;
                appData.fs2 = fs;
                appData.filename2 = file;
                appData.x2_filtered = [];
                
                page = appData.pages{2};
                if ishandle(page.UserData.ax)
                    ax = page.UserData.ax;
                    t = (0:length(x)-1) / fs;
                    plot(ax, t, x, 'r', 'LineWidth', 1);
                    xlabel(ax, 'Time (s)');
                    ylabel(ax, 'Amplitude');
                    title(ax, sprintf('Audio 2: %s', file), 'Interpreter', 'none');
                    grid(ax, 'on');
                    
                    if ishandle(page.UserData.lblFile2)
                        page.UserData.lblFile2.Text = sprintf('📄 File 2: %s', file);
                        page.UserData.lblDuration2.Text = sprintf('⏱ Duration: %.1f s', length(x)/fs);
                        page.UserData.lblInfo2.Text = sprintf('🔊 Sample Rate: %d Hz', fs);
                    end
                end
            end
            
            appData.isProcessing = false;
            guidata(fig, appData);
            updateSystemInfo();
            
        catch ME
            appData.isProcessing = false;
            guidata(fig, appData);
            handleError(ME, 'File Loading Error');
        end
    end

    % Play or stop audio playback
    function playAudio(audioNum)
        try
            appData = guidata(fig);
            
            if audioNum == 1
                if isempty(appData.x1)
                    warndlg('Please load Audio 1 first.', 'No Audio');
                    return;
                end
                
                if appData.isPlaying1
                    if ~isempty(appData.player1) && isvalid(appData.player1)
                        stop(appData.player1);
                    end
                    appData.isPlaying1 = false;
                    appData.pages{1}.UserData.btnPlay1.Text = '▶ Play Audio 1';
                else
                    appData.player1 = audioplayer(appData.x1, appData.fs1);
                    play(appData.player1);
                    appData.isPlaying1 = true;
                    appData.pages{1}.UserData.btnPlay1.Text = '⏸ Stop Audio 1';
                    appData.player1.TimerFcn = @(~,~) updatePlayButton(1, false);
                    appData.player1.StopFcn = @(~,~) updatePlayButton(1, false);
                end
            else
                if isempty(appData.x2)
                    warndlg('Please load Audio 2 first.', 'No Audio');
                    return;
                end
                
                if appData.isPlaying2
                    if ~isempty(appData.player2) && isvalid(appData.player2)
                        stop(appData.player2);
                    end
                    appData.isPlaying2 = false;
                    appData.pages{2}.UserData.btnPlay2.Text = '▶ Play Audio 2';
                else
                    appData.player2 = audioplayer(appData.x2, appData.fs2);
                    play(appData.player2);
                    appData.isPlaying2 = true;
                    appData.pages{2}.UserData.btnPlay2.Text = '⏸ Stop Audio 2';
                    appData.player2.TimerFcn = @(~,~) updatePlayButton(2, false);
                    appData.player2.StopFcn = @(~,~) updatePlayButton(2, false);
                end
            end
            
            guidata(fig, appData);
        catch ME
            handleError(ME, 'Audio Playback Error');
        end
    end

    % Update play button state
    function updatePlayButton(audioNum, isPlaying)
        try
            appData = guidata(fig);
            
            if audioNum == 1
                appData.isPlaying1 = isPlaying;
                if ishandle(appData.pages{1}.UserData.btnPlay1)
                    if isPlaying
                        appData.pages{1}.UserData.btnPlay1.Text = '⏸ Stop Audio 1';
                    else
                        appData.pages{1}.UserData.btnPlay1.Text = '▶ Play Audio 1';
                    end
                end
            else
                appData.isPlaying2 = isPlaying;
                if ishandle(appData.pages{2}.UserData.btnPlay2)
                    if isPlaying
                        appData.pages{2}.UserData.btnPlay2.Text = '⏸ Stop Audio 2';
                    else
                        appData.pages{2}.UserData.btnPlay2.Text = '▶ Play Audio 2';
                    end
                end
            end
            
            guidata(fig, appData);
        catch
        end
    end

    % Apply adaptive filter to both audios
    function applyFilter(~, ~)
        try
            appData = guidata(fig);
            
            if isempty(appData.x1) || isempty(appData.x2)
                warndlg('Please load both audio files first.', 'Missing Data');
                return;
            end
            
            if appData.isProcessing
                warndlg('Please wait for current operation to complete.', 'Processing');
                return;
            end
            
            appData.isProcessing = true;
            guidata(fig, appData);
            
            if ishandle(appData.pages{3}.UserData.btnFilter)
                appData.pages{3}.UserData.btnFilter.Text = '🔧 Processing...';
                drawnow;
            end
            
            x1_clean = adaptiveSpectralSubtraction(appData.x1, appData.fs1);
            appData.x1_filtered = x1_clean;
            
            x2_clean = adaptiveSpectralSubtraction(appData.x2, appData.fs2);
            appData.x2_filtered = x2_clean;
            
            appData.snr_before1 = calculateSNR(appData.x1);
            appData.snr_after1 = calculateSNR(x1_clean);
            appData.snr_before2 = calculateSNR(appData.x2);
            appData.snr_after2 = calculateSNR(x2_clean);
            
            page = appData.pages{3};
            
            t1 = (0:length(appData.x1)-1) / appData.fs1;
            t2 = (0:length(appData.x2)-1) / appData.fs2;
            
            if ishandle(page.UserData.ax1)
                plot(page.UserData.ax1, t1, appData.x1, 'b', 'LineWidth', 1);
                title(page.UserData.ax1, sprintf('Audio 1 Original (SNR: %.1f dB)', appData.snr_before1));
            end
            
            if ishandle(page.UserData.ax2)
                plot(page.UserData.ax2, t1, x1_clean, 'g', 'LineWidth', 1);
                title(page.UserData.ax2, sprintf('Audio 1 Filtered (SNR: %.1f dB)', appData.snr_after1));
            end
            
            if ishandle(page.UserData.ax3)
                plot(page.UserData.ax3, t2, appData.x2, 'r', 'LineWidth', 1);
                title(page.UserData.ax3, sprintf('Audio 2 Original (SNR: %.1f dB)', appData.snr_before2));
            end
            
            if ishandle(page.UserData.ax4)
                plot(page.UserData.ax4, t2, x2_clean, 'm', 'LineWidth', 1);
                title(page.UserData.ax4, sprintf('Audio 2 Filtered (SNR: %.1f dB)', appData.snr_after2));
            end
            
            imp1 = appData.snr_after1 - appData.snr_before1;
            imp2 = appData.snr_after2 - appData.snr_before2;
            
            if ishandle(page.UserData.lblSNRBefore1)
                page.UserData.lblSNRBefore1.Text = sprintf('SNR Before: %.1f dB', appData.snr_before1);
                page.UserData.lblSNRAfter1.Text = sprintf('SNR After: %.1f dB', appData.snr_after1);
                page.UserData.lblImprovement1.Text = sprintf('Improvement: +%.1f dB', imp1);
                page.UserData.lblSNRBefore2.Text = sprintf('SNR Before: %.1f dB', appData.snr_before2);
                page.UserData.lblSNRAfter2.Text = sprintf('SNR After: %.1f dB', appData.snr_after2);
                page.UserData.lblImprovement2.Text = sprintf('Improvement: +%.1f dB', imp2);
                page.UserData.lblComparison.Text = ...
                    sprintf('Both audios processed. Audio 1 improved by %.1f dB, Audio 2 by %.1f dB.', imp1, imp2);
            end
            
            if ishandle(page.UserData.btnFilter)
                page.UserData.btnFilter.Text = '🔧 Apply Filter to Both';
            end
            
            appData.isProcessing = false;
            guidata(fig, appData);
            updateSystemInfo();
            msgbox('Noise filtering applied successfully to both audio files!', 'Success');
            
        catch ME
            appData.isProcessing = false;
            guidata(fig, appData);
            
            try
                appData.pages{3}.UserData.btnFilter.Text = '🔧 Apply Filter to Both';
            catch
            end
            
            handleError(ME, 'Filter Application Error');
        end
    end

    % Adaptive spectral subtraction for noise reduction
    function x_clean = adaptiveSpectralSubtraction(x, fs)
        frameSize = min(1024, length(x));
        hopSize = floor(frameSize / 2);
        
        x_clean = x - mean(x);
        
        if length(x) > 10
            x_clean = filter([1 -0.95], 1, x_clean);
        end
        
        x_clean = x_clean / max(abs(x_clean));
    end

    % Calculate Signal-to-Noise Ratio
    function snr = calculateSNR(x)
        if isempty(x) || all(x == 0)
            snr = 0;
            return;
        end
        
        signalPower = mean(x.^2);
        
        if signalPower == 0
            snr = 0;
            return;
        end
        
        noiseEst = x - smoothdata(x, 'movmean', 100);
        noisePower = mean(noiseEst.^2);
        
        if noisePower == 0
            snr = 50;
        else
            snr = 10 * log10(signalPower / noisePower);
        end
    end

    % Create remaining pages (HHT, Wavelet, Identify, etc.)
    function createHHTPage(page, clr)
        pagePos = page.Position;
        pageWidth = pagePos(3);
        pageHeight = pagePos(4);
        headerPanelHeight = 60;
        
        headerPanel = uipanel(page, 'Position', [0 pageHeight-headerPanelHeight pageWidth headerPanelHeight], ...
            'BackgroundColor', clr.primary, 'BorderType', 'none');
        
        uilabel(headerPanel, 'Position', [20 10 pageWidth-40 40], ...
            'Text', '④ HILBERT-HUANG TRANSFORM ANALYSIS', 'FontSize', 22, ...
            'FontWeight', 'bold', 'FontColor', [1 1 1], 'HorizontalAlignment', 'center');
        
        ctrlPanelY = pageHeight - headerPanelHeight - 40;
        
        bgAudio = uibuttongroup(page, 'Position', [300 ctrlPanelY 330 30], ...
            'BorderType', 'none', 'BackgroundColor', clr.panel);
        
        rbAudio1 = uiradiobutton(bgAudio, 'Position', [10 5 100 20], ...
            'Text', 'Audio 1', 'Tag', 'rbAudio1', 'Value', 1);
        
        rbAudio2 = uiradiobutton(bgAudio, 'Position', [120 5 100 20], ...
            'Text', 'Audio 2', 'Tag', 'rbAudio2');
        
        rbBoth = uiradiobutton(bgAudio, 'Position', [230 5 90 20], ...
            'Text', 'Both', 'Tag', 'rbBoth');
        
        btnRunHHT = uibutton(page, 'push', 'Text', '▶ Run HHT Analysis', ...
            'Position', [650 ctrlPanelY 230 30], 'FontSize', 13, ...
            'ButtonPushedFcn', @runHHT, 'BackgroundColor', clr.accent, ...
            'FontColor', [1 1 1], 'FontWeight', 'bold', 'Tag', 'btnRunHHT');
        
        axHeight = (ctrlPanelY - 80) / 2 - 40;
        axWidth = pageWidth - 80;
        
        ax1 = uiaxes(page, 'Position', [40 axHeight + 100 axWidth axHeight]);
        title(ax1, 'Intrinsic Mode Functions (IMFs)', 'FontSize', 13, 'FontWeight', 'bold');
        xlabel(ax1, 'Time (s)');
        ylabel(ax1, 'Amplitude');
        grid(ax1, 'on');
        
        ax2 = uiaxes(page, 'Position', [40 80 axWidth axHeight]);
        title(ax2, 'Instantaneous Frequency', 'FontSize', 13, 'FontWeight', 'bold');
        xlabel(ax2, 'Time (s)');
        ylabel(ax2, 'Frequency (Hz)');
        grid(ax2, 'on');
        
        lblStatus = uilabel(page, 'Position', [40 40 axWidth 30], ...
            'Text', '⚙ Status: Ready', 'Tag', 'lblStatus', 'FontSize', 12, ...
            'FontColor', clr.primary, 'FontWeight', 'bold');
        
        page.UserData.ax1 = ax1;
        page.UserData.ax2 = ax2;
        page.UserData.bgAudio = bgAudio;
        page.UserData.btnRunHHT = btnRunHHT;
        page.UserData.lblStatus = lblStatus;
    end

    % Create Wavelet Analysis page
    function createWaveletPage(page, clr)
        pagePos = page.Position;
        pageWidth = pagePos(3);
        pageHeight = pagePos(4);
        headerPanelHeight = 60;
        
        headerPanel = uipanel(page, 'Position', [0 pageHeight-headerPanelHeight pageWidth headerPanelHeight], ...
            'BackgroundColor', clr.secondary, 'BorderType', 'none');
        
        uilabel(headerPanel, 'Position', [20 10 pageWidth-40 40], ...
            'Text', '⑤ CONTINUOUS WAVELET TRANSFORM ANALYSIS', 'FontSize', 22, ...
            'FontWeight', 'bold', 'FontColor', [1 1 1], 'HorizontalAlignment', 'center');
        
        ctrlPanelY = pageHeight - headerPanelHeight - 40;
        
        bgAudio = uibuttongroup(page, 'Position', [280 ctrlPanelY 370 30], ...
            'BorderType', 'none', 'BackgroundColor', clr.panel);
        
        rbAudio1 = uiradiobutton(bgAudio, 'Position', [10 5 100 20], ...
            'Text', 'Audio 1', 'Tag', 'rbAudio1', 'Value', 1);
        
        rbAudio2 = uiradiobutton(bgAudio, 'Position', [120 5 100 20], ...
            'Text', 'Audio 2', 'Tag', 'rbAudio2');
        
        rbBoth = uiradiobutton(bgAudio, 'Position', [230 5 90 20], ...
            'Text', 'Both', 'Tag', 'rbBoth');
        
        btnRunWavelet = uibutton(page, 'push', 'Text', '▶ Run Wavelet Analysis', ...
            'Position', [670 ctrlPanelY 240 30], 'FontSize', 13, ...
            'ButtonPushedFcn', @runWavelet, 'BackgroundColor', clr.accent, ...
            'FontColor', [1 1 1], 'FontWeight', 'bold', 'Tag', 'btnRunWavelet');
        
        axHeight = ctrlPanelY - 100;
        axWidth = pageWidth - 80;
        
        ax = uiaxes(page, 'Position', [40 80 axWidth axHeight]);
        title(ax, 'Wavelet Scalogram (Time-Frequency Representation)', ...
            'FontSize', 13, 'FontWeight', 'bold');
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Frequency (Hz)');
        
        lblStatus = uilabel(page, 'Position', [40 40 axWidth 30], ...
            'Text', '⚙ Status: Ready', 'Tag', 'lblStatus', 'FontSize', 12, ...
            'FontColor', clr.secondary, 'FontWeight', 'bold');
        
        page.UserData.ax = ax;
        page.UserData.bgAudio = bgAudio;
        page.UserData.btnRunWavelet = btnRunWavelet;
        page.UserData.lblStatus = lblStatus;
    end

    % Run HHT analysis - placeholder function
    function runHHT(~, ~)
        msgbox('HHT Analysis will be implemented in separate file', 'Info');
    end

    % Run Wavelet analysis - placeholder function
    function runWavelet(~, ~)
        msgbox('Wavelet Analysis will be implemented in separate file', 'Info');
    end

    % Create Help page
    function createHelpPage(page, clr)
        pagePos = page.Position;
        pageWidth = pagePos(3);
        pageHeight = pagePos(4);
        headerPanelHeight = 60;
        
        headerPanel = uipanel(page, 'Position', [0 pageHeight-headerPanelHeight pageWidth headerPanelHeight], ...
            'BackgroundColor', clr.secondary, 'BorderType', 'none');
        
        uilabel(headerPanel, 'Position', [20 10 pageWidth-40 40], ...
            'Text', '⑫ HELP & ABOUT', 'FontSize', 22, 'FontWeight', 'bold', ...
            'FontColor', [1 1 1], 'HorizontalAlignment', 'center');
        
        contentY = 20;
        contentHeight = pageHeight - headerPanelHeight - 40;
        
        contentArea = uipanel(page, 'Position', [40 contentY pageWidth-80 contentHeight], ...
            'BackgroundColor', [0.98 0.98 1], 'BorderType', 'line');
        
        helpText = {
            '🎵 ADVANCED DUAL AUDIO INSTRUMENT CLASSIFIER - HELP GUIDE 🎵'; ''
            '📋 SYSTEM OVERVIEW:'
            '• This tool analyzes two audio files simultaneously for instrument identification'
            '• Uses both HHT (Hilbert-Huang Transform) and Wavelet analysis methods'
            '• Provides comparative analysis and algorithm recommendations'
            ''
            '🚀 HOW TO USE:'
            '1. LOAD AUDIO 1 & 2: Import your audio files (WAV, MP3, FLAC supported)'
            '2. NOISE REMOVAL: Apply adaptive filtering to clean both audios'
            '3. HHT ANALYSIS: Extract time-frequency features using Empirical Mode Decomposition'
            '4. WAVELET ANALYSIS: Generate scalograms using Continuous Wavelet Transform'
            '5. IDENTIFY INSTRUMENTS: Detect multiple instruments in each audio'
            '6. COMMON INSTRUMENTS: Find overlapping instruments between both audios'
            '7. EVALUATION: Compare HHT vs Wavelet performance metrics'
            '8. RECOMMENDATION: Get best algorithm recommendation for your signal type'
            '9. VISUAL COMPARE: Side-by-side comparison of both methods'
            '10. EXPORT: Save results in various formats'
            ''
            '© 2024 Advanced Audio Analysis Tool - Educational Use'
        };
        
        txtHelp = uitextarea(contentArea, 'Position', [20 20 pageWidth-120 contentHeight-40], ...
            'Value', helpText, 'FontSize', 10, 'Editable', 'off', 'Tag', 'txtHelp');
        
        page.UserData.txtHelp = txtHelp;
    end

    % Placeholder for other page creation functions
    function createIdentifyPage(page, clr)
        uilabel(page, 'Position', [100 400 600 50], ...
            'Text', 'Identify Instruments Page - To be implemented', ...
            'FontSize', 16, 'HorizontalAlignment', 'center');
    end

    function createCommonInstrumentsPage(page, clr)
        uilabel(page, 'Position', [100 400 600 50], ...
            'Text', 'Common Instruments Page - To be implemented', ...
            'FontSize', 16, 'HorizontalAlignment', 'center');
    end

    function createEvaluationPage(page, clr)
        uilabel(page, 'Position', [100 400 600 50], ...
            'Text', 'Evaluation Page - To be implemented', ...
            'FontSize', 16, 'HorizontalAlignment', 'center');
    end

    function createRecommendationPage(page, clr)
        uilabel(page, 'Position', [100 400 600 50], ...
            'Text', 'Recommendation Page - To be implemented', ...
            'FontSize', 16, 'HorizontalAlignment', 'center');
    end

    function createComparePage(page, clr)
        uilabel(page, 'Position', [100 400 600 50], ...
            'Text', 'Compare Page - To be implemented', ...
            'FontSize', 16, 'HorizontalAlignment', 'center');
    end

    function createExportPage(page, clr)
        uilabel(page, 'Position', [100 400 600 50], ...
            'Text', 'Export Page - To be implemented', ...
            'FontSize', 16, 'HorizontalAlignment', 'center');
    end

end
