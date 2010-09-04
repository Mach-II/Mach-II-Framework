/*
 *  Mach-II - A framework for object oriented MVC web applications in CFML
 *  Copyright (C) 2003-2010 GreatBizTools, LLC
 *  
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *  
 *  Linking this library statically or dynamically with other modules is
 *  making a combined work based on this library.  Thus, the terms and
 *  conditions of the GNU General Public License cover the whole
 *  combination.
 *  
 *  As a special exception, the copyright holders of this library give you
 *  permission to link this library with independent modules to produce an
 *  executable, regardless of the license terms of these independent
 *  modules, and to copy and distribute the resultant executable under
 *  the terms of your choice, provided that you also meet, for each linked
 *  independent module, the terms and conditions of the license of that
 *  module.  An independent module is a module which is not derived from
 *  or based on this library and communicates with Mach-II solely through
 *  the public interfaces* (see definition below). If you modify this library,
 *  but you may extend this exception to your version of the library,
 *  but you are not obligated to do so. If you do not wish to do so,
 *  delete this exception statement from your version.
 *  
 *  * An independent module is a module which not derived from or based on
 *  this library with the exception of independent module components that
 *  extend certain Mach-II public interfaces (see README for list of public
 *  interfaces).
 *  
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