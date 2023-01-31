module.exports = {
  config: {
    updateChannel: "stable",
    fontSize: "13",
    fontFamily: "SauceCodeProNerdFontComplete-Regular",
    fontWeight: "normal",
    fontWeightBold: "bold",
    lineHeight: 1,
    letterSpacing: 0,
    cursorColor: "rgba(248,28,229,0.8)",
    cursorAccentColor: "#000",
    cursorShape: "BLOCK",
    cursorBlink: false,
    foregroundColor: "#fff",
    backgroundColor: "#000",
    selectionColor: "rgba(248,28,229,0.3)",
    borderColor: "#333",
    css: "",
    termCSS: "",
    showHamburgerMenu: false,
    showWindowControls: false,
    padding: "12px 14px",
    colors: {
      black: "#073642",
      red: "#dc322f",
      green: "#859900",
      yellow: "#b58900",
      blue: "#268bd2",
      magenta: "#d33682",
      cyan: "#2aa198",
      white: "#eee8d5",
      lightBlack: "#686868",
      lightRed: "#cb4b16",
      lightGreen: "#586e75",
      lightYellow: "#657b83",
      lightBlue: "#839496",
      lightMagenta: "#6c71c4",
      lightCyan: "#93a1a1",
      lightWhite: "#fdf6e3",
    },
    shell: "",
    shellArgs: ["--login"],
    env: {},
    bell: false,
    copyOnSelect: true,
    defaultSSHApp: true,
    quickEdit: false,
    macOptionSelectionMode: "force",
    webLinksActivationKey: "shift",
    webGLRenderer: true,
  },
  plugins: ["hyper-solarized-light"],
};
