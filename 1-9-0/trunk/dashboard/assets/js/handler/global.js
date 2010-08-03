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

var GlobalHandler = Class.create();

GlobalHandler.prototype = {

	//
	// PROPERTIES
	//
	
	//
	//INITIALIZATION - CONFIGURATION
	//
	initialize: function(_enableLogin, _logoutUrl) {
		var currentObject = this;
		this.enableLogin = _enableLogin;
		this.logoutUrl = _logoutUrl;
		Event.observe(window, 'load', currentObject.fancyRules);
		if (_enableLogin != 0) {
			this.startLogoutTimeout();

			Event.observe(window, 'load', function() {
					$$('a').each(function(element) {
						element.observe('click', currentObject.resetLogoutTimeout.bindAsEventListener(currentObject));
					});
				}
			);
		}
	},
	
	//
	// PUBLIC FUNTIONS
	//	
	fancyRules: function() {
		var hrs = $$('hr');
		
		hrs.each(function(hr) {
		    var newhr = hr; 
		    var wrapdiv = document.createElement('div');
		    wrapdiv.className = 'line';  
		    newhr.parentNode.replaceChild(wrapdiv, newhr);  
		    wrapdiv.appendChild(newhr);			
		});
	},
	
	startLogoutTimeout: function() {
		var currentObject = this;
		this.logoutConfirmTimeout = setTimeout(function() { currentObject.displayLogoutConfirm(); }, this.enableLogin); //
	},
	
	resetLogoutTimeout: function() {
		clearTimeout(this.logoutConfirmTimeout);
		this.startLogoutTimeout();
	},
	
	displayLogoutConfirm: function() {
		var currentObject = this;
		var logoutCountdownTimeout = setTimeout(function() { currentObject.performLogout(); }, 30000);
		
		Dialog.confirm('You will be logged out in 30 seconds.', {
			onConfirm: function(dlg) {
				currentObject.performLogout();
			},
			onCancel: function(dlg) {
				currentObject.startLogoutTimeout();
			}
		});
	},
	
	performLogout: function() {
		window.location.href = this.logoutUrl;
	},
	
	loginRedirect: function() {
		Event.fire(document, 'dashboard:stop');
		Dialog.alert('Your session appears to have expired.  You will asked to log in again and returned here.', {
			onConfirm: function() { location.reload(true) }
			, onCancel:  function() { location.reload(true) }
		});
	}
	
};

var TextAreaResize = Class.create();

TextAreaResize.prototype = {

	/*
	 * PROPERTIES
	*/
	
	/*
	 * 
	 * OPTIONS:
	 * maxRows: integer (default 50)
	 * The maximum number of rows to grow the text area
	 * 
	*/
	
	
	/*
	* INITIALIZATION - CONFIGURATION
	*/
	initialize: function(element, options) {
		this.element = $(element);		
		this.options = Object.extend({maxRows: 50}, options || {} );

		Event.observe(this.element, 'keyup', this.onKeyUp.bindAsEventListener(this));
		this.onKeyUp();
	},

	/*
	* PUBLIC FUNTIONS
	*/	
	onKeyUp: function() {		
		while (this.element.scrollHeight > this.element.offsetHeight && this.element.rows < this.options.maxRows) {
			if (this.element.rows < this.options.maxRows) {
				this.element.rows = this.element.rows + 1;
			}
		}
	}
};