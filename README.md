# Digital Twin-Based Reinforcement Learning Control for REMUS 100 AUV

> Energy-Aware Autonomous Underwater Vehicle Control using Reinforcement Learning, Digital Twin Technology, Physics-Based Sensor Modeling, and Real-Time Marine Environmental Data.

![MATLAB](https://img.shields.io/badge/MATLAB-R2024a-orange)
![Simulink](https://img.shields.io/badge/Simulink-Digital%20Twin-blue)
![Reinforcement Learning](https://img.shields.io/badge/Reinforcement-Learning-success)
![PPO](https://img.shields.io/badge/PPO-Continuous%20Control-red)
![Digital Twin](https://img.shields.io/badge/Digital-Twin-green)
![Marine Robotics](https://img.shields.io/badge/Marine-Robotics-purple)

---

# Table of Contents

- Overview
- Why This Project Matters
- Key Features
- System Architecture
- Digital Twin Architecture
- Technologies Used
- Reinforcement Learning Framework
- Digital Twin Sensor Layer
- Training Workflow
- Results
- Project Structure
- Installation
- Usage
- Future Improvements
- Patent
- Authors

---

# Overview

Autonomous Underwater Vehicles (AUVs) are extensively used for oceanographic research, underwater exploration, environmental monitoring, offshore inspection, and defense applications. These vehicles operate in highly dynamic underwater environments where currents, waves, turbulence, and weather conditions continuously influence navigation performance.

Traditional control methods such as PID controllers often struggle to adapt to these changing environmental conditions and frequently consume excessive energy while maintaining stability.

This project presents a **Digital Twin-Based Reinforcement Learning Framework** for the REMUS 100 Autonomous Underwater Vehicle. The framework integrates:

- High-Fidelity Digital Twin Modeling
- Reinforcement Learning-Based Control
- Real-Time Marine Environmental Data
- Physics-Based Sensor Modeling
- Multi-Objective Reward Optimization

The trained agent learns how to navigate efficiently, exploit favorable ocean currents, minimize energy consumption, and maintain navigation accuracy in realistic marine environments.

---

# Why This Project Matters

Modern autonomous systems must operate intelligently in uncertain environments.

Underwater vehicles face several challenges:

### Energy Constraints

AUVs rely on limited onboard batteries.

Poor control decisions can significantly reduce mission duration.

### Dynamic Marine Conditions

Ocean currents and waves continuously change.

Controllers must adapt in real time.

### Sim-to-Real Gap

Most AI models perform well in simulation but fail when deployed in real environments due to unrealistic training conditions.

### Multi-Objective Optimization

AUV missions require simultaneous optimization of:

- Navigation Accuracy
- Energy Efficiency
- Stability
- Sensor Performance

This project addresses all these challenges using a Digital Twin and Reinforcement Learning.

---

# Key Features

## High-Fidelity Digital Twin

A complete virtual representation of the REMUS 100 AUV was developed using MATLAB and Simulink. The digital twin simulates both vehicle behavior and environmental interactions, enabling safe and cost-effective reinforcement learning training.

---

## Real-Time Environmental Modeling

Unlike conventional reinforcement learning environments that use static disturbances, this project incorporates real-world marine conditions through API-based environmental modeling.

Files:

```text
Ocean_API_Block.m
Weather_API_Block.m
fetch_env_data.m
```

The environmental model incorporates:

- Ocean Currents
- Wave Conditions
- Temperature
- Humidity
- Water Surface Conditions

This creates a realistic training environment that better represents actual ocean operations.

---

## Physics-Based Sensor Simulation

The digital twin contains dedicated models for multiple onboard sensors.

Files:

```text
IMU_Block.m
DVL_Block.m
Depth_Block.m
Magnetometer_Block.m
MQ2_Block.m
```

The sensor layer generates realistic measurements including:

- Vehicle Orientation
- Angular Velocity
- Underwater Velocity
- Heading Information
- Depth Measurements
- Gas Concentration Levels

This reduces the sim-to-real gap and improves deployment readiness.

---

## Reinforcement Learning Controller

The vehicle controller is trained using Proximal Policy Optimization (PPO).

Files:

```text
setupAgent.m
run.m
```

The controller learns how to:

- Navigate autonomously
- Compensate for ocean currents
- Reduce energy consumption
- Maintain vehicle stability
- Improve mission efficiency

---

## Automated Performance Evaluation

After training, the learned policy is evaluated through automated simulation testing.

Files:

```text
evaluate_and_plot.m
```

Performance metrics include:

- Navigation Accuracy
- Energy Consumption
- Target Convergence
- Mission Completion Time

---

# System Architecture

The complete system operates as a closed-loop intelligent control framework.

<p align="center">
  <img src="Results/Top_Level_Architecture.png" width="900">
</p>

## Architecture Workflow

```text
Environmental Data
(Currents, Waves, Temperature)
                │
                ▼
       Digital Twin Model
                │
                ▼
       Observation Vector
                │
                ▼
        PPO RL Agent
                │
                ▼
     Thruster & Rudder Commands
                │
                ▼
           REMUS 100
                │
                ▼
        Sensor Feedback
                │
                └────────────► Digital Twin
```

The reinforcement learning agent continuously interacts with the digital twin, learns from environmental feedback, and improves its navigation strategy through repeated training episodes.

---

# Digital Twin Architecture

A Digital Twin is a virtual representation of a real-world system.

In this project, the digital twin simulates:

- Vehicle Dynamics
- Ocean Disturbances
- Sensor Behavior
- Energy Consumption
- Vehicle Navigation

<p align="center">
  <img src="Results/Digital_Twin_Architecture.jpg" width="950">
</p>

## Major Components

### Vehicle Dynamics Model

Simulates:

- Hydrodynamic Forces
- Vehicle Motion
- Drag Effects
- Thruster Response

### Environmental Interface

Retrieves marine data including:

- Ocean Currents
- Wave Information
- Water Conditions
- Environmental Variables

### Sensor Layer

Provides simulated outputs for:

- IMU
- DVL
- Magnetometer
- Depth Sensor
- MQ-2 Gas Sensor

### Observation Assembly

Combines all system states and sensor measurements into a reinforcement learning observation vector.

---

# Technologies Used

## MATLAB

MATLAB serves as the primary computational platform.

Used for:

- Mathematical Modeling
- Data Processing
- RL Training
- Performance Evaluation
- Visualization

### Why MATLAB?

MATLAB provides a rich ecosystem for robotics, control systems, optimization, and machine learning.

---

## Simulink

Simulink provides a graphical environment for modeling complex engineering systems.

Used for:

- Vehicle Dynamics Simulation
- Sensor Simulation
- Environmental Modeling
- Digital Twin Construction

### Why Simulink?

It allows engineers to visualize and test complex systems before physical deployment.

---

## Digital Twin Technology

A Digital Twin is a virtual replica of a physical asset.

### Benefits

- Safe Training Environment
- Reduced Development Cost
- Faster Experimentation
- Improved System Understanding
- Better Sim-to-Real Transfer

---

## Reinforcement Learning

Reinforcement Learning enables an agent to learn through interaction with an environment.

Unlike traditional controllers that follow fixed rules, RL agents learn optimal behaviors through experience.

### Benefits

- Adaptability
- Continuous Learning
- Autonomous Decision Making
- Multi-Objective Optimization

---

## PPO (Proximal Policy Optimization)

The reinforcement learning algorithm used in this project is PPO.

### Why PPO?

PPO is one of the most successful RL algorithms for continuous control tasks.

Advantages:

- Stable Training
- Continuous Action Spaces
- Efficient Learning
- Strong Convergence Performance

---

## Marine Environmental APIs

Environmental realism is achieved through:

### Open-Meteo Marine API

Provides:

- Ocean Currents
- Wave Height
- Sea Conditions

### NOAA Marine Data

Provides:

- Environmental Forecasts
- Ocean Measurements

These APIs make the simulation significantly more realistic.

---

# Reinforcement Learning Framework

## How Reinforcement Learning Works

The RL agent learns using trial-and-error interactions.

### Observation

The agent observes:

```text
Position Error
Velocity
Heading
Ocean Currents
Wave Data
Sensor Measurements
Energy Usage
```

### Action

The agent outputs:

```text
Thruster Command
Rudder Command
```

### Reward

Rewards encourage:

- Progress Toward Target
- Energy Efficiency
- Stability
- Better Sensing Performance

The agent continuously improves its policy by maximizing cumulative reward.

---

# Neural Network Architecture

The PPO controller uses an Actor-Critic architecture.

```text
Observation Vector
         │
         ▼
   Dense Layer
      128
         │
        ReLU
         │
         ▼
   Dense Layer
      128
         │
        ReLU
         │
 ┌───────┴────────┐
 ▼                ▼
Actor          Critic
Policy      Value Function
```

### Actor

Generates control actions.

### Critic

Evaluates action quality.

Together they learn optimal navigation behavior.

---

# Digital Twin Sensor Layer

One of the most important contributions of this project is the development of realistic sensor models that mimic the behavior of physical sensors found on modern AUV platforms.

The digital twin does not simply generate perfect measurements. Instead, it attempts to replicate how actual hardware behaves underwater.

---

## IMU Model

File:

```text
IMU_Block.m
```

The Inertial Measurement Unit provides:

- Linear Acceleration
- Angular Velocity
- Vehicle Orientation

The RL agent relies on IMU measurements to estimate vehicle motion and maintain stability.

---

## DVL Model

File:

```text
DVL_Block.m
```

The Doppler Velocity Log estimates vehicle velocity relative to the seabed.

Outputs include:

- Surge Velocity
- Sway Velocity
- Relative Motion Information

The DVL helps the controller determine whether the vehicle is drifting due to currents.

---

## Magnetometer Model

File:

```text
Magnetometer_Block.m
```

The magnetometer provides heading information.

This sensor enables:

- Direction Estimation
- Course Correction
- Heading Stabilization

---

## Depth Sensor Model

File:

```text
Depth_Block.m
```

The depth sensor continuously monitors underwater depth.

This information is critical for:

- Maintaining Operating Depth
- Vertical Stability
- Mission Safety

---

## MQ-2 Gas Sensor Model

Files:

```text
MQ2_Block.m
MQ2_Sensor_Simple.m
```

A physics-inspired gas sensor model was implemented to simulate realistic gas concentration measurements.

Features include:

- Heater Warm-Up Effects
- Environmental Compensation
- Multi-Gas Sensitivity
- Dynamic Sensor Response

This sensor can support future applications such as:

- Leak Detection
- Environmental Monitoring
- Underwater Pollution Tracking

---

# Training Workflow

## Step 1

Initialize:

- Digital Twin
- Sensors
- Environmental Conditions

---

## Step 2

Generate Observation Vector

```text
Vehicle States
+
Environmental Data
+
Sensor Measurements
```

---

## Step 3

Agent Generates Actions

```text
Thruster Output
Rudder Output
```

---

## Step 4

Apply Actions

The digital twin updates vehicle motion.

---

## Step 5

Compute Reward

Reward includes:

- Navigation Progress
- Energy Savings
- Stability
- Sensor Quality

---

## Step 6

Update PPO Policy

The neural network weights are updated.

---

## Step 7

Repeat Until Convergence

Thousands of training episodes are performed.

The agent gradually learns optimal navigation behavior.

---

# Results and Performance Analysis

The trained PPO agent was evaluated in a mission scenario where the REMUS 100 AUV was required to travel from the origin point to a target waypoint while experiencing simulated ocean disturbances.

Mission Parameters:

```text
Start Position  : (0,0)
Target Position : (50,50)
Environment     : Ocean Current Disturbances
Controller      : PPO Reinforcement Learning Agent
```

---

## Navigation Performance

<p align="center">
  <img src="Results/navigation_path.png" width="700">
</p>

### Analysis

The trajectory demonstrates that the RL agent successfully reached the target waypoint while compensating for ocean current disturbances.

Key observations:

- Successful target acquisition
- Smooth trajectory generation
- Stable path corrections
- Drift-aware navigation

Unlike traditional controllers that fight currents directly, the learned policy intelligently exploits environmental forces to maintain efficient motion.

---

## Convergence Performance

<p align="center">
  <img src="Results/convergence.png" width="700">
</p>

### Analysis

The convergence graph illustrates the reduction in distance-to-target throughout the mission.

Observations:

- Monotonic reduction in target distance
- Stable convergence behavior
- No oscillatory divergence
- Successful mission completion

The distance decreases from approximately 70 meters to near zero, indicating reliable navigation performance.

---

## Energy Consumption Analysis

<p align="center">
  <img src="Results/energy_consumption.png" width="700">
</p>

### Analysis

Energy efficiency was a primary optimization objective.

Observations:

- Controlled energy expenditure
- No unnecessary actuator activity
- Efficient propulsion usage
- Reduced energy wastage after target acquisition

The learned controller demonstrates awareness of energy costs and actively minimizes unnecessary control actions.

---

## Overall Performance Summary

| Metric | Performance |
|---|---|
| Target Reached | Yes |
| Navigation Stability | High |
| Current Compensation | Successful |
| Energy Optimization | Successful |
| Mission Completion | Successful |
| Sim-to-Real Readiness | Improved |

The results demonstrate that the Digital Twin and PPO framework can successfully learn energy-efficient navigation policies while maintaining robust performance in disturbed marine environments.

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
│   ├── Ocean_API_Block.m
│   ├── Weather_API_Block.m
│   ├── IMU_Block.m
│   ├── DVL_Block.m
│   ├── Depth_Block.m
│   ├── Magnetometer_Block.m
│   ├── MQ2_Block.m
│   └── MQ2_Sensor_Simple.m
│
├── Simulink/
│   └── Remus_AUV_twin.slx
│
├── Results/
│   ├── Top_Level_Architecture.png
│   ├── Digital_Twin_Architecture.jpg
│   ├── navigation_path.png
│   ├── energy_consumption.png
│   └── convergence.png
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

# Installation

1. Install MATLAB R2024a or later
2. Install Simulink
3. Install Reinforcement Learning Toolbox
4. Install Deep Learning Toolbox
5. Clone the repository

```bash
git clone https://github.com/your-username/Energy-Aware-AUV-Control-Using-RL-and-Digital-Twin.git
```

---

# Usage

Open MATLAB and run:

```matlab
run.m
```

For evaluation:

```matlab
evaluate_and_plot.m
```

To modify the PPO agent:

```matlab
setupAgent.m
```

---

# Future Improvements

- Real AUV Deployment
- NVIDIA Jetson Integration
- Raspberry Pi Deployment
- Sonar-Based Obstacle Avoidance
- Multi-Agent AUV Coordination
- Adaptive Current Estimation
- Real-Time Ocean Mapping
- Swarm Intelligence
- 3D Path Planning

---

# Authors

**Devanshi Das**
