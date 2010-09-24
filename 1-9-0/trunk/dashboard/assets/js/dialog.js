/*  js.Dialog JavaScript library, version 0.1.3 (19.11.2008)
 *  © 2008 by Sascha René Leib
 *
 *  This library is freely distributable under the terms of an MIT-style license.
 *  For details or updates, see http://code.kolmio.com/jsdialog
 *--------------------------------------------------------------------------*/

var Dialog = {
	// global settings:
	settings:	{
					overlayBG: 'black',	// background of the overlay screen
					overlayOpacity: 0.6, // 1.0 = completely opaque, 0.0 = fully transparent
					titleBG: '#ccc',	// background for the dialog title
					dialogBG: '#eee',	// background of the dialog (except title)
					dialogContainerBG: '#333', // background of the container
					dialogOpacity: 1,	// default-opacity of the container
					cancelWhenOverlayIsClicked:	true	// cancels all dialogs if the user clicks on the overlay
				}
};

/**
 * The core functionality for all dialogs:
**/
Dialog.Core = Class.create({

	uniqueId: 0,	// will be initialized to a (hopefully) unique random number.

	dlgObject: null,	// reference to the object's 'root' element.
	
	_options: {},	// settings will be stored here.

	initialize: function(options)
		{
			// the default settings:
			this._options = {
					title: 'Dialog',
					zIndex: 32750, // the  layer for the dialog
					modal: false,	// should the overlay be inserted?
					onLoad: null	// called after the dialog has been loaded
				};
			
			// overwrite settings if user-supplied:
			Object.extend(this._options, options || { });
			
			// give this instance a (hopefully) unique id:
			this.uniqueId = Math.ceil(Math.random()*4294967296); // = 2^32
			// I reckon there will be few cases where there are more than 2-3 dialogs open at a time, so this is probably good enough.

		},
	
	/**
	 * Returns true, if this dialog is supposedly modal
	**/
	isModal: function()
		{
			return this._options.modal;
		},
	
	/**
	 * (Overridable function)
	**/
	show: function(options)
		{
			// merge the options:
			var opt = {
				msg: '{unset}',
				modal:	true,
				onButtonClick: null
			};
			Object.extend(opt, options || {});
			
			// build the body node:
			var body = Builder.node('p', {}, opt.msg);
			
			// show it in the appropriate way:
			if (opt.modal) {
				this._showModalFrame(body);
			} else {
				this._showFrame(body);
			};
		},
	
	/**
	 * Cancels the dialog. This does the same as "hide", but it may be overridden:
	**/
	cancel: function()
		{
			this.hide();
		},
	
	/**
	 * Hides the dialog
	**/
	hide: function()
		{
			this.dlgObject.hide();
			
			// remove it from the list of open dialogs:
			Dialog.unregister(this.uniqueId);
		},
	
	/**
	 * The following function should get called when a button is clicked:
	**/
	_clickButton: function(num)
		{
			// allow the caller to override the behaviour:
			if (Object.isFunction(this._options.onButtonClick)) 
				if (!this._options.onButtonClick(this, num))
					return;
			
			// other things to do:
			switch(num) {
			case 0: // the cancel button
				this.cancel();
				break;
			case 1: // the OK button
				this.hide(); // simply hide it.
				break;
			case 2: // the Help button
			}
		},
	
	/**
	 * Shows the dialog frame as a modal dialog
	 **/
	_showModalFrame: function(node)
		{
			// simply override the option:
			this._options.modal = true;
			
			// now create and show the dialog box:
			this._showFrame(node);
		},
		
	/**
	 * Shows the dialog frame as specified by the settings
	 **/
	_showFrame: function(node)
		{
			if (this._options.modal) {
				// insert & display the overlay:
				document.body.appendChild(this._getOverlayNode());
				Effect.Appear('modalDlgOverlay', {from: 0.0, to: Dialog.settings.overlayOpacity});
			};
		
			// create and show the dialog box:
			var dlg = this._getFrameNode(node);
			this.dlgObject = dlg;
			document.body.appendChild(dlg);
			
			// make the dialog moveable:
			new Draggable(dlg, { handle: $('dlgHeader-'+this.uniqueId) });
			
			// ready to show:
			dlg.show();
			
			// register this item in the global registry (IMPORTANT!)
			Dialog.register(this);
			
			// it's done. now run the 'onLoad' event:
			if (Object.isFunction(this._options.onLoad)) {
				this._options.onLoad(this);
			};
		},
	_getOverlayNode: function()
		{
			// if an overlay exists, get that one:
			var olset = $$('div#modalDlgOverlay');
			
			if (olset.length > 0) {
				var overlay = olset[0];
			} else { // otherwise make new one:

				var set = {
					id: 'modalDlgOverlay',
					style: 'display:none;position:fixed;left:0;top:0;width:100%;height:100%;z-index:32700;background:'+Dialog.settings.overlayBG+';opacity:'+Dialog.settings.overlayOpacity+';'
				};
				
				if (Dialog.settings.cancelWhenOverlayIsClicked) {
					set.onclick = 'Dialog.cancelAll();';
				};
			
				overlay = Builder.node('div', set);
			};
			
			return overlay;
		},
	_getFrameNode: function(node)
		{
			var dlg = Builder.node('div', { className: 'DlgContainer', id: 'dialog-'+this.uniqueId,
						style: 'position:fixed;top:20%;left:25%;width:50%;height:auto;z-index:'+this._options.zIndex+';margin:auto;background:'+Dialog.settings.dialogContainerBG+';opacity:'+Dialog.settings.dialogOpacity+';' });
			var frame = Builder.node('div', { className: 'DlgFrame', id: 'dlgFrm-'+this.uniqueId,
						style: 'background:'+Dialog.settings.dialogBG+';opacity:1.0;min-width:26em;'}, [
					Builder.node('div', { className: 'DlgHeader', id: 'dlgHeader-'+this.uniqueId,
							style: 'cursor:move;background:'+Dialog.settings.titleBG+';' }, [
						Builder.node('span', { className: 'DlgClosebox', id: 'dlgCloseBox-'+this.uniqueId,
								onclick: 'Dialog.cancel('+this.uniqueId+');',
								style: 'float:right;cursor:pointer;'}, '×'),
						this._options.title
					]),
					node
				]);
			dlg.appendChild(frame);
			
			return dlg;
		}
	
});

/**
 * The core class for simple dialogs
**/
Dialog.Simple = Class.create(Dialog.Core, {

	/**
	 * Initialization of the dialog object:
	**/
	initialize: function($super, settings)
		{
			$super(settings);
		},
	/**
	 * Keep a reference to the form object:
	**/
	_form: null,	
	/**
	 * Show the dialog
	**/
	show: function(msg, options)
		{
			// Set the default dialog options:
			var opt = {
				title: 'Dialog',
				detail: null,
				input: null,
				button0: null,
				button1: 'OK',
				button2: null,
				modal: true,
				onLoad: function(dlg) {	// after the dialog is loaded, set focus on the first form element:
						if (dlg._form) {
							Element.extend(dlg._form).focusFirstElement();
						};
					},
				onButtonClick: function(dlg, num) { // when a button has been clicked
						if(num==0) { // Cancel-Button
							dlg.cancel();
						} else if (num==1) { // OK-Button
							dlg.confirm();
						} else { // Other Button
							dlg.otherButton()
						}
					},
				onCancel: null,	// called if the dialog is cancelled
				onConfirm: null,	// called when the dialog is confirmed
				onOtherButton: null	// called when the other button is pressed.
			};

			// if necessary, overwrite the options:
			Object.extend(opt, (options || { }));
			Object.extend(this._options, opt);

			// make msg overwridable:
			msg = (Object.isUndefined(msg) ? this._options.msg : msg);
			
			// Get the dialog body node, and the main text:
			var node = Builder.node('div', {className: 'DlgBody', style: 'padding:.5em;' }, [
					Builder.node('p', {className: 'DlgMainText' }, msg)
				]);

			// if a detail text is supplied, add this node, too:
			if (this._options.detail) {
				node.appendChild(Builder.node('p', {className: 'DlgDetailText' }, opt.detail));
			};

			//create the form:
			var form = Builder.node('form', {onsubmit: 'return false;'});
			this._form = form;
			
			// is there an input field?
			if (!Object.isUndefined(opt.input) && opt.input!=null) {
				form.appendChild(Builder.node('input', {type: 'text', id: 'dlgTextField-'+this.uniqueId, value: opt.input}));
			};
			
			// Styles that depend on the number of buttons:
			var btn1Style = ((opt.button0==null && opt.button2==null) ? '' : 'float:right;');
			var areaStyle = ((opt.button0==null && opt.button2==null) ? 'text-align:right;' : '');
			
			// finally, add a div to store the buttons:
			var btnArea = Builder.node('div', {className: 'DlgButtonArea', style: 'width:90%;margin-left:auto; margin-right:auto;'+areaStyle });
			if (opt.button1) {
				btnArea.appendChild(Builder.node('input', {className: 'DlgButton1', type: 'submit',  onclick: 'Dialog.getById('+this.uniqueId+')._clickButton(1);return false;', value: opt.button1, style: btn1Style}));
			};
			if (opt.button0) {
				btnArea.appendChild(Builder.node('input', {className: 'DlgButton0', type: 'reset',  onclick: 'Dialog.getById('+this.uniqueId+')._clickButton(0);return false;', value: opt.button0 }));
			};
			if (opt.button2) {
				btnArea.appendChild(Builder.node('input', {className: 'DlgButton2', type: 'button',  onclick: 'Dialog.getById('+this.uniqueId+')._clickButton(2);return false;', value: opt.button2, style: 'margin-left:2em;margin-right:2em;'}));
			};
			form.appendChild(btnArea);
			node.appendChild(form);

			// show the dialog:
			this._showFrame(node);
		},
	
	/**
	 * returns the text in the entry field if available
	 * or null otherwise.
	**/
	getText: function()
		{
			if (!Object.isUndefined(this._options.input)) {
				return $F('dlgTextField-'+this.uniqueId);
			} else {
				return null;
			};
		},
	
	/**
	 * Cancel the dialog
	**/
	cancel: function()
		{
			// allow the caller to override the behaviour:
			if (Object.isFunction(this._options.onCancel)) {
				var r = this._options.onCancel(this);
				if (!Object.isUndefined(r) && !r) {
					return; // do not close the dialog!
				};
			};

			// hide & remove:
			this.hide();
		},
		
	/**
	 * Confirms the dialog
	**/
	confirm: function()
		{
			// allow the caller to override the behaviour:
			if (Object.isFunction(this._options.onConfirm))  {
				var r = this._options.onConfirm(this);
				if (!Object.isUndefined(r) && !r) {
					return; // do not close the dialog!
				};
			};

			// hide & remove:
			this.hide();

		},
	/**
	 * Called when the "other" button" is pressed
	**/
	otherButton: function()
		{
			// call the appropriate callback function:
			if (Object.isFunction(this._options.onOtherButton)) 
				this._options.onOtherButton(this);

			// no automatic hiding here!
		}
	});

/* *** Global Registry for Dialogs: *** */
/**
 * The following Hash obeject keeps a registry of all open dialog objects:
**/
Dialog._registry = $H();

/**
 * Returns the dialog element with the passed uid or null if not available
**/
Dialog.getById = function(uid)
	{
		var dlg = Dialog._registry.get(uid)
		return dlg;
	};
	
/**
 * Stores a dialog object in the registry:
**/
Dialog.register = function(dc)
	{
		Dialog._registry.set(dc.uniqueId, dc);
	};

/**
 * Removes a dialog object from the registry *and* the DOM.
 * If this was the last modal dialog, the overlay is also removed.
**/
Dialog.unregister = function(uid)
	{
		// remove item from the registry:
		var obj = Dialog._registry.unset(uid);
		
		// remove elements from DOM:
		var elements = $$('body>#dialog-'+obj.uniqueId)
		elements.each(function(it) {
				// it.hide();
				document.body.removeChild(it);
			});

		// find out if the overlay is still needed:
		var overlays = $$('#modalDlgOverlay');
		if (overlays.size() > 0) {	// is there one at all?
			
			var removeOverlay = (Dialog._registry.size()==0);
			if (!removeOverlay) {
				Dialog._registry.each(function(dlg) {
					if (!dlg.value.isModal()) {
						removeOverlay = true;
						throw $break;
					}
				})
			};
			
			// remove the overlay, if not needed any longer:
			if(removeOverlay) {
				overlays.each(function(item) {
					document.body.removeChild(item);
				});
			};
		};
	};

/* *** Utility Functions *** */
	
/**
 * Cancels a dialog with the given number:
**/
Dialog.cancel = function(uid)
	{
		var dlg = Dialog._registry.get(uid);
		dlg.cancel();
	};
	
/**
 * Cancels all (!) dialogs
**/
Dialog.cancelAll = function()
	{
		var dlgs = Dialog._registry.values();
		
		dlgs.each(function(item) {
			item.cancel();
		});
	
	},

/* *** Simple predefined dialogs: *** */

/**
 * Drop-in replacement for the JS 'alert' function.
**/
Dialog.alert = function(msg, options)
	{
		// get the simple dialog 
		var simpleDlg = new Dialog.Simple();

		// Set the default dialog options:
		var opt = {
			title: 'Alert Dialog',
			detail: null,
			input:	null,
			button0: null,
			button1: 'OK',
			button2: null,
			modal: true,
			onButtonClick: function(dlg, num) {
				dlg.confirm();
			}
		};

		// merge with custom options:
		Object.extend(opt, (options || { }));
		
		// show dialog:
		simpleDlg.show(msg, opt);
	};

/**
 * Drop-in replacement for the JS 'confirm' function.
**/
Dialog.confirm = function(msg, options)
	{
		// get the simple dialog 
		var simpleDlg = new Dialog.Simple();

		// Set the dialog options:
		var opt = {
			title: 'Confirm Dialog',
			detail: null,
			input:	null,
			button0: 'Cancel',
			button1: 'OK',
			button2: null,
			modal: true,
			onCancel: null,
			onConfirm: null,
			onOtherButton: null
		};

		// merge with options:
		Object.extend(opt, (options || { }));

		// show dialog:
		simpleDlg.show(msg, opt);
		
		// return the dialog (so it can be checked for values.
		return simpleDlg;
	};

/**
 * Drop-in replacement for the JS 'prompt' function.
**/
Dialog.prompt = function(msg, options)
	{
		// get the simple dialog 
		var simpleDlg = new Dialog.Simple();

		// Set the default dialog options:
		var opt = {
			title: 'Prompt Dialog',
			detail: null,
			input:	'',
			button0: 'Cancel',
			button1: 'OK',
			button2: null,
			modal: true,
			onButtonClick: function(dlg, num) {
					if (num==0) { // Cancel-Button
						dlg.cancel();
					} else if (num==1) { // if(num==1) {
						dlg.confirm();
					} else { // can only be 2:
						dlg.otherButton();
					};
				},
			onCancel: null,
			onConfirm: null,
			onOtherButton: null
		};

		// merge with options:
		Object.extend(opt, (options || { }));

		// show dialog:
		simpleDlg.show(msg, opt);
		
		// return the dialog (so it can be checked for values.
		return simpleDlg;
	};