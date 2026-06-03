# Digital Twin-Based Reinforcement Learning Control for REMUS 100 AUV

> Energy-Aware Autonomous Underwater Vehicle Control using Reinforcement Learning, Digital Twins, Physics-Based Sensor Modeling, and Real-Time Marine Environmental Data.

![MATLAB](https://img.shields.io/badge/MATLAB-R2024a-orange)
![Simulink](https://img.shields.io/badge/Simulink-Modeling-blue)
![Reinforcement Learning](https://img.shields.io/badge/Reinforcement-Learning-success)
![PPO](https://img.shields.io/badge/PPO-Continuous%20Control-red)
![Digital Twin](https://img.shields.io/badge/Digital-Twin-green)
![Research Project](https://img.shields.io/badge/Research-Marine%20Robotics-purple)

---

# Overview

Autonomous Underwater Vehicles (AUVs) are extensively used in oceanographic research, environmental monitoring, underwater inspection, defense applications, and offshore infrastructure maintenance. However, most conventional AUV control systems rely on fixed-parameter controllers such as PID, which often struggle in dynamic marine environments characterized by varying ocean currents, waves, turbulence, and changing environmental conditions.

This project presents a Digital Twin-Based Reinforcement Learning Framework for the REMUS 100 Autonomous Underwater Vehicle. The system combines high-fidelity simulation, marine environmental data, physics-based sensor modeling, and deep reinforcement learning to create an intelligent controller capable of energy-efficient navigation and adaptive decision-making.

Unlike traditional control systems, the proposed framework continuously learns how to:

- Exploit favorable ocean currents
- Minimize propulsion energy consumption
- Improve mission duration
- Maintain navigation accuracy
- Perform robust station keeping
- Adapt to changing environmental disturbances
- Improve sensing quality during exploration missions

The project was developed using MATLAB, Simulink, Reinforcement Learning Toolbox, and Digital Twin methodologies.

---

# Problem Statement

Current AUV control systems face several major challenges:

### Energy Constraints

AUVs operate using finite onboard battery resources. Traditional controllers frequently waste energy by fighting against environmental disturbances instead of utilizing them intelligently.

### Dynamic Ocean Conditions

Marine environments continuously change due to:

- Ocean Currents
- Waves
- Turbulence
- Temperature Variations
- Humidity Variations

Conventional controllers struggle to adapt to these changing conditions.

### Sim-to-Real Gap

Most reinforcement learning environments use simplified simulations that do not accurately model:

- Sensor Dynamics
- Environmental Disturbances
- Ocean Conditions
- Vehicle Hydrodynamics

This often leads to poor real-world performance.

### Multi-Objective Optimization

Modern AUV missions require simultaneous optimization of:

- Navigation Accuracy
- Energy Consumption
- Vehicle Stability
- Sensing Performance

Traditional approaches cannot effectively optimize all objectives simultaneously.

---

# Proposed Solution

The proposed solution integrates:

1. High-Fidelity Digital Twin
2. Real-Time Marine Environmental Data
3. Reinforcement Learning Controller
4. Physics-Based Sensor Models
5. Multi-Objective Reward Optimization

The resulting system learns an adaptive control policy capable of operating efficiently in dynamic marine environments.

---

# System Architecture

The system architecture combines simulation, environmental sensing, reinforcement learning, and autonomous control into a single closed-loop framework.

<p align="center">
  <img src="Results/Top_Level_Architecture.png" width="950">
</p>

## Architecture Workflow

```text
Marine APIs
(Currents, Waves, Temperature)
            │
            ▼
 ┌─────────────────────┐
 │ Digital Twin Model  │
 └──────────┬──────────┘
            │
            ▼
 ┌─────────────────────┐
 │ Observation Vector  │
 └──────────┬──────────┘
            │
            ▼
 ┌─────────────────────┐
 │ PPO RL Agent        │
 └──────────┬──────────┘
            │
            ▼
 ┌─────────────────────┐
 │ Thruster & Rudder   │
 └──────────┬──────────┘
            │
            ▼
 ┌─────────────────────┐
 │ REMUS 100 AUV       │
 └──────────┬──────────┘
            │
            ▼
      Sensor Feedback
            │
            └─────────────► Digital Twin
```

The architecture operates as a closed feedback loop where the reinforcement learning agent continuously interacts with the digital twin environment and learns optimal navigation strategies.

---

# Digital Twin Architecture

The digital twin serves as a virtual representation of the REMUS 100 AUV.

<p align="center">
  <img src="Results/Digital_Twin_Architecture.png" width="1000">
</p>

The digital twin includes:

### Vehicle Dynamics Model

Simulates:

- Hydrodynamic Forces
- Thruster Dynamics
- Vehicle Motion
- Ocean Disturbances

### Environmental Interface

Fetches real-time data from:

- Open-Meteo Marine API
- NOAA Marine Data Services

Including:

- Ocean Currents
- Waves
- Temperature
- Humidity

### Sensor Models

Simulates realistic sensor outputs from:

- IMU
- DVL
- Magnetometer
- Depth Sensor
- MQ-2 Gas Sensor

### Observation Assembly

Combines all vehicle states, environmental variables, and sensor measurements into a reinforcement learning observation vector.

---

# Technologies Used

## MATLAB

MATLAB serves as the primary development environment.

Used for:

- Mathematical Modeling
- Data Processing
- Reinforcement Learning Training
- Visualization

---

## Simulink

Simulink provides the simulation environment used to build the digital twin.

Used for:

- Vehicle Dynamics Modeling
- Sensor Simulation
- Environmental Modeling
- Control System Integration

---

## Reinforcement Learning Toolbox

Used for:

- PPO Agent Training
- Policy Optimization
- Actor-Critic Networks
- Continuous Control

---

## Deep Learning Toolbox

Used for:

- Neural Network Construction
- Policy Networks
- Value Function Approximation

---

## Marine APIs

Real-world marine data is obtained using:

### Open-Meteo Marine API

Provides:

- Ocean Currents
- Wave Data
- Sea Surface Conditions

### NOAA Marine Data

Provides:

- Ocean Forecast Data
- Environmental Variables

---

# Reinforcement Learning Framework

## Why Reinforcement Learning?

Traditional control systems use predefined rules.

Reinforcement Learning allows the AUV to learn optimal actions through interaction with the environment.

The agent continuously improves by maximizing cumulative rewards.

---

## PPO Algorithm

This project uses:

### Proximal Policy Optimization (PPO)

PPO is one of the most widely used reinforcement learning algorithms for continuous control problems.

Advantages:

- Stable Training
- Continuous Actions
- Sample Efficiency
- Robust Performance

---

## Observation Space

The observation vector contains:

```text
Position Error
Heading Error
Velocity
Ocean Current Information
Wave Information
Gas Sensor Measurements
Temperature
Energy Consumption
```

Total:

```text
10-Dimensional Observation Vector
```

---

## Action Space

The RL agent outputs:

```text
Thruster Command
Rudder Command
```

These continuous actions control vehicle movement.

---

## Neural Network Architecture

```text
Observation Vector
        │
        ▼
Dense Layer (128)
        │
       ReLU
        │
        ▼
Dense Layer (128)
        │
       ReLU
        │
 ┌──────┴────────────┐
 ▼                   ▼
Critic          Actor
(Value)       (Policy)
```

The actor generates control actions while the critic evaluates state quality.

---

# Sensor Modeling

One major innovation of this project is realistic sensor modeling.

## IMU Model

Provides:

- Acceleration
- Angular Velocity
- Orientation

---

## DVL Model

Provides:

- Velocity Estimation
- Position Tracking

---

## Magnetometer Model

Provides:

- Heading Information
- Direction Estimation

---

## Depth Sensor Model

Provides:

- Underwater Depth Measurements

---

## MQ-2 Gas Sensor Digital Twin

The project includes a physics-based MQ-2 sensor model.

Features:

- Heater Warm-Up Effects
- Multi-Gas Sensitivity
- Temperature Compensation
- Humidity Compensation
- Dynamic Response Modeling

This significantly improves sim-to-real transfer capability.

---

# Training Procedure

## Step 1

Initialize:

- Vehicle Dynamics
- Sensor Models
- Ocean Conditions

---

## Step 2

Generate observation vector.

---

## Step 3

Feed observations into PPO agent.

---

## Step 4

Generate thruster and rudder actions.

---

## Step 5

Apply actions inside the digital twin.

---

## Step 6

Calculate reward.

Reward components:

- Navigation Progress
- Energy Efficiency
- Stability
- Sensing Performance

---

## Step 7

Update PPO policy.

---

## Step 8

Repeat until convergence.

---

# Results

The trained PPO agent successfully learned energy-aware navigation behavior.

---

# Autonomous Navigation Trajectory

<p align="center">
  <img src="Results/navigation_path.png" width="700">
</p>

Observations:

- Successfully reached target waypoint
- Stable navigation performance
- Effective ocean current compensation
- Smooth trajectory generation

---

# Navigation Convergence

<p align="center">
  <img src="Results/convergence.png" width="700">
</p>

Observations:

- Distance to target continuously decreases
- Stable convergence behavior
- Successful mission completion

---

# Energy Consumption Profile

<p align="center">
  <img src="Results/energy_consumption.png" width="700">
</p>

Observations:

- Reduced propulsion effort
- Efficient energy utilization
- Improved mission endurance
- Adaptive current exploitation

---

# Project Structure

```text
Digital-Twin-RL-Control-for-REMUS100-AUV
│
├── Codebase/
│   ├── run.m
│   ├── setupAgent.m
│   ├── evaluate_and_plot.m
│   ├── fetch_env_data.m
│   └── Sensor Models
│
├── Simulink/
│   └── Remus_AUV_twin.slx
│
├── Results/
│   ├── Fig1_Top_Level_Architecture.png
│   ├── Fig2_Digital_Twin_Architecture.png
│   ├── Result_Fig1_Path.png
│   ├── Result_Fig2_Energy.png
│   └── Result_Fig3_Convergence.png
│
├── Docs/
│   ├── Project_Report.pdf
│   └── Patent_Document.pdf
│
├── Trained_models/
│   ├── Trained_Remus_Agent.mat
│   └── Trained_Remus_Agent_Final.mat
│
├── README.md
├── Requirements.md
├── LICENSE
└── .gitignore
```

---

# Future Improvements

- Real AUV Deployment
- NVIDIA Jetson Integration
- Raspberry Pi Deployment
- Sonar-Based Obstacle Avoidance
- Multi-Agent AUV Swarms
- Adaptive Ocean Current Estimation
- Real-Time Ocean Mapping
- 3D Path Planning
- Underwater Communication Integration

---

# Patent

This project contributed to a patent disclosure titled:

**Energy-Aware Autonomous Underwater Vehicle Control Using Reinforcement Learning with Digital Twin and Real-Time Marine Environmental Data Integration**

---

# Authors

### Devanshi Das
