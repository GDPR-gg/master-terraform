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
 * @fileoverview JavaScript that handles cluster status UI on stats.html.
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
function SingleStatForAdmin(jsonStat) {
  this.jsonStat = jsonStat;
}


/**
 * Adds DOM structure that shows status of single instance.
 *
 * @return {jQuery} jQuery object to represent the new single stat box.
 */
SingleStatForAdmin.prototype.createBox = function() {
  var statBox = $('<div class="hostinfo-container"></div>');
  statBox.attr('id', this.jsonStat['host']);
  statBox.append('<div class="host">' + this.jsonStat['host'] + '</div>');
  statBox.append('<div class="ip-address">' + this.jsonStat['ipaddress'] +
                 '</div>');
  statBox.append('<div class="status">' + this.jsonStat['status'] + '</div>');
  if (this.hasLoadInfo()) {
    this.addLoadIndicator(statBox);
  }
  statBox.append('<div class="clear-both"></div>');
  return statBox;
};


/**
 * Tells whether load level is included in the JSON for an instance.
 *
 * @return {boolean} Boolean value to indicate whether load level information
 *     for the instance exists.
 */
SingleStatForAdmin.prototype.hasLoadInfo = function() {
  return (this.jsonStat['load'] != null);
};


/**
 * Decide color of the bar by load level of the instance.
 *
 * @private
 * @param {number} load Load level of one instance in [0-100] integer.
 * @return {string} Name of the color used as part of CSS class name.
 */
SingleStatForAdmin.prototype.getColor_ = function(load) {
  return (load < 60 ? 'green' : (load < 80 ? 'yellow' : 'red'));
};


/**
 * Displays load level information of a single instance.
 *
 * @param {jQuery} loadBox Container jQuery object for load information.
 * @param {jQuery} loadBar Container jQuery object for load bar.
 */
SingleStatForAdmin.prototype.setLoad = function(loadBox, loadBar) {
  var load = this.jsonStat['load'];
  loadBox.text('' + load + '%');
  if (this.jsonStat['force_set']) {
    loadBox.addClass('force-set');
  } else {
    loadBox.removeClass('force-set');
  }
  loadBar.addClass('bar-' + this.getColor_(load));
  loadBar.css({'width': '' + load * 2 + 'px',
               'margin-right': '' + 215 - load * 2 + 'px'});
};


/**
 * Displays load UI of a single instance.  Load UI includes load percentage,
 * bar of the load level, and controls to overwrite actual load level.
 *
 * @param {jQuery} statBox jQuery object to represent the container of single
 *     instance information.
 */
SingleStatForAdmin.prototype.addLoadIndicator = function(statBox) {
  var loadBox = $('<div class="load"></div>');
  statBox.append(loadBox);
  var loadBar = $('<div class="load-bar"></div>');
  statBox.append(loadBar);
  this.setLoad(loadBox, loadBar);
  statBox.append('<div class="load-input-container">' +
                 '<input type="text" class="load-input" /></div>');
  statBox.append('<div class="grits-button debug-button"' +
                 '     onclick="forceSetLoad(this)">set</div>');
  statBox.append('<div class="grits-button debug-button"' +
                 '     onclick="resetLoad(this)">reset</div>');
};


/**
 * Updates status of existing instance.  The function updates status of
 * Compute Engine instance and load level of the instance.
 *
 * @param {jQuery} statBox jQuery object to represent the container of single
 *     instance information.
 */
SingleStatForAdmin.prototype.updateStat = function(statBox) {
  statBox.children('.status').text(this.jsonStat['status']);
  if (this.hasLoadInfo()) {
    if (statBox.children('.load').length == 0) {
      statBox.remove('.clear-both');
      this.addLoadIndicator(statBox);
      statBox.append('<div class="clear-both"></div>');
    } else {
      var loadBox = statBox.children('.load');
      var loadBar = statBox.children('.load-bar');
      loadBar.removeClass('bar-green bar-yellow bar-red');
      this.setLoad(loadBox, loadBar);
    }
  }
};


/**
 * Processes stats in JSON and updates UI.
 * @param {Array.<JsonSingleInstanceStat>} json JSON stats returned from server.
 */
function processJsonStats(json) {
  var statsTable = $('#stats-table');
  var boxes = statsTable.children('.hostinfo-container');
  $.each(json, function(index, jsonStat) {
    var processed = false;
    var singleStat = new SingleStatForAdmin(jsonStat);
    boxes = boxes.filter(function(i) {
      if (this && $(this).attr('id') == jsonStat['host']) {
        singleStat.updateStat($(this));
        processed = true;
        return false;
      }
      return true;
    });
    if (!processed) {
      statsTable.append(singleStat.createBox());
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
  $.getJSON('/stats.json', function(json) {
    if (json.length && globalMessage && globalMessage.hideOnServerRunning) {
      globalMessage.hideMessage();
    }
    $('#worker-count').text(json.length);
    processJsonStats(json);
  });
}


/**
 * Sends request to start up game server cluster.
 */
function startUp() {
  $.get('/startup');
  showMessage('Game Cluster Starting...', true);
}


/**
 * Sends request to shut down all game server instances.
 */
function tearDown() {
  $.get('/teardown');
  showMessage('Shutting Down Game Cluster...', false);
}


/**
 * Forcibly sets load level for the instance.  It's initiated by UI button and
 * is used for demo and debugging purpose.  When the load level is forcibly
 * set, cluster manager doesn't accept regular load level reports from that
 * instance.
 *
 * @param {Element} button DOM element to indicate the button that initiated
 *     this function.  The button keeps the name of the instance in its "id"
 *     attribute.
 */
function forceSetLoad(button) {
  var parentBox = $(button).parent();
  var name = parentBox.attr('id');
  var loadInputBox = parentBox.find('.load-input');
  var loadValue = loadInputBox.val();
  loadInputBox.val('');
  $.post('/load', {'name': name, 'load': loadValue, 'force': 1}, function() {
    getStat();
  });
}


/**
 * Unset "force-set" flag of load level.  After the force flag is cleared,
 * cluster manager accepts regular load level reports from that instance,
 * and updates the load level of the instance..
 *
 * @param {Element} button DOM element to indicate the button that initiated
 *     this function.  The button keeps the name of the instance in its "id"
 *     attribute.
 */
function resetLoad(button) {
  var parentBox = $(button).parent();
  var name = parentBox.attr('id');
  var loadValue = parentBox.find('.load-input').val();
  $.post('/load', {'name': name, 'force': 0}, function() {
    getStat();
  });
}
