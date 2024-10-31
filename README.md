# SASHA

## Overview

The **SASHA** is a simple Bash script designed to streamline the process of connecting to SSH hosts.

## Features

- **Dynamic Host Listing**: Automatically loads SSH hosts from your `~/.ssh/config` file.
- **Search Functionality**: Quickly filter hosts by typing your search query.
- **Navigation**: Use arrow keys to navigate through the list of hosts.
- **Simple Connection**: Connect to a selected host by pressing Enter.
- **Customizable Colors**: Supports themes for a personalized experience.
- **Cross-Platform Compatibility**: Works on Linux, macOS, and Windows (via WSL or Cygwin).

## Inspiration

This project was inspired by the **[sshs](https://github.com/quantumsheep/sshs)** project, which demonstrates a similar approach to managing SSH connections in a streamlined and user-friendly manner.

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/2cc/sasha.git
   cd sasha
   ```

2. **Create a symbolic link** to easily run the script from anywhere:
   ```bash
   ln -s /path/to/main.sh /usr/local/bin/sasha
   ```

3. **Ensure your `~/.ssh/config` file is set up** with the desired hosts.

## Usage

To launch the SSH Menu Script, simply type the following command in your terminal:

```bash
sasha
```

Once the script is running, you can:

- Use **arrow keys** to navigate through the list of hosts.
- Type to **search** for specific hosts.
- Press **Enter** to connect to the selected host.
- Use **Ctrl+C** to exit the script gracefully.

## Customization

Feel free to customize the script to fit your workflow. You can adjust the color themes and other settings by modifying the `themes/base_theme` file.

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Author

Developed by [2сс](https://github.com/2сс) with assistance from **ChatGPT**.

## Acknowledgments

- Special thanks to the open-source community for their invaluable contributions and support.
- Inspired by the [sshs](https://github.com/quantumsheep/sshs) project for its innovative approach to SSH management.
- Code and documentation assistance provided by **ChatGPT**.
