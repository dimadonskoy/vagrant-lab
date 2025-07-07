# Kuber

> Modern Vagrant-based Kubernetes Cluster Automation

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/yourusername/kuber/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## Table of Contents

- [About](#about)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## About

Kuber is a simple and modern automation toolkit for setting up and managing a local Kubernetes cluster using Vagrant. Ideal for development, testing, and learning Kubernetes in a reproducible environment.

---

## Features

- One-command cluster setup
- Automated disk resizing
- Easy restore and backup scripts
- Customizable Vagrantfile
- Cross-platform support (macOS, Linux)

---

## Prerequisites

- [Vagrant](https://www.vagrantup.com/) >= 2.2
- [VirtualBox](https://www.virtualbox.org/) or compatible provider
- [Bash](https://www.gnu.org/software/bash/)

---

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/kuber.git
   cd kuber
   ```
2. **Review and edit the `Vagrantfile` as needed.**

---

## Usage

- **Start the cluster:**
  ```bash
  ./control_node.sh up
  ```
- **Resize disk:**
  ```bash
  ./disk_resize.sh
  ```
- **Restore Vagrant state:**
  ```bash
  ./restore_vagrant.sh
  ```
- **Install kubeadm:**
  ```bash
  ./install_kubeadm.sh
  ```

> See each script for more details and options.

---

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements and bug fixes.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

Created by [Your Name](mailto:your.email@example.com) — feel free to reach out!
