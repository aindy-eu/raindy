import { Controller } from "@hotwired/stimulus";

/**
 * BaseController - Parent class for all Stimulus controllers
 * 
 * All controllers should follow this structure:
 * 1. Static Definitions (targets, values, etc.)
 * 2. Lifecycle Methods (connect, disconnect)
 * 3. Target Lifecycle Methods (alphabetical)
 * 4a. Public Action Methods (alphabetical)
 * 4b. Public Dispatch Action Methods (alphabetical)
 * 5. Private Helper Methods (alphabetical) 
 * 6. Getters / Setters / Computed Properties (alphabetical)
 * 
 * See docs/architecture/stimulus-guidelines.md for more details
 */
export default class BaseController extends Controller {
  // 1. Static Definitions
  // (No static targets/values in base controller)

  // 2. Lifecycle Methods
  // ---------------------- 
  connect(debug = false) {
    this._debug = debug;
  
    // Cache the environment check
    this._shouldLog = this.#shouldLog();
    this.logControllerName();
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------
  // (None in base controller)

  // 4a. Public Action Methods (alphabetical)
  // ----------------------
  logControllerName() {
    if (this._debug && this._shouldLog) console.log(`${this.context.module.definition.identifier} ctr`);
  }

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------
  // (None in base controller)

  // 5. Private Helper Methods (alphabetical)
  // ----------------------
  #shouldLog() {
    const railsEnv = document.querySelector("meta[name='environment']")?.content;
    return railsEnv !== "production"; // Only log in non-production environments
  }
  
  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
  // (None in base controller)
}
