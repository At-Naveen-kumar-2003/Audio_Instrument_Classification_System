# 🎵 Advanced Dual Audio Instrument Classifier (MATLAB GUI)

This project provides a **full-featured MATLAB-based GUI application** for analyzing, processing, and identifying musical instruments from **two audio files simultaneously**.  
It uses advanced **signal processing techniques** including:

- **Hilbert–Huang Transform (HHT)**
- **Continuous Wavelet Transform (CWT)**
- **Adaptive Noise Removal**
- **Multi-Instrument Identification**
- **Visual & Algorithm Performance Comparison**
- **Automated Recommendation System**
- **Comprehensive Export & Reporting Tools**

The system is designed for **research, education, DSP learners, and audio analysis applications**.

---

## 📌 Features

### 🔹 1. Dual Audio Loading
- Load and preview two audio files (WAV, MP3, FLAC, M4A, OGG).
- Mono conversion for uniform processing.
- Signal visualization.

### 🔹 2. Adaptive Noise Removal
- Spectral subtraction–based filter.
- Before/after comparison panels.
- SNR improvement metrics for both signals.

### 🔹 3. Hilbert–Huang Transform (HHT)
- Empirical Mode Decomposition (IMFs)
- Instantaneous frequency extraction.
- Full time-frequency representation.

### 🔹 4. Continuous Wavelet Transform (CWT)
- High-resolution scalograms.
- Time-frequency insights for transient signals.

### 🔹 5. Instrument Identification
- Detects:
  - Strings (violin, cello, guitar, harp)
  - Woodwinds (flute, clarinet, saxophone)
  - Brass (trumpet, trombone)
  - Percussion (drums, piano, xylophone)
  - Voice and synthetic instruments
- Extracted features:
  - Spectral centroid  
  - Peak frequency  
  - Harmonic ratio  
  - Confidence estimation  
- Visual spectrum + result tables.

### 🔹 6. Common Instrument Matching
- Finds shared instruments between Audio 1 & Audio 2.
- Venn diagram visualization.
- Unique instrument lists.

### 🔹 7. Algorithm Evaluation
- Compares **HHT vs CWT** using:
  - Energy concentration  
  - Time-frequency resolution  
  - Processing time  
  - Robustness to noise  
- Table + graph-based comparisons.

### 🔹 8. Smart Algorithm Recommendation
- Automatically chooses the better method for your input audio.
- Provides reasoning and feature-based scoring.

### 🔹 9. Visual Method Comparison
- Side-by-side time-frequency visualization.
- Feature score comparison plot.

### 🔹 10. Data & Report Export
Export:
- Raw & filtered audio  
- HHT / Wavelet results  
- Instrument identification tables  
- Plots (PNG)  
- Metrics & recommendation  
- MAT, Excel, Text, Combined reports  

---

## 🛠 System Requirements

- **MATLAB R2022b or later**  
  (GUI optimized; earlier versions may have visual issues)
- Signal Processing Toolbox  
- Wavelet Toolbox  
- Audio Toolbox (optional but useful)

---



