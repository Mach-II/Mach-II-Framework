/*
 *
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
	
 * Author: Peter J. Farrell (peter@mach-ii.com)
 * $Id$
 * 
 */
try {
	console.log('init console... done');
} catch(e) {
	console = { log: function() {} };
}

Ajax.PeriodicalUpdaterCompleteCallback=Class.create(Ajax.Base,
		{initialize:function($super,container,url,options){
			$super(options);
			this.onComplete=this.options.onComplete;
			this.frequency=(this.options.frequency||2);
			this.decay=(this.options.decay||1);
			this.updater={};
			this.container=container;
			this.url=url;
			this.start();}
		,start:function(){
			this.options.onComplete=this.updateComplete.bind(this);
			this.onTimerEvent();}
		,stop:function(){
			this.updater.options.onComplete=undefined;
			clearTimeout(this.timer);
			(this.onComplete||Prototype.emptyFunction).apply(this,arguments);}
		,updateComplete:function(response){
			if(this.options.decay){this.decay=(response.responseText==this.lastText?this.decay*this.options.decay:1);this.lastText=response.responseText;}
			this.timer=this.onTimerEvent.bind(this).delay(this.decay*this.frequency);
			// bug with Prototype, call onComplete here if specified
			if (this.onComplete) {
				this.onComplete(response);
			}}
		,onTimerEvent:function(){
			this.updater=new Ajax.Updater(this.container,this.url,this.options);}});

var ConfigHandler = Class.create();

ConfigHandler.prototype = {

	//
	// PROPERTIES
	//
	updater: null,
	reloadAllChangedComponentsUrl: '',
	refreshAllChangedComponents: '',
	openFileUrl: '',

	//
	//INITIALIZATION - CONFIGURATION
	//
	initialize: function(_reloadAllChangedComponentsUrl, _refreshAllChangedComponentsUrl, _openFileUrl) {
		this.reloadAllChangedComponentsUrl = _reloadAllChangedComponentsUrl;
		this.refreshAllChangedComponentsUrl = _refreshAllChangedComponentsUrl;
		this.openFileUrl = _openFileUrl;
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
			this.updater = new Ajax.PeriodicalUpdaterCompleteCallback('changedComponents'
				, this.reloadAllChangedComponentsUrl
				, {
					frequency: currentValue
					, decay: 1
					, onComplete: this.updateChangeLog
				}
			);
		} else {
			if (this.updater != null) {
				this.updater.stop();
			}
		}
	},
	
	updateChangeLog: function() {
		$$("div##changedComponentsMessage div.messageBox div p").each(function(node) {
			$("changedComponentsLogDetails").insert({'before': node.innerHTML + '<br/>'})
			$("changedComponentsLog").show();
		});
	},

	updateChangedComponents: function() {
		if (this.updater != null) {
			this.updater.stop();
		}

		new Ajax.Updater('changedComponents'
			, this.refreshAllChangedComponentsUrl
			, { onComplete: this.updateChangeLog }
		);

		this.periodicUpdateChangedComponents();
	},
	
	reloadAllChangedComponents: function() {
		
		if (this.updater != null) {
			this.updater.stop();
		}
		
		new Ajax.Updater('changedComponents'
			, this.reloadAllChangedComponentsUrl
			, { evalScripts: true
				, onComplete: this.updateChangeLog }
		);
		
		this.periodicUpdateChangedComponents();
	},
	
	openInCFBuilder: function(cfctype) {
		var currentObject = this;
		var arequest = new Ajax.Request(this.openFileUrl, {
			method: 'post',
			parameters: { filename: cfctype },
			onSuccess: function(transport) {
				// empty for now
			}
		});
	}
}