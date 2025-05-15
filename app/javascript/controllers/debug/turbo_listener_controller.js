import BaseController from "controllers/base_controller";

// Connects to data-controller="debug--turbo-listener"
export default class extends BaseController {
  static debugGroup = {
    navigation: true,
    fetch: true,
    forms: true,
    rendering: true,
    frames: true,
    stream: true,
    morph: true,
  };

  connect() {
    // Show controller name
    super.connect(true);

    this.debugEventEnabled = true;
    this.debugEventDetailEnabled = true;

    // Attach groups based on config
    if (this.constructor.debugGroup.navigation) this.basicNavigationAndLinkEvents();
    if (this.constructor.debugGroup.fetch) this.fetchLifecycleEvents();
    if (this.constructor.debugGroup.forms) this.formSubmissions();
    if (this.constructor.debugGroup.rendering) this.rendering();
    if (this.constructor.debugGroup.frames) this.turboFrames();
    if (this.constructor.debugGroup.stream) this.turboStream();
    if (this.constructor.debugGroup.morph) this.turboMorph();
  }

  disconnect() {
    if (this._listeners) {
      this._listeners.forEach(({ eventName, handler }) => {
        document.removeEventListener(eventName, handler);
      });
      // Optional: reset for reuse
      this._listeners = [];
    }
  }

  // 1. Basic Navigation and Link Events
  // --------------------------------
  basicNavigationAndLinkEvents() {
    this.listenToEvents({
      "turbo:click": "Click on a Turbo-enabled link.",
      "turbo:before-visit": "Before visiting a location, excluding history navigation.",
      "turbo:visit": "Immediately after a visit starts.",
    });
  }

  // 2. Fetch Lifecycle Events
  // -------------------------
  fetchLifecycleEvents() {
    this.listenToEvents({
      "turbo:before-fetch-request": "Before Turbo issues a network request.",
      "turbo:before-fetch-response": "After the network request completes.",
      "turbo:fetch-request-error": "When a fetch request fails due to network errors.",
    });
  }

  // 3. Form Submissions
  // --------------------
  formSubmissions() {
    this.listenToEvents({
      "turbo:submit-start": "During a form submission.",
      "turbo:submit-end": "After the form submission-initiated network request completes.",
    });
  }

  // 4. Rendering
  // --------------
  rendering() {
    this.listenToEvents({
      "turbo:before-cache": "Before Turbo saves the current page to cache.",
      "turbo:before-render": "Before rendering the page.",
      "turbo:render": "After Turbo renders the page.",
      "turbo:load": "Once after the initial page load, and again after every Turbo visit.",
    });
  }

  // 5. Turbo Frames
  // ----------------
  turboFrames() {
    this.listenToEvents({
      "turbo:before-frame-render": "Before rendering the turbo-frame element.",
      "turbo:frame-render": "After a turbo-frame element renders its view.",
      "turbo:frame-load": "When a turbo-frame element finishes loading.",
      "turbo:frame-missing":
        "When a response to a turbo-frame request does not contain a matching turbo-frame.",
    });
  }

  // 6. Turbo Streams
  // -----------------
  turboStream() {
    this.listenToEvents({
      "turbo:before-stream-render": "Before rendering a Turbo Stream update.",
      "turbo:stream-render": "A Turbo Stream update has been rendered.",
      "turbo:after-stream-render": "After a Turbo Stream update has been rendered.",
    });
  }

  // 7. Turbo Morph
  // ---------------
  turboMorph() {
    this.listenToEvents({
      "turbo:morph": "After Turbo morphs the page.",
      "turbo:before-morph-element": "Before Turbo morphs an element.",
      "turbo:before-morph-attribute": "Before Turbo morphs an element's attributes.",
      "turbo:morph-element": "After Turbo morphs an element."
    });
  }

  // 8. Listen to Events
  // -------------------
  listenToEvents(events) {
    if (!this._listeners) this._listeners = [];

    Object.entries(events).forEach(([eventName, description]) => {
      const handler = (event) => {
        console.log(`!!! => ${eventName}: ${description}`);
        if (this.debugEventEnabled) {
          console.log(event);
        }

        if (this.debugEventDetailEnabled) {
          if (eventName === "turbo:frame-missing") {
            console.warn("❤️❤️❤️ Missing frame:", event.detail);
          }

          if (eventName === "turbo:before-morph-element") {
            console.log("Before morphing element:", event.detail.newElement);
          }

          if (eventName === "turbo:before-morph-attribute") {
            console.log(
              `Before morphing attribute: ${event.detail.attributeName} | type: ${event.detail.mutationType}`
            );
          }
        }
      };

      document.addEventListener(eventName, handler);
      this._listeners.push({ eventName, handler });
    });
  }
}
