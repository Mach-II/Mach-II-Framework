/*
 * License:
 * Copyright 2009-2010 GreatBizTools, LLC
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Copyright: GreatBizTools, LLC
 * Author: Peter J. Farrell (peter@mach-ii.com)
 * $Id$
 * 
 */
try {
	console.log('init console... done');
} catch(e) {
	console = { log: function() {} };
}

var ConfigHandler = Class.create();

ConfigHandler.prototype = {

	//
	// PROPERTIES
	//
	updater: null,
	reloadAllChangedComponentsUrl: '',
	refreshAllChangedComponents: '',

	//
	//INITIALIZATION - CONFIGURATION
	//
	initialize: function(_reloadAllChangedComponentsUrl, _refreshAllChangedComponentsUrl) {
		this.reloadAllChangedComponentsUrl = _reloadAllChangedComponentsUrl;
		this.refreshAllChangedComponentsUrl = _refreshAllChangedComponentsUrl;
	},

	//
	// PUBLIC FUNTIONS
	//	
	periodicUpdateChangedComponents: function() {
		var currentValue = $('reloadAllChangedComponentsValue').value;

		console.log(currentValue);

		if (this.updater != null) {
			this.updater.stop();
		}

		if (currentValue != 0) {
			this.updater = new Ajax.PeriodicalUpdater('changedComponents'
				, this.reloadAllChangedComponentsUrl
				, {
					frequency: currentValue
					, decay: 1
				}
			);
		} else {
			if (this.updater != null) {
				this.updater.stop();
			}
		}
	},

	updateChangedComponents: function() {
		if (this.updater != null) {
			this.updater.stop();
		}

		new Ajax.Updater('changedComponents'
			, this.refreshAllChangedComponentsUrl
			, {}
		);

		this.periodicUpdateChangedComponents();
	},
	
	reloadAllChangedComponents: function() {
		
		if (this.updater != null) {
			this.updater.stop();
		}
		
		new Ajax.Updater('changedComponents'
			, this.reloadAllChangedComponentsUrl
			, {}
		);
		
		this.periodicUpdateChangedComponents();
	}
}