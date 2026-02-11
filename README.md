# Parallel Bitonic Sort using CUDA
Implementing Bitonic Sort algorithm using CUDA
This project was developed as part of the **Parallel Processing** coursework to demonstrate the efficiency of GPU acceleration for sorting large datasets.
## Key Features
* **Parallel Execution:** Fully parallelized sorting stages using CUDA kernels.
* **Scalability:** Designed to handle array sizes of $2^n$.
* **Memory Management:** Efficient handling of Host-to-Device and Device-to-Host memory transfers.

## 🛠️ Technologies Used
* **Language:** C / C++
* **Parallel Computing Platform:** CUDA (Compute Unified Device Architecture)
* **Compiler:** NVCC (NVIDIA CUDA Compiler)

## ⚙️ How It Works
The algorithm works in two main phases:
1.  **Bitonic Sequence Generation:** The array is divided into smaller bitonic sequences (first increasing, then decreasing).
2.  **Bitonic Merge:** These sequences are recursively merged to form a single sorted sequence.

By mapping threads to comparison operations, we can perform thousands of comparisons simultaneously on the GPU.

## 🚀 Getting Started

### Prerequisites
* NVIDIA GPU with CUDA support.
* [CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit) installed.
