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
 * @fileoverview JavaScript that starts Grits game.
 */


/**
 * An Object representing load status of single instance.  The information is
 * generated and retrned by server in JSON format.
 *
 * @typedef {{
 *   host: string,
 *   ipaddress: string,
 *   status: string,
 *   load: number,
 *   force_set: boolean
 * }}
 */
var JsonSingleInstanceStat;


/**
 * Redirects the browser to Grits game server to start game.
 */
function playGrits() {
  $.getJSON('/getip.json', function(json) {
    if (json['ipaddress']) {
      window.location.replace('http://' + json['ipaddress'] + ':8080/');
    } else {
      showMessage('No Game Server Available.');
    }
  });
}


/**
 * Sets auto-reload of game server cluster status every 5 seconds.
 */
$(function() {
  getStat();
  setInterval(getStat, 5000);
});


/**
 * A class to represent stat information of single instance of game server.
 *
 * @constructor
 * @param {JsonSingleInstanceStat} jsonStat Object passed from server in JSON
 *     that contains load information of the single instance.
 */
function SingleStatForUser(jsonStat) {
  /**
   * Status information of single game server instance.
   * @type {JsonSingleInstanceStat}
   * @private
   */
  this.jsonStat_ = jsonStat;

  /**
   * jQuery instance to represent HTML div box for single game server instance.
   * @type {?jQuery}
   * @private
   */
  this.statBox_ = null;
}


/**
 * Adds DOM structure that shows status of single instance.
 *
 * @return {jQuery} jQuery object to represent the new single stat box.
 */
SingleStatForUser.prototype.createBox = function() {
  this.statBox_ = $('<div class="server-status-user"></div>');
  this.statBox_.attr('id', this.jsonStat_['host']);
  var joinDiv = $('<div class="join"></div>');
  this.statBox_.append(joinDiv);
  joinDiv.html('<a href="http://' + this.jsonStat_['ipaddress'] + ':8080/">' +
               'Join</a>');
  this.statBox_.append('<div class="ip-address-user">' +
                       this.jsonStat_['ipaddress'] + '</div>');
  this.addLoadIndicator_();
  this.statBox_.append('<div class="clear-both"></div>');
  return this.statBox_;
};


/**
 * Tells whether load level is included in the JSON for an instance.
 *
 * @private
 * @return {boolean} Boolean value to indicate whether load level information
 *     for the instance exists.
 */
SingleStatForUser.prototype.hasLoadInfo_ = function() {
  return (this.jsonStat_['load'] != null);
};


/**
 * Displays load level information of a single instance.
 *
 * @param {jQuery} loadBar Container jQuery object for load bar.
 */
SingleStatForUser.prototype.setLoad = function(loadBar) {
  var load = (this.jsonStat_['load'] || 0);
  // 48px per 12.5% (1 user).
  loadBar.css({'width': '' + Math.floor(load / 12) * 48 + 'px'});
  var joinDiv = this.statBox_.find('.join');

  // If load is >= 100%, hide "join" link.
  if (load >= 100) {
    joinDiv.css('visibility', 'hidden');
  } else {
    joinDiv.css('visibility', 'visible');
  }
};


/**
 * Displays load UI of a single instance.  Load UI includes load percentage,
 * bar of the load level, and controls to overwrite actual load level.
 *
 * @private
 */
SingleStatForUser.prototype.addLoadIndicator_ = function() {
  var loadBar = $('<div class="user-count-bar"></div>');
  this.statBox_.append(loadBar);
  this.setLoad(loadBar);
};


/**
 * Updates status of existing instance.  The function updates status of
 * Compute Engine instance and load level of the instance.
 *
 * @param {jQuery} statBox jQuery object to represent the container of single
 *     instance information.
 */
SingleStatForUser.prototype.updateStat = function(statBox) {
  this.statBox_ = statBox;
  if (this.hasLoadInfo_()) {
    var loadBar = this.statBox_.children('.user-count-bar');
    this.setLoad(loadBar);
  }
};


/**
 * Processes stats in JSON and updates UI.
 * @param {Array.<JsonSingleInstanceStat>} json JSON stats returned from server.
 */
function processJsonStats(json) {
  var serverList = $('#server-list');
  var boxes = serverList.children('.server-status-user');
  $.each(json, function(index, jsonStat) {
    var processed = false;
    var singleStat = new SingleStatForUser(jsonStat);
    boxes = boxes.filter(function(i) {
      if (this && $(this).attr('id') == jsonStat['host']) {
        singleStat.updateStat($(this));
        processed = true;
        return false;
      }
      return true;
    });
    if (!processed) {
      serverList.append(singleStat.createBox());
    }
  });
  $.each(boxes, function(index, val) {
    $(val).remove();
  });
}


/**
 * Gets status of game server cluster.  It throws AJAX request to get status
 * information in JSON, and updates status information when successfully
 * queried.
 */
function getStat() {
  $.getJSON('/stats-user.json', function(json) {
    processJsonStats(json);
  });
}
