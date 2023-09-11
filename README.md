<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![GitHub Repo stars][stars-shield]][stars-url]
[![MIT License][license-shield]][license-url]


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/duja446/BluetoothAmp">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Bluetooth Amp</h3>

  <p align="center">
    A webapp which plays music on the device hosting it, which can route it to AUX, Bluetooth or another device.
    <br />
    <a href="https://github.com/duja446/BluetoothAmp"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/duja446/BluetoothAmp">View Demo</a>
    ·
    <a href="https://github.com/duja446/BluetoothAmp/issues">Report Bug</a>
    ·
    <a href="https://github.com/duja446/BluetoothAmp/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Bluetooth Amp Screen Shot][product-screenshot]](https://example.com)

I wanted to create an app with which I can play music on my bluetooth speakers from my phone but withouth it coming from my phone. I created an webapp which lists albums and songs, and can play music from the device that is hosting the app. That device can connect to any bluetooth speaker thus being able to play music on it. I personally host it on a RaspberryPI and connect the PI to my bluetooth speakers.

The app has a really similar style to [Poweramp](https://powerampapp.com/) a music player I use on a daily basis.

The project currently only supports music in the `.flac` format.
<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* [![Elixir][Elixir]][Elixir-url]
* [![Phoenix][Phoenix]][Phoenix-url]
* [![Tailwind][Tailwind]][Tailwind-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

Here is an example of how you can configure an run the project

### Prerequisites

* Install and configure MPD ([Arch wiki](https://wiki.archlinux.org/title/Music_Player_Daemon))
* Put your music albums in `.flac` format in the `~/Music` folder 

### Installation

1. Clone the repo
    ```sh
    git clone https://github.com/duja446/BluetoothAmp
    ```
2. Install the dependancies 
    ```sh
    mix deps.get
    ```
3. Configure the database
    ```sh
    mix ecto.create
    mix ecto.migrate
    ```
4. Run the project
    ```sh
    mix phx.server
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [x] Scan button 
- [ ] Base page
- [ ] Write the usage page
- [ ] Support .mp3 files
- [ ] Music seek
- [ ] Bluetooth connection from the app
- [ ] Shuffle
- [ ] Playlists
- [ ] List songs by:
    - [ ] Author
    - [ ] Genre
- [ ] Raiting system

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Dusan Veljkovic - duja446@gmail.com

Project Link: [https://github.com/duja446/BluetoothAmp](https://github.com/duja446/BluetoothAmp)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[stars-shield]: https://img.shields.io/github/stars/duja446/BluetoothAmp.svg?style=for-the-badge
[stars-url]: https://github.com/duja446/duja446/stargazers
[license-shield]: https://img.shields.io/github/license/duja446/BluetoothAmp.svg?style=for-the-badge
[license-url]: https://github.com/duja446/BluetoothAmp/blob/master/LICENSE.txt
[product-screenshot]: images/screenshot.png

[Elixir]: https://img.shields.io/badge/elixir-%234B275F.svg?style=for-the-badge&logo=elixir&logoColor=white
[Elixir-url]: https://elixir-lang.org/
[Phoenix]: https://img.shields.io/badge/Phoenix_Framework-000000?style=for-the-badge&logo=phoenix-framework&logoColor=white&color=%23ff6f61
[Phoenix-url]: https://www.phoenixframework.org/
[Tailwind]: https://img.shields.io/badge/tailwindcss-%2338B2AC.svg?style=for-the-badge&logo=tailwind-css&logoColor=white
[Tailwind-url]: https://tailwindcss.com/
