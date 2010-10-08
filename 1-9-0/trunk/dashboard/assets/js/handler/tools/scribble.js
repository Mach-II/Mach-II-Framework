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
 * $Id: generic.js 1269 2009-01-14 22:54:21Z peterfarrell $
 * 
 */
try {
	console.log('init console... done'); 
} catch(e) {
	console = { log: function() {} }
}

var ScribbleHandler = Class.create();

ScribbleHandler.prototype = {

	//
	// PROPERTIES
	//
	
	//
	//INITIALIZATION - CONFIGURATION
	//
	initialize: function() {
	},

	//
	// PUBLIC FUNTIONS
	//
	processScribble: function(event) {
		// stop the form from submitting first in case we encounter an error
		Event.stop(event);
		
	    $('processScribble').request({
	    	parameters: {
				evalJS: true
			},
			onCreate: function() {
				$('resultsTitle').scrollTo();
			},
	        onSuccess: function(transport) {
	            $('results').update(transport.responseText);
	        }
	    });	
	},
	
	promptPasteBin: function(event) {		
		var dlg = new Dialog.PasteBin();
		$('code').setValue(editor.getCode());

		
		dlg.show('', {
			onConfirm: function(dlg) {				
				$('pasteBinForm').request({
					onSuccess: function(transport) {
						console.log('onSuccess');
						$('pasteBinInput').value = transport.getHeader('pasteBinUrl');
						$('pasteBinUrlValue').href = transport.getHeader('pasteBinUrl');
						Effect.BlindDown('pasteBinUrlBox');

					}.bind(this)
					, onFailure: function(transport) {
						$('pasteBinInput').value = 'Failed';
						$('pasteBinUrl').hide();
						Effect.BlindDown('pasteBinUrlBox');
					}
				});
				
			}.bind(this)
		});
	},
	
	successPasteBin: function(transport) {
		console.log("successPasteBin");
		dump(transport);
		alert(transport.getHeader('pasteBinUrl'));
		$F('pasteBinUrl').setValue(transport.getHeader('pasteBinUrl'));
		Effect.BlindDown('pasteBinUrlBox');
	}
};

Dialog.PasteBin = Class.create(Dialog.Core, {
	//
	// PROPERTIES
	//
	_form:	null,
	
	//
	// PUBLIC FUNCTIONS
	//			
	show: function(msg, options) {
		// Set the default dialog options:
		var opt = {
			title: 'Share on PasteBin',
			detail: null,
			button0: 'Cancel',
			button1: 'OK',
			modal: true,
			onLoad: function(dlg)	// after the dialog is loaded, set focus on the first form element:
				{	Element.extend(dlg._form).focusFirstElement();
				},
			onButtonClick: function(dlg, num)
				{	if(num==0) { // Cancel-Button
						dlg.cancel();
					} else { // OK-Button
						dlg.confirm();
					}
				},
			onCancel: null,
			onConfirm: null
		};

		// if necessary, overwrite the options:
		Object.extend(opt, (options || { }));
		Object.extend(this._options, opt);
		
		// create the dialog form:
		var form = Builder.node('form', {onsubmit: 'return false;', id: 'pasteBinForm', action: pasteBinUrl, method: 'post' }, [
				Builder.node('label', {HtmlFor: 'paste_name'+this.uniqueId }, 'Name / Title (optional):'),
				Builder.node('input', {id: 'paste_name'+this.uniqueId, name: 'paste_name', type: 'text' }),
				Builder.node('label', {HtmlFor: 'paste_email-'+this.uniqueId }, 'Email (optional):'),
				Builder.node('input', {id: 'paste_email-'+this.uniqueId, name: 'paste_email', type: 'text' }),
				Builder.node('input', {id: 'paste_code-'+this.uniqueId, name: 'paste_code', type: 'hidden', value: $F('code') }),
				Builder.node('div', {className: 'DlgButtonArea', style: 'width:90%;margin-left:auto; margin-right:auto;'}, [
					Builder.node('input', {className: 'DlgButton1', type: 'submit',  onclick: 'Dialog.getById('+this.uniqueId+')._clickButton(1);return false;', value: opt.button1, style: 'float:right'}),
					Builder.node('input', {className: 'DlgButton0', type: 'reset',  onclick: 'Dialog.getById('+this.uniqueId+')._clickButton(0);return false;', value: opt.button0 })
				])
			]);
		
		// Get the dialog body node, and the main text:
		var node = Builder.node('div', {className: 'DlgBody', style: 'padding:.5em;' }, [
				Builder.node('p', {className: 'DlgMainText' }, msg)
			]);
		
		// if a detail text is supplied, add this node, too:
		if (this._options.detail) {
			node.appendChild(Builder.node('p', {className: 'DlgDetailText' }, opt.detail));
		};
		
		// append the form:
		node.appendChild(form);
		this._form = form;

		// show the dialog:
			this._showFrame(node);

	},
		
		cancel: function () {
			// allow the caller to override the behavior:
			if (Object.isFunction(this._options.onCancel))  {
				var r = this._options.onCancel(this);
				if (!Object.isUndefined(r) && !r) {
					return; // do not close the dialog!
				};
			};

			// hide & remove:
			this.hide();		
		},
		
		confirm: function() {
			// allow the caller to override the behavior:
			if (Object.isFunction(this._options.onConfirm))  {
				var r = this._options.onConfirm(this);
				if (!Object.isUndefined(r) && !r) {
					return; // do not close the dialog!
				};
			};

			// hide & remove:
			this.hide();
		}
	}
);