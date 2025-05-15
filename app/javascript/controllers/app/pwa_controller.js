import BaseController from "controllers/base_controller";

// Connects to data-controller="app--pwa"
export default class extends BaseController {
  // 1. Static Definitions
  static targets = ["pwaStandalone"]

  // 2. Lifecycle Methods
  // ----------------------
  connect() {
    super.connect(false)
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------
  /**
   * Even though target-connected methods are not used as public actions,
   * they cannot be declared as private (e.g. as #pwaStandaloneTargetConnected)
   * because Stimulus requires these methods to be public.
   *
   * If the app is running in standalone mode (as an installed PWA), we add the
   * 'pwa-standalone' class. This class adjusts the bottom position of our fixed
   * navigation buttons (e.g. on iOS).
   */
  pwaStandaloneTargetConnected() {
    const isStandalone = window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone

    if (isStandalone) {
      this.pwaStandaloneTargets.forEach((element) =>
        element.classList.add("pwa-standalone")
      )
    }
  }
  
  // 4a. Public Action Methods (alphabetical)
  // ----------------------
  
  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------
  
  // 5. Private Helper Methods (alphabetical)
  // ----------------------
  
  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
}
