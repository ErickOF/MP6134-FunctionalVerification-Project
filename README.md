<p align="center"><h1 align="center">MP6134-FUNCTIONALVERIFICATION-PROJECT</h1></p>
<p align="center">
	<img src="https://img.shields.io/github/license/ErickOF/MP6134-FunctionalVerification-Project?style=default&logo=opensourceinitiative&logoColor=white&color=0080ff" alt="license">
	<img src="https://img.shields.io/github/last-commit/ErickOF/MP6134-FunctionalVerification-Project?style=default&logo=git&logoColor=white&color=0080ff" alt="last-commit">
	<img src="https://img.shields.io/github/languages/top/ErickOF/MP6134-FunctionalVerification-Project?style=default&color=0080ff" alt="repo-top-language">
	<img src="https://img.shields.io/github/languages/count/ErickOF/MP6134-FunctionalVerification-Project?style=default&color=0080ff" alt="repo-language-count">
</p>
<p align="center"><!-- default option, no dependency badges. -->
</p>
<p align="center">
	<!-- default option, no dependency badges. -->
</p>
<br>

## 🔗 Table of Contents

- [📍 Overview](#-overview)
- [👾 Features](#-features)
- [📁 Project Structure](#-project-structure)
  - [📂 Project Index](#-project-index)
- [🚀 Getting Started](#-getting-started)
  - [☑️ Prerequisites](#-prerequisites)
  - [⚙️ Installation](#-installation)
  - [🤖 Usage](#🤖-usage)
  - [🧪 Testing](#🧪-testing)
- [📌 Project Roadmap](#-project-roadmap)
- [🔰 Contributing](#-contributing)
- [🎗 License](#-license)
- [🙌 Acknowledgments](#-acknowledgments)

---

## 📍 Overview

<code>❯ This repository contains the functional verification for <a href="https://github.com/darklife/darkriscv">darkriscv</a>. This a course project for <b>MP6134 Functional Verification</b> of the Master's in Electronics degree at Costa Rica Institute of Technology.</code>

---

## 👾 Features

<code>❯ REPLACE-ME</code>

---

## 📁 Project Structure

```sh
└── MP6134-FunctionalVerification-Project/
    ├── LICENSE
    ├── Makefile
    ├── README.md
    ├── export_tools.sh
    ├── rtl
    │   ├── README.md
    │   ├── include
    │   ├── interfaces
    │   └── src
    ├── tb
    │   ├── README.md
    │   ├── checkers
    │   ├── environment
    │   ├── filelist.f
    │   ├── sequences
    │   └── tests
    └── tb_uvm
        ├── checkers
        ├── environment
        ├── filelist.f
        ├── sequences
        └── tests
```


### 📂 Project Index
<details open>
	<summary><b><code>MP6134-FUNCTIONALVERIFICATION-PROJECT/</code></b></summary>
	<details> <!-- __root__ Submodule -->
		<summary><b>__root__</b></summary>
		<blockquote>
			<table>
			<tr>
				<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/export_tools.sh'>export_tools.sh</a></b></td>
				<td><code>❯ REPLACE-ME</code></td>
			</tr>
			<tr>
				<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/Makefile'>Makefile</a></b></td>
				<td><code>❯ REPLACE-ME</code></td>
			</tr>
			</table>
		</blockquote>
	</details>
	<details> <!-- rtl Submodule -->
		<summary><b>rtl</b></summary>
		<blockquote>
			<details>
				<summary><b>src</b></summary>
				<blockquote>
					<table>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/rtl/src/darkriscv.v'>darkriscv.v</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					</table>
				</blockquote>
			</details>
			<details>
				<summary><b>include</b></summary>
				<blockquote>
					<table>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/rtl/include/config.vh'>config.vh</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					</table>
				</blockquote>
			</details>
			<details>
				<summary><b>interfaces</b></summary>
				<blockquote>
					<table>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/rtl/interfaces/darkriscv_if.sv'>darkriscv_if.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					</table>
				</blockquote>
			</details>
		</blockquote>
	</details>
	<details> <!-- tb_uvm Submodule -->
		<summary><b>tb_uvm</b></summary>
		<blockquote>
			<table>
			<tr>
				<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/filelist.f'>filelist.f</a></b></td>
				<td><code>❯ REPLACE-ME</code></td>
			</tr>
			</table>
			<details>
				<summary><b>environment</b></summary>
				<blockquote>
					<table>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/darkriscv_scoreboard.sv'>darkriscv_scoreboard.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/darkriscv_agent.sv'>darkriscv_agent.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/instructions_pkg.svh'>instructions_pkg.svh</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/darkriscv_items_pkg.sv'>darkriscv_items_pkg.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/darkriscv_driver.sv'>darkriscv_driver.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/darkriscv_reference_model.sv'>darkriscv_reference_model.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/darkriscv_input_item.sv'>darkriscv_input_item.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/helper.sv'>helper.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/darkriscv_env.sv'>darkriscv_env.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/darkriscv_monitor.sv'>darkriscv_monitor.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/environment/darkriscv_output_item.sv'>darkriscv_output_item.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					</table>
				</blockquote>
			</details>
			<details>
				<summary><b>sequences</b></summary>
				<blockquote>
					<table>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/sequences/darkriscv_seq.sv'>darkriscv_seq.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/sequences/random_instr_seq.sv'>random_instr_seq.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/sequences/darkriscv_item.sv'>darkriscv_item.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/sequences/init_registers_seq.sv'>init_registers_seq.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/sequences/save_registers_seq.sv'>save_registers_seq.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					</table>
				</blockquote>
			</details>
			<details>
				<summary><b>checkers</b></summary>
				<blockquote>
					<table>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/checkers/s_type_checker.sv'>s_type_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/checkers/base_instruction_checker.sv'>base_instruction_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb_uvm/checkers/i_type_checker.sv'>i_type_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					</table>
				</blockquote>
			</details>
		</blockquote>
	</details>
	<details> <!-- tb Submodule -->
		<summary><b>tb</b></summary>
		<blockquote>
			<table>
			<tr>
				<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/filelist.f'>filelist.f</a></b></td>
				<td><code>❯ REPLACE-ME</code></td>
			</tr>
			</table>
			<details>
				<summary><b>environment</b></summary>
				<blockquote>
					<table>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/riscv_defs.svh'>riscv_defs.svh</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/instructions_pkg.svh'>instructions_pkg.svh</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/dut_intf.sv'>dut_intf.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/driver.sv'>driver.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/environment.sv'>environment.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/riscv_reference_model.sv'>riscv_reference_model.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/tb_top.sv'>tb_top.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/helper.sv'>helper.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/monitor.sv'>monitor.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/environment/scoreboard.sv'>scoreboard.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					</table>
				</blockquote>
			</details>
			<details>
				<summary><b>sequences</b></summary>
				<blockquote>
					<table>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/sequences/stimulus_types.sv'>stimulus_types.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/sequences/stimulus.sv'>stimulus.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					</table>
				</blockquote>
			</details>
			<details>
				<summary><b>checkers</b></summary>
				<blockquote>
					<table>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/checkers/j_type_checker.sv'>j_type_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/checkers/b_type_checker.sv'>b_type_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/checkers/s_type_checker.sv'>s_type_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/checkers/base_instruction_checker.sv'>base_instruction_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/checkers/u_type_checker.sv'>u_type_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/checkers/r_type_checker.sv'>r_type_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					<tr>
						<td><b><a href='https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/master/tb/checkers/i_type_checker.sv'>i_type_checker.sv</a></b></td>
						<td><code>❯ REPLACE-ME</code></td>
					</tr>
					</table>
				</blockquote>
			</details>
		</blockquote>
	</details>
</details>

---
## 🚀 Getting Started

### ☑️ Prerequisites

Before getting started with MP6134-FunctionalVerification-Project, ensure your runtime environment meets the following requirements:

- **Programming Language:** Error detecting primary_language: {'sh': 1, 'v': 1, 'vh': 1, 'sv': 36, 'f': 2, 'svh': 3}


### ⚙️ Installation

Install MP6134-FunctionalVerification-Project using one of the following methods:

**Build from source:**

1. Clone the MP6134-FunctionalVerification-Project repository:
```sh
❯ git clone https://github.com/ErickOF/MP6134-FunctionalVerification-Project
```

2. Navigate to the project directory:
```sh
❯ cd MP6134-FunctionalVerification-Project
```

3. Install the project dependencies:

echo 'INSERT-INSTALL-COMMAND-HERE'



### 🤖 Usage
Run MP6134-FunctionalVerification-Project using the following command:
echo 'INSERT-RUN-COMMAND-HERE'

### 🧪 Testing
Run the test suite using the following command:
echo 'INSERT-TEST-COMMAND-HERE'

---
## 📌 Project Roadmap

- [X] **`Task 1`**: <strike>Implement feature one.</strike>
- [ ] **`Task 2`**: Implement feature two.
- [ ] **`Task 3`**: Implement feature three.

---

## 🔰 Contributing

- **💬 [Join the Discussions](https://github.com/ErickOF/MP6134-FunctionalVerification-Project/discussions)**: Share your insights, provide feedback, or ask questions.
- **🐛 [Report Issues](https://github.com/ErickOF/MP6134-FunctionalVerification-Project/issues)**: Submit bugs found or log feature requests for the `MP6134-FunctionalVerification-Project` project.
- **💡 [Submit Pull Requests](https://github.com/ErickOF/MP6134-FunctionalVerification-Project/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your github account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone https://github.com/ErickOF/MP6134-FunctionalVerification-Project
   ```
3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.
   ```sh
   git checkout -b new-feature-x
   ```
4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.
   ```sh
   git commit -m 'Implemented new feature x.'
   ```
6. **Push to github**: Push the changes to your forked repository.
   ```sh
   git push origin new-feature-x
   ```
7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.
8. **Review**: Once your PR is reviewed and approved, it will be merged into the main branch. Congratulations on your contribution!
</details>

<details closed>
<summary>Contributor Graph</summary>
<br>
<p align="left">
   <a href="https://github.com{/ErickOF/MP6134-FunctionalVerification-Project/}graphs/contributors">
      <img src="https://contrib.rocks/image?repo=ErickOF/MP6134-FunctionalVerification-Project">
   </a>
</p>
</details>

---

## 🎗 License

This project is protected under the [SELECT-A-LICENSE](https://choosealicense.com/licenses) License. For more details, refer to the [LICENSE](https://choosealicense.com/licenses/) file.

---

## 🙌 Acknowledgments

- Powered by [README AI](https://readme-ai.streamlit.app/).

---
