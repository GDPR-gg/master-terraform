// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * @fileoverview JavaScript module for global message to users on UI.
 */


/**
 * Class to manage message to users shown on screen.
 *
 * @constructor
 * @param {boolean} hideOnServerRunning Whether message should be deleted
 *     when at least one server is up and running.  If this is false,
 *     message automatically disappears after a while.
 */
function Message(hideOnServerRunning) {
  /**
   * Boolean value to indicate whether the message should be deleted when
   * at least one server is up.
   * @type {boolean}
   */
  this.hideOnServerRunning = hideOnServerRunning;
}


/**
 * @private
 * @return {boolean} Whether the message should be automatically hidden.
 */
Message.prototype.automaticallyHides_ = function() {
  return !this.hideOnServerRunning;
};


/**
 * Displays message on the page.
 *
 * @param {string} message Message text.
 */
Message.prototype.showMessage = function(message) {
  messageDiv = $('.message').text(message).show();
  if (this.automaticallyHides_()) {
    // CSS class 'fade-out' fades out the message box in 5 seconds.
    messageDiv.addClass('fade-out');
    setTimeout(this.hideMessage.bind(this), 5000);
  } else {
    // Infinitely blinks until manually hidden.
    messageDiv.addClass('infinite-blink');
  }
};


/**
 * Hides message.
 */
Message.prototype.hideMessage = function() {
  $('.message').hide().removeClass('fade-out infinite-blink');
  globalMessage = null;
};


/**
 * Holds the current Message instance.
 * @type {?Message}
 */
globalMessage = null;


/**
 * Displays message.
 *
 * @param {string} message Message text.
 * @param {boolean} hideOnServerRunning Whether message should be deleted
 *     when at least one server is up and running.
 */
function showMessage(message, hideOnServerRunning) {
  globalMessage = new Message(hideOnServerRunning);
  globalMessage.showMessage(message);
}
