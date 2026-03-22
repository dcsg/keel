import DefaultTheme from 'vitepress/theme'
import Terminal from './Terminal.vue'
import T from './T.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('Terminal', Terminal)
    app.component('T', T)
  }
}
