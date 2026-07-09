# Real-Time Video Processing Pipeline — FPGA Final Year Project

A hardware-only image-processing pipeline built for a Basys3 (Artix-7) FPGA that captures camera input, buffers frames in dual-port BRAM, applies eight real-time filters, and drives a VGA display without software intervention.

## Project Statement

This repository implements a complete FPGA-based pipeline for acquiring live camera data (OV7670), transforming the pixel stream through a set of eight hardware filters, and presenting the processed image on a standard VGA monitor. The design emphasises clear signal flow, timing discipline, and reproducible visual results suitable for a final-year project demonstration.

<img width="2560" height="1280" alt="Major Project Swaroop" src="https://github.com/user-attachments/assets/c3e5aa25-7309-4d8b-9a19-e50736574ad1" />

## Features

- Acquisition: OV7670 configuration and RGB565 capture through the camera interface.
- Processing: Eight real-time, combinational filters applied directly in hardware.
- Display: VGA output (640×480) with stable timing and on-screen frame delivery.
- Memory: Dual-port BRAM separates capture and display domains for reliable frame buffering.

## Methodology (Hardware Flow)

1. Camera setup — Configure the OV7670 via SCCB for a stable, synchronous pixel stream.
2. Pixel capture — Sample RGB565 data and convert to an internal format for processing.
3. Frame buffering — Store frames in dual-port BRAM to decouple read/write domains.
4. Filter bank — Evaluate eight distinct combinational filters on the live pixel stream.
5. VGA output — Route the selected result to a 640×480 display with consistent timing.

## System Architecture

Key components:

- Camera interface: Sensor communication, clocking, and synchronized sample capture.
- Memory subsystem: Dual-port BRAM for separate capture and display activity.
- Filter stage: Eight hardware filters producing distinct visual transformations.
- VGA generation: Display controller that converts processed frames into a stable analog-style VGA stream.

## Results

- Measured frame rate: 30–32 FPS
- LUT usage: ~1.37%
- Approx. board power draw: 0.193 W
- VGA timing domain: 25 MHz

Photographs and demonstration videos showing the filter outputs are included under the `RESULTS/` folder in the repository.

## Artifacts in this repository

- `v1/`, `v2/`, `v3/` — Project versions and build artifacts (bitstreams, TCL scripts, Vivado project templates). See the README files inside `v2/` and `v3/` for version-specific notes.
- `RESULTS/` — Example images and videos demonstrating filter outputs and recorded demos.
- `src/` — Source HDL, scripts and project source (refer to the repository tree for the exact locations used to build the designs).

## Authors & Supervision

- Prepared by: Swaroop Kumar Yadav, B.Tech ECE (2022–2026)
- Supervision: Dr. Yogendra Pratap Pundir, H.N.B. Garhwal University
<img width="2607" height="1467" alt="1783519517940" src="https://github.com/user-attachments/assets/91285f7d-5769-4a6b-8874-bab5143583de" />

## License & Usage

This repository is provided for reference and demonstration. Use Vivado to open the provided project files or to program bitstreams on your target board. See version folders for further instructions and project files.

