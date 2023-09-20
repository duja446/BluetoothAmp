// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import WaveSurfer from "wavesurfer.js"

let Hooks = {
  transition: {
    mounted() {
      this.from = this.el.getAttribute('data-transition-from').split(' ')
      this.to = this.el.getAttribute('data-transition-to').split(' ')

      this.el.classList.add(...this.from)

      setTimeout(() => {
        this.el.classList.remove(...this.from)
        this.el.classList.add(...this.to)
      }, 10)
    },
    updated() {
      this.el.classList.remove('transition')
      this.el.classList.remove(...this.from)
    }

  },
  Waveform: {
    mounted(){
      let duration = this.el.dataset.duration
      console.log(this.el.id)
      const wavesurfer = WaveSurfer.create({
        container: "#" + this.el.id,
        normalize: true,

        barRadius: 5,
        barWidth: 6,
        height:90,
        cursorWidth: 0,
        waveColor: '#A7A7A7',
        progressColor: '#66BAEA',

      })

      wavesurfer.on('dblclick', () => {
        let time = wavesurfer.getCurrentTime()
        console.log('Seeking', time)
        this.pushEvent("seeking", time) 
      })

      this.handleEvent("peaks", ({peaks}) => {
        console.log(peaks)
        wavesurfer.backend.setPeaks(peaks, duration)
        wavesurfer.drawBuffer()
      })

      this.handleEvent("current_time", ({current_time}) => {
        console.log(current_time)
        wavesurfer.setCurrentTime(current_time)
      })
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
let topBarScheduled = undefined;
window.addEventListener("phx:page-loading-start", () => {
  if(!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 200);
  };
});
window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});
// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


