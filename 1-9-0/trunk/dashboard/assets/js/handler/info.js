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
 * $Id: generic.js 1269 2009-01-14 22:54:21Z peterfarrell $
 * 
 */
try {
	console.log('init console... done'); 
} catch(e) {
	console = { log: function() {} }
}

var InfoHandler = Class.create();

InfoHandler.prototype = {

	//
	// PROPERTIES
	//
	
	//
	//INITIALIZATION - CONFIGURATION
	//
	initialize: function(_suggestGarbageCollectionUrl, _memoryInformationUrl) {
		this.suggestGarbageCollectionUrl = _suggestGarbageCollectionUrl;
		this.memoryInformationUrl = _memoryInformationUrl;
	
		this.memoryInformation = "";
		this.garbageCollectionTimerStart = "";
		this.garbageCollectionTimerTimeoutId = "";

		this.beginMemoryInformation();
	},
	
	//
	// PUBLIC FUNTIONS
	//	
	beginMemoryInformation: function() {
		var currentObject = this;
		this.memoryInformation = new Ajax.PeriodicalUpdater('memoryInformation'
			, this.memoryInformationUrl
			, {
				frequency: 30
				, decay: 1
				, on403: myGlobalHandler.loginRedirect
			}
		);
		Element.observe(document, 'dashboard:stop', function() { currentObject.stopMemoryInformation(); });
	},
	
	startMemoryInformation: function() {
		this.memoryInformation.start();
	},
	
	stopMemoryInformation: function() {
		this.memoryInformation.stop();
	},
		
	refreshMemoryinformation: function() {
		this.memoryInformation.stop();
		this.memoryInformation.start();
		$('miRun').fade({ duration: 0.5, queue: 'end' });
		$('miInProgress').appear({ duration: 0.5, queue: 'end' })
		$('miInProgress').fade({ duration: 0.5, delay: 1, queue: 'end' });
		$('miRun').appear({ duration: 0.5, queue: 'end' });
	},
		
	suggestGarbageCollection: function() {
		var currentObject = this;
		Dialog.confirm('Suggesting a garbage collection may cause the server to pause and stop accepting requests while a garbage collections occurs. This could take several seconds or more depending on a variety of factors. You\'ve been warned! Are you sure you want to continue?', {
			onConfirm: function(dlg) {
				new Ajax.Request(currentObject.suggestGarbageCollectionUrl, {
					onCreate: function() {
						currentObject.stopMemoryInformation();
						currentObject.startGarbageCollectionTimer();
						$('gcRun').fade({ duration: 0.5, queue: 'end' });
						$('gcInProgress').appear({ duration: 0.5, queue: 'end' });
					}
					, onSuccess: function(transport) {
						currentObject.startMemoryInformation();
						currentObject.stopGarbageCollectionTimer(transport.getHeader("recoveredMemory"));
						$('gcInProgress').fade({ duration: 0.5, queue: 'end' });
						$('gcRun').appear({ duration: 0.5, queue: 'end' });
					}
					, on403: myGlobalHandler.loginRedirect.bindAsEventListener(currentObject)
				});
			}
		});
	},
	
	startGarbageCollectionTimer: function() {
		var currentObject = this;
		this.garbageCollectionTimerStart = new Date().getTime();
		this.garbageCollectionTimerTimeoutId = setInterval(function () { 
			var timeDifference = new Date().getTime() - currentObject.garbageCollectionTimerStart;
			$('gcInProgressCount').update((timeDifference / 1000).floor() + ' seconds');
		}, 250);
	},
	
	stopGarbageCollectionTimer: function(recoveredMemory) {
		clearInterval(this.garbageCollectionTimerTimeoutId);
		var timeDifference = new Date().getTime() - this.garbageCollectionTimerStart;
		$('messageBoxText').update('Suggested garbage collection recovered ' + recoveredMemory + ' of memory and finished in ' + (timeDifference / 1000).floor() + ' seconds.');
		new Effect.BlindDown('messageBox', { queue: 'end' });
		timeoutId = setInterval(function() { 
			new Effect.BlindUp('messageBox', { queue: 'end' });
			clearTimeout(timeoutId);
		}, 6000);
	}
}