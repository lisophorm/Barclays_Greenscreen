package uk.co.huydinh.app.champion
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Expo;
	
	import fl.controls.ComboBox;
	import fl.controls.UIScrollBar;
	import fl.data.DataProvider;
	import fl.text.TLFTextField;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.Direction;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import mdm.Alert2;
	import mdm.Application;
	import mdm.Dialogs;
	import mdm.FileSystem;
	import mdm.Image;
	import mdm.System;
	
	import uk.co.huydinh.app.champion.keyboard.OnScreenKeyboard;
	import uk.co.huydinh.utils.AssetLoader;
	
	public class Champion extends MovieClip
	{
		protected static const WAIT_MORE_SECONDS:int = 2; // Seconds to wait after photoshop has finished processing
		protected static const WAIT_PHOTOSHOP_SECONDS:int = 120; // Seconds to wait for Photoshop to process the image
		protected static const INACTIVE_TIMEOUT_SECONDS:int = 60; // Seconds to wait for the user to do something, else we restart the app
		protected static const FINISH_SECONDS:int = 30; // Seconds to wait for the user to either  take photo again or finish
		protected static const COUNTDOWN_SECONDS:int = 10; // Seconds to wait for the user to get ready to take the photo
		protected static const INPUT_FIELD_COLOUR:int = 0xffffff; // Normal field input background colour
		protected static const INPUT_FIELD_ERROR_COLOUR:int = 0xff9999; // Field input colour when there is a validation error
		protected static const LANGUAGE_BUTTON_HORIZONTAL_GAP:int = 25; // Horizontal gap between each language button
		protected static const LANGUAGE_BUTTON_VERTICAL_GAP:int = 25; // Vertical gap between each language button
		protected static const TEAM_ICON_HORIZONTAL_GAP:int = 23; // Horizontal gap between each team logo
		protected static const TEAM_ICON_VERTICAL_GAP:int = 2; // Vertical gap between each team logo
		
		protected var language:XML;
		protected var bookings:XML;
		protected var customer:XML;
		protected var pages:Array;
		protected var camera:Camera;
		protected var basePath:String;
		protected var selectedTeam:TeamIcon;
		protected var languageKeyboard:OnScreenKeyboard;
		protected var englishKeyboard:OnScreenKeyboard;
		protected var activeKeyboard:OnScreenKeyboard;
		protected var defaultQuestion:String;
		protected var securityQuestions:DataProvider;
		protected var trophyX:Number;
		protected var trophyY:Number;
		protected var trophyWidth:Number;
		protected var trophyHeight:Number;
		protected var bgLoaded:Boolean;
		protected var trophyLoaded:Boolean;
		protected var countdownTimer:Timer;
		protected var finishTimer:Timer;
		protected var inactiveTimer:Timer;
		protected var waitTimer:Timer;
		protected var waitMoreCounter:int;
		protected var loader:AssetLoader = AssetLoader.getInstance();
		var customerPreregistered:Boolean=false;
		
		static var currentLang:String;
		static var softwareKeyboardOff:Boolean=true;
		static var touchItPath:String="";
		
		public function Champion()
		{
			stop();
			
			mdm.Application.init(this, init);
		}
		
		/**
		 * Loads settings and user booking data
		 */
		protected function init():void
		{
			basePath = mdm.Application.path;
			mdm.Application.bringToFront();
			if (mdm.FileSystem.fileExists("C:\\Program Files (x86)\\Chessware\\TouchIt\\TouchIt.exe")) {
				touchItPath="C:\\Program Files (x86)\\Chessware\\TouchIt\\";
			} else {
				touchItPath="C:\\Program Files\\Chessware\\TouchIt\\";
			}
			
			var settingFile:String = basePath + "settings/appSettings.txt";
			if (mdm.FileSystem.fileExists(settingFile)) {
				var settingStr:String = mdm.FileSystem.loadFileUnicode(settingFile);
				var settings:Array = settingStr.split("|");
				
				camera = Camera.getCamera(settings[0]);
				camera.setMode(800, 600, 15, true);
				camera.setQuality(0, 90);
				
				// Cache the trophy's attributes for later use
				trophyX = Number(settings[9]) + 1280;
				trophyY = Number(settings[10]);
				trophyWidth = Number(settings[11]);
				trophyHeight = Number(settings[12]);
				
								
				// Creates the video's clipping area
				countdownPage.videoMask.x = Number(settings[13]) + 1280;
				countdownPage.videoMask.y = Number(settings[14]);
				countdownPage.videoMask.width = Number(settings[15]);
				countdownPage.videoMask.height = Number(settings[16]);
				
				// Creates the video and attach the camera to the countdown page
				countdownPage.video.attachCamera(null);
				countdownPage.video.attachCamera(camera);
				countdownPage.video.smoothing = true;
				
				// Loads the config XML and all the required images
				loader.baseUrl = basePath;
				loader.addEventListener(Event.COMPLETE, handleConfigLoaded);
				loader.load("config.xml", ["icon"]);
				
				// Make these pages invisible:
				pages = [bookingPage, barcodePage, wristbandPage, registerPage, securityPage, teamPage, instructionPage, preparePage, countdownPage, waitPage, previewPage];
				for each (var page:MovieClip in pages) {
					page.visible = false;
				}
				
				// Hide the alert dialog
				alertDialog.visible = false;
				alertDialog.scaleX = alertDialog.scaleY = 0.9;
				teamPage.continueButton.visible = false;
				
				// Create the English on-screen keyboard
				englishKeyboard = new OnScreenKeyboard();
				englishKeyboard.visible = false;
				englishKeyboard.alpha = 0;
				addChild(englishKeyboard);
				
				// Create the on-screen keyboard
				languageKeyboard = new OnScreenKeyboard();
				languageKeyboard.visible = false;
				languageKeyboard.alpha = 0;
				addChild(languageKeyboard);
				
				// Set up timers but dont start it yet
				countdownTimer = new Timer(1000, COUNTDOWN_SECONDS);
				countdownTimer.addEventListener(TimerEvent.TIMER, handleCountdownTimer);
				countdownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleCountdownComplete);

				finishTimer = new Timer(1000, FINISH_SECONDS);
				finishTimer.addEventListener(TimerEvent.TIMER_COMPLETE, reset);

				inactiveTimer = new Timer(1000, INACTIVE_TIMEOUT_SECONDS);
				inactiveTimer.addEventListener(TimerEvent.TIMER_COMPLETE, reset);
				
				waitTimer = new Timer(1000, WAIT_PHOTOSHOP_SECONDS);
				waitTimer.addEventListener(TimerEvent.TIMER, handleWaitTimer);
				waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleWaitTimerTimeout);
				
				// Loads bookings data
				bookings = new XML(mdm.FileSystem.loadFileUnicode(basePath + "bookings.xml"));
//				mdm.Dialogs.prompt(bookings.toXMLString());								
				
				termsDialog.visible = false;
				
				
				stage.addEventListener(MouseEvent.CLICK, handleStageClick);
			} else {
				mdm.Dialogs.prompt("Settings file is missing");
			}
			
		}
		
		
		protected function handleStageClick(event:MouseEvent):void
		{
			if (inactiveTimer.running) {
				inactiveTimer.reset();
				inactiveTimer.start();
			}
		}
		
		function checkVirtualPrinter()
		{
			var currentApp:String;
			var amcapStatus:Boolean = false;
			//myDebug.text="Checking AMCAP"+String(Math.random());
			var windowList:Array = mdm.System.getWindowList();
		
			for (var n=0; n<windowList.length; n++)
			{
				currentApp = windowList[n][0];
				currentApp = currentApp.toLowerCase();
				if (currentApp.indexOf("touchit") >= 0)
				{
					mdm.Dialogs.prompt("virtual keyboard ON");
					amcapStatus = true;
				}
			}
			return amcapStatus
			if (! amcapStatus)
			{
				mdm.Dialogs.prompt("Photoshop must be running, before you launch the Calibrator");
				mdm.Application.exit();
			}
		
		}
		/**
		 * Grabs a translation from the language xml
		 * 
		 * @param key the id of the translation
		 * 
		 * @return the translation
		 */
		protected function getTranslation(key:String):String
		{
			return language.text.(@id == key).toString();
		}
		
		protected function validateEmail(email:String):Boolean {
			var emailExpression:RegExp=/^[a-z0-9][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
			return ! emailExpression.test(email);
		}
		
		
		protected function handleConfigLoaded(event:Event):void
		{
			loader.removeEventListener(Event.COMPLETE, handleConfigLoaded);
			var icon:DisplayObject;
			var posX:Number = 0;
			var posY:Number = 0;
			var i:int;
			for each (var lang:XML in loader.xml.language) {				
				icon = loader.getLoader(lang.@icon.toString()) as DisplayObject;
				var btn:LanguageButton = new LanguageButton();
				btn.addEventListener(MouseEvent.CLICK, handleLanguageButtonClick);
				btn.labelField.text = lang.label.toString();
				btn.file = lang.@file.toString();
				btn.tc = lang.@tc.toString();
				btn.keyboard = lang.@keyboard.toString();
				btn.addChild(icon);
				btn.x = posX;
				btn.y = posY;
				posX += btn.width + LANGUAGE_BUTTON_HORIZONTAL_GAP;
				if (++i == 3) {
					i = 0;
					posX = 0;
					posY += btn.height + LANGUAGE_BUTTON_VERTICAL_GAP;
				}
				
				languagePage.languageHolder.addChild(btn);
			}
			languagePage.languageHolder.x = (1280 - languagePage.languageHolder.width) * .5;
			languagePage.languageHolder.y = (1024 - languagePage.languageHolder.height) * .5;
			
			posX = 0;
			posY = 0;
			i = 0;
			for each (var team:XML in loader.xml.team) {
				icon = loader.getLoader(team.@icon.toString()) as DisplayObject;
				icon.x = 28;
				icon.y = 25;
				var teamIcon:TeamIcon = new TeamIcon();
				teamIcon.addChild(icon);
				teamIcon.buttonMode = true;
				teamIcon.mouseChildren = false;
				teamIcon.label.text = team.toString();
				teamIcon.logo = team.@icon.toString();
				teamIcon.background = team.@bg.toString();
				teamIcon.trophy = team.@cup.toString();
				teamIcon.x = posX;
				teamIcon.y = posY;
				posX += teamIcon.width + TEAM_ICON_HORIZONTAL_GAP;
				if (++i == 5) {
					i = 0;
					posX = 0;
					posY += teamIcon.height + TEAM_ICON_VERTICAL_GAP;
				}
				teamIcon.addEventListener(MouseEvent.CLICK, handleTeamIconClick, false, 0, true);
				teamPage.teamHolder.addChild(teamIcon);
			}
			teamPage.teamHolder.highlight.visible = false;
			teamPage.teamHolder.x = (teamPage.introText.width - teamPage.teamHolder.width) * .5;
						
		}
		
		
		
		/**
		 * Begins loading language xml
		 */
		protected function handleLanguageButtonClick(event:MouseEvent):void
		{			
			languagePage.visible = false;
			currentLang=event.target.keyboard;
			
			englishKeyboard.keyData = new XML(mdm.FileSystem.loadFileUnicode(basePath + 'languages/english.kb.xml'));
			languageKeyboard.keyData = new XML(mdm.FileSystem.loadFileUnicode(basePath + event.target.keyboard));
			language = new XML(mdm.FileSystem.loadFileUnicode(basePath + event.target.file));
			
			defaultQuestion = getTranslation("security-default-question");
			var questions:Array = [defaultQuestion];
			for each (var question:XML in language.question) {
				questions.push(question.toString());
			}
			
			
			var tlfArray:Array = new Array(
				termsDialog.introText,
				termsDialog.messageText,
				termsDialog.dismissButton.labelField,
				alertDialog.introText,
				alertDialog.messageText,
				alertDialog.dismissButton.labelField,
				bookingPage.registeredWithReceiptButton.labelField,
				bookingPage.notRegisteredButton.labelField,
				barcodePage.introText,
				barcodePage.instructionText,
				barcodePage.inputField,
				barcodePage.submitButton.labelField,
				barcodePage.backButton.labelField,
				wristbandPage.introText,
				wristbandPage.instructionText,
				wristbandPage.inputField,
				wristbandPage.submitButton.labelField,
				wristbandPage.backButton.labelField,
				registerPage.introText,
				registerPage.firstNameLabel,
				registerPage.lastNameLabel,
				registerPage.firstNameInput,
				registerPage.lastNameInput,
				registerPage.cancelButton.labelField,
				registerPage.continueButton.labelField,
				registerPage.tcStatementText,
				securityPage.securityText,
				securityPage.securityInput,
				securityPage.emailLabel,
				securityPage.emailInput,
				securityPage.submitButton.labelField,
				teamPage.introText,
				teamPage.continueButton.labelField,
				instructionPage.introText,
				instructionPage.continueButton.labelField,
				preparePage.introText,
				preparePage.instructionText,
				preparePage.continueButton.labelField,
				countdownPage.introText,
				countdownPage.counterText,
				countdownPage.counterTextSmall,
				countdownPage.lookText,
				waitPage.introText,
				waitPage.introTextSmall,
				previewPage.againButton.labelField,
				previewPage.finishButton.labelField
				);			
			
			
			var textdir:String = language.@textdirection.toString();
			for each (var tf:TLFTextField in tlfArray) {
				tf.direction = textdir;
			}
		
						
			securityQuestions = new DataProvider(questions);
			
			alertDialog.dismissButton.labelField.text = getTranslation("ok");
			alertDialog.dismissButton.addEventListener(MouseEvent.CLICK, handleDismissButtonClick);
			
			bookingPage.registeredWithReceiptButton.labelField.text = getTranslation("registered-with-receipt");
			bookingPage.notRegisteredButton.labelField.text = getTranslation("not-registered");
			bookingPage.addEventListener(MouseEvent.CLICK, handleBookingClick);
			
			barcodePage.introText.text = getTranslation("scan-barcode-instruction");
			barcodePage.instructionText.text = getTranslation("type-reference-instruction");
			barcodePage.backButton.labelField.text = getTranslation("back");
			barcodePage.backButton.addEventListener(MouseEvent.CLICK, handleBackClick);
			barcodePage.submitButton.labelField.text = getTranslation("submit");
			barcodePage.submitButton.addEventListener(MouseEvent.CLICK, handleBarcodeSubmit);
			configureInputField(barcodePage.inputField);
									
			securityPage.securityText.text = getTranslation("security-instruction"); 
			configureCombobox(securityPage.securityCombobox, securityQuestions);
			configureInputField(securityPage.securityInput);
			securityPage.submitButton.labelField.text = getTranslation("submit");
			securityPage.submitButton.addEventListener(MouseEvent.CLICK, handleSecuritySubmit);
			securityPage.emailLabel.text = getTranslation("email");
			configureInputField(securityPage.emailInput);
			
			wristbandPage.introText.text = getTranslation("scan-wristband-instruction");
			wristbandPage.instructionText.text = getTranslation("type-reference-instruction");
			wristbandPage.backButton.labelField.text = getTranslation("back");
			wristbandPage.backButton.addEventListener(MouseEvent.CLICK, handleBackClick);
			wristbandPage.submitButton.labelField.text = getTranslation("submit");
			wristbandPage.submitButton.addEventListener(MouseEvent.CLICK, handleWristbandSubmit);
			configureInputField(wristbandPage.inputField);
			wristbandPage.inputField.maxChars = 6;
			wristbandPage.inputField.addEventListener(TextEvent.TEXT_INPUT, handleWristbandInput);
			
			registerPage.introText.text = getTranslation("register-intro");
			registerPage.firstNameLabel.text = getTranslation("first-name");
			registerPage.lastNameLabel.text = getTranslation("last-name");
			configureInputField(registerPage.firstNameInput);
			configureInputField(registerPage.lastNameInput);
			
						
			registerPage.tcStatementText.htmlText = getTranslation("tc-statement");
			registerPage.tcStatementText.buttonMode = true;
			registerPage.tcStatementText.addEventListener(MouseEvent.CLICK, showTerms, false, 0 , true);
						
			registerPage.cancelButton.labelField.text = getTranslation("cancel");
			registerPage.cancelButton.addEventListener(MouseEvent.CLICK, handleBackClick);
			registerPage.continueButton.labelField.text = getTranslation("submit");
			registerPage.continueButton.addEventListener(MouseEvent.CLICK, handleRegisterPageSubmit);
									
			termsDialog.introText.text = getTranslation("terms-title");
			termsDialog.messageText.text = mdm.FileSystem.loadFileUnicode(basePath + event.target.tc);			
			termsDialog.dismissButton.labelField.text = getTranslation("close");
			termsDialog.dismissButton.addEventListener(MouseEvent.CLICK, hideTerms, false, 0, true);
			
			var scrollbar:UIScrollBar = new UIScrollBar;
			scrollbar.height = termsDialog.messageText.height;
			termsDialog.addChild(scrollbar);
			scrollbar.scrollTarget = termsDialog.messageText;
			scrollbar.x = termsDialog.messageText.x + termsDialog.messageText.width;
			scrollbar.y = termsDialog.messageText.y;
						
			teamPage.introText.text = getTranslation("select-team-instruction");
			teamPage.continueButton.labelField.text = getTranslation("continue");
			teamPage.continueButton.addEventListener(MouseEvent.CLICK, handleTeamContinue);
			
			instructionPage.continueButton.labelField.text = getTranslation("continue");
			instructionPage.continueButton.addEventListener(MouseEvent.CLICK, handleInstructionContinue);
			instructionPage.introText.text = getTranslation("instruction-text");
			
			preparePage.introText.text = getTranslation("thank-you");
			preparePage.instructionText.text = getTranslation("prepare-instruction");
			preparePage.continueButton.labelField.text = getTranslation("take-photo");
			preparePage.continueButton.addEventListener(MouseEvent.CLICK, handlePrepareContinue);
			
			countdownPage.introText.text = getTranslation("get-ready");
			countdownPage.lookText.text = getTranslation("look-at-camera");
			
			waitPage.introText.htmlText = getTranslation("please-wait");
			waitPage.introTextSmall.htmlText = getTranslation("please-wait");
			
			previewPage.againButton.labelField.text = getTranslation("take-photo-again");
			previewPage.againButton.addEventListener(MouseEvent.CLICK, handleAgainClick);
			previewPage.finishButton.labelField.text = getTranslation("finish");
			previewPage.finishButton.addEventListener(MouseEvent.CLICK, reset);
			
			bookingPage.visible = true;	
			
			inactiveTimer.reset();
			inactiveTimer.start();
		}
		
		
		protected function showTerms(e:MouseEvent):void
		{
			termsDialog.visible = true;			
		}	
		protected function hideTerms(e:MouseEvent):void
		{
			termsDialog.visible = false;
		}
		
		protected function showAlertDialog(title:String, message:String, textField:TLFTextField = null):void
		{
			alertDialog.introText.text = getTranslation(title);
			alertDialog.messageText.text = getTranslation(message);
			TweenMax.to(alertDialog, 0.2, {
				autoAlpha:1,
				scaleX:1,
				scaleY:1,
				ease:Back.easeOut
			});
			if (textField) {
				textField.backgroundColor = INPUT_FIELD_ERROR_COLOUR;
			}
		}
		
		protected function hideAlertDialog():void
		{
			TweenMax.to(alertDialog, 0.2, {
				autoAlpha:0,
				scaleX:0.9,
				scaleY:0.9,
				ease:Back.easeIn
			});
		}
		
		protected function handleDismissButtonClick(event:MouseEvent):void
		{
			hideAlertDialog();
		}
		
		/**
		 * Sets default text and add focus listeners for text field
		 */
		protected function configureInputField(tf:TLFTextField):void
		{
			tf.useRichTextClipboard = false;
			tf.addEventListener(FocusEvent.FOCUS_IN, handleFocusIn);
			tf.addEventListener(MouseEvent.CLICK, handleInputClick);
			tf.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyboardDown);
		}
		
		/**
		 * Sets visual properties for combo box
		 */
		protected function configureCombobox(cb:ComboBox, dp:DataProvider):void
		{
			var format:TextFormat = new TextFormat();
			format.size = 23;
			cb.dataProvider = dp;
			cb.textField.setStyle("textFormat", format);
			cb.dropdown.setRendererStyle("textFormat", format);
			cb.dropdown.rowHeight = 35;
		}
			
		
		/**
		 * Clears the default text in input box
		 */
		protected function handleFocusIn(event:FocusEvent):void
		{
			var activeField:TLFTextField = event.currentTarget as TLFTextField;
			activeField.backgroundColor = INPUT_FIELD_COLOUR;
			switch (activeField) {
				case barcodePage.inputField:
				case wristbandPage.inputField:
					activeKeyboard = englishKeyboard;
					break;
				default:
					activeKeyboard = languageKeyboard;
			}
			activeKeyboard.focus = activeField;
		}
		
		/**
		 * Restores the hint text if the input is empty
		 */
		protected function handleInputClick(event:MouseEvent):void
		{
			trace("clicked text");
				trace("currentTarghet name:"+event.currentTarget.name+"string:"+event.target.toString());
				//mdm.Dialogs.prompt("foreign keiboard SHOW "+currentLang);
				//checkVirtualPrinter();
			if(event.currentTarget.name=="emailInput") {
				trace("CLICKING EMAIL");
				softwareKeyboardOff=true;
				mdm.Application.bringToFront();
				mdm.System.exec(touchItPath+"KillIt.exe");
				activeKeyboard.show();
			}
			else  {
			if ((!activeKeyboard.visible || activeKeyboard.alpha < 1) && currentLang == "languages/english.kb.xml") {
				activeKeyboard.show();
			}
			if(currentLang != "languages/english.kb.xml" && softwareKeyboardOff) {
				softwareKeyboardOff=false;
				mdm.System.exec(touchItPath+"TouchIt.exe");
				mdm.Application.sendToBack();
			}
			}
			var activeField:TLFTextField = event.currentTarget as TLFTextField;
			activeField.backgroundColor = INPUT_FIELD_COLOUR;
		}
		
		
		protected function handleKeyboardDown(event:KeyboardEvent):void
		{
			var activeField:TLFTextField = event.currentTarget as TLFTextField;
			activeField.backgroundColor = INPUT_FIELD_COLOUR;
			inactiveTimer.reset();
			inactiveTimer.start();
		}
		
		
		protected function handleWristbandInput(event:TextEvent):void
		{
			// not working!
//			if (wristbandPage.inputField.text.length > 4) {
//				handleWristbandSubmit();
//			}
		}
		
		
		protected function handleBackClick(event:MouseEvent):void
		{
			switch (event.target) {
				case barcodePage.backButton:
				case registerPage.cancelButton:
					bookingPage.visible = true;
					barcodePage.visible = false;
					registerPage.visible = false;
					break;
				case wristbandPage.backButton:
					wristbandPage.visible = false;
					barcodePage.visible = true;
					break;
			}

			if(currentLang != "languages/english.kb.xml") {
				softwareKeyboardOff=true;
				mdm.Application.bringToFront();
				mdm.System.exec(touchItPath+"KillIt.exe");
			}

			activeKeyboard.hide();
		}
		
		/**
		 * Determines which booking button has been pressed and shows the appropriate page
		 * 
		 * Hides the booking page.
		 * 
		 * Shows one of the following pages:
		 * scan barcode page
		 * recover booking details page
		 * register page
		 */
		protected function handleBookingClick(event:MouseEvent):void
		{
			switch (event.target) {
				case bookingPage.registeredWithReceiptButton:
					bookingPage.visible = false;
					barcodePage.visible = true;
					activeKeyboard = englishKeyboard;
					activeKeyboard.focus = barcodePage.inputField;
					break;
				case bookingPage.notRegisteredButton:
				// we show email if customer is not registered
					customerPreregistered=false;
					securityPage.emailInput.visible=true;
					securityPage.emailLabel.visible=true;
					bookingPage.visible = false;
					registerPage.visible = true;
					activeKeyboard = languageKeyboard;
					activeKeyboard.focus = registerPage.firstNameInput;
					break;
			}
		}
		
		/**
		 * Validates input, add data to registrations.xml, goes to the scan wristband page
		 */
		protected function handleRegisterPageSubmit(event:MouseEvent):void
		{

			if(currentLang != "languages/english.kb.xml") {
				softwareKeyboardOff=true;
				mdm.Application.bringToFront();
				mdm.System.exec(touchItPath+"KillIt.exe");
			}

			activeKeyboard.hide();
			if (registerPage.firstNameInput.text) {
				registerPage.firstNameInput.backgroundColor = INPUT_FIELD_COLOUR;
				if (registerPage.lastNameInput.text) {
					registerPage.lastNameInput.backgroundColor = INPUT_FIELD_COLOUR;
					registerPage.visible = false;
					securityPage.visible = true;
					
					customer = <customer>
									<firstname>{registerPage.firstNameInput.text}</firstname>
									<lasname>{registerPage.lastNameInput.text}</lasname>
								</customer>;
					return;
				} else {
					showAlertDialog("error", "last-name-invalid", registerPage.lastNameInput);
				}
			} else {
				showAlertDialog("error", "first-name-invalid", registerPage.firstNameInput);
			}
		}
		
		/**
		 * Validates Barcode input field, Hides the scan barcode page, shows the scan wristband page
		 */
		protected function handleBarcodeSubmit(event:MouseEvent):void
		{

			if(currentLang != "languages/english.kb.xml") {
				softwareKeyboardOff=true;
				mdm.Application.bringToFront();
				mdm.System.exec(touchItPath+"KillIt.exe");
			}

			activeKeyboard.hide();
			var f:TLFTextField = barcodePage.inputField;
			if (f.length >= 8) {
				var customers:XMLList = bookings.customer.(@ref == f.text.toUpperCase());
				if (customers.length() == 1) {
					customer = customers[0];
					f.backgroundColor = INPUT_FIELD_COLOUR;
					barcodePage.visible = false;
					securityPage.visible = true;
					customerPreregistered=true;
					securityPage.emailInput.visible=false;
					securityPage.emailLabel.visible=false;
					return;
				} else {
					showAlertDialog("error", "barcode-not-found", f);
				}
			} else {
				showAlertDialog("error", "barcode-invalid", f);
			}
		}
		
		/**
		 * Validates Security input field, Hides the scan security page, shows the scan wristband page
		 */
		protected function handleSecuritySubmit(event:MouseEvent):void
		{
			var validated=true;

			if(currentLang != "languages/english.kb.xml") {
				softwareKeyboardOff=true;
				mdm.Application.bringToFront();
				mdm.System.exec(touchItPath+"KillIt.exe");
			}

			activeKeyboard.hide();
			if (securityPage.securityCombobox.value == defaultQuestion) {
				validated=false;
				showAlertDialog("error", "security-question-invalid");
				return;
			}
				if (securityPage.securityInput.text.length<1) {
					validated=false;
					showAlertDialog("error", "security-answer-invalid", securityPage.securityInput);
					return;
				} 
			if((securityPage.emailInput.text.length<2 || validateEmail(securityPage.emailInput.text)) && !customerPreregistered) {
					showAlertDialog("error", "email-invalid", securityPage.emailInput);
					return;
			
			}
			
			if(validated) {
					securityPage.visible = false;
					wristbandPage.visible = true;
					stage.focus = wristbandPage.inputField;
					customer.appendChild(<security>{securityPage.securityCombobox.value}</security>);
					customer.appendChild(<securyty_label>{securityPage.securityInput.text}</securyty_label>);
					if(!customerPreregistered) {
						customer.appendChild(<email>{securityPage.emailInput.text}</email>);
					}
					return;
			}
		}
		
		/**
		 * Hides the scan wristband page, shows the team selection page
		 */
		protected function handleWristbandSubmit(event:MouseEvent = null):void
		{

			if(currentLang != "languages/english.kb.xml") {
				softwareKeyboardOff=true;
				mdm.Application.bringToFront();
				mdm.System.exec(touchItPath+"KillIt.exe");
			}

			activeKeyboard.hide();
			var f:TLFTextField = wristbandPage.inputField;
			if (f.length >= 5) {
				wristbandPage.visible = false;
				selectedTeam = null;
				teamPage.continueButton.visible = false;
				teamPage.visible = true;
				
				var d:Date = new Date();
				var date:String = d.getFullYear() + "-" + d.getMonth() + "-" + d.getDate() + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds() + "." + d.getMilliseconds();
				customer.appendChild(<urn>{wristbandPage.inputField.text}</urn>);
				customer.appendChild(<timestamp>{date}</timestamp>);
				
				return;
			} else {
				showAlertDialog("error", "wristband-invalid", f);
			}
		}
		
		/**
		 * Positions the highlight behind the clicked team icon
		 */
		protected function handleTeamIconClick(event:MouseEvent):void
		{
			teamPage.teamHolder.highlight.x = event.currentTarget.x;
			teamPage.teamHolder.highlight.y = event.currentTarget.y;
			teamPage.continueButton.visible = true;
			teamPage.teamHolder.highlight.visible = true;
			selectedTeam = event.currentTarget as TeamIcon;
		}
		
		/**
		 * Starts loading background, frame and trophy for the selected team
		 */
		protected function handleTeamContinue(event:MouseEvent):void
		{
			var bgRequest:URLRequest = new URLRequest(basePath + selectedTeam.background);
			var bgLoader:Loader = new Loader();
			bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleBgLoadComplete, false, 0, true);
			bgLoader.load(bgRequest);
						
			var trophyRequest:URLRequest = new URLRequest(basePath + selectedTeam.trophy);
			var trophyLoader:Loader = new Loader();
			trophyLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleTrophyLoadComplete, false, 0, true);
			trophyLoader.load(trophyRequest);
		}
		
		/**
		 * Mark background as loaded, tries to show the preparation page
		 */
		protected function handleBgLoadComplete(event:Event):void
		{
			bgLoaded = true;
			showPreparationPage();
		}
		
		/**
		 * Mark trophy as loaded, tries to show the preparation page
		 */
		protected function handleTrophyLoadComplete(event:Event):void
		{
			trophyLoaded = true;
			var t:Bitmap = event.target.content as Bitmap;
			t.x = t.width * -.5;
			t.y = t.height * -.5;
			countdownPage.trophy.addChild(t);
			countdownPage.trophy.x = trophyX;
			countdownPage.trophy.y = trophyY;
			countdownPage.trophy.width = trophyWidth;
			countdownPage.trophy.height = trophyHeight;
			
			//mdm.Dialogs.prompt(trophyWidth + " " + countdownPage.trophy.height);
			
			
			showPreparationPage();
		}
		
		/**
		 * Shows the preparation page if background, frame and trophy are loaded
		 */
		protected function showPreparationPage():void
		{
			if (bgLoaded && trophyLoaded) {
				teamPage.visible = false;
				instructionPage.visible = true;
			}
		}
		
		/**
		 * Hides the instruction page, shows the preparation page
		 */
		protected function handleInstructionContinue(event:MouseEvent):void
		{
			instructionPage.visible = false;
			preparePage.visible = true;
		}
		
		/**
		 * Hides the preparation page, starts the countdown timer
		 */
		protected function handlePrepareContinue(event:MouseEvent):void
		{
			preparePage.visible = false;
			countdownPage.visible = true;
			countdownPage.counterText.text = countdownPage.counterTextSmall.text = COUNTDOWN_SECONDS;
			
			inactiveTimer.stop();
			
			countdownTimer.reset();
			countdownTimer.start();
			
			countdownPage.lookText.alpha = 0;
			TweenMax.to(countdownPage.lookText, .1, {
				alpha:1,
				repeat:-1,
				repeatDelay:.7,
				yoyo:true
			});
				
		}
		
		/**
		 * Updates the countdown timer for each tic
		 */
		protected function handleCountdownTimer(event:TimerEvent):void
		{
			countdownPage.counterText.text = countdownPage.counterTextSmall.text = COUNTDOWN_SECONDS - event.target.currentCount;
			
			if (event.target.currentCount == COUNTDOWN_SECONDS - 1)
			{
				//countdownPage.trophy.visible = false;
				TweenMax.to(countdownPage.trophy,0.3,{autoAlpha:0, delay:.6, ease:Expo.easeIn});
			}
		}
		
		/**
		 * Captures the screen, saves the image to the file system, call photoshop to process the image
		 */
		protected function handleCountdownComplete(event:TimerEvent):void
		{
			var imageFile:String = basePath + "output/" + wristbandPage.inputField.text + ".jpg";			
			if (mdm.FileSystem.fileExists(imageFile)) {				
				mdm.FileSystem.deleteFile(imageFile);
			}
			TweenMax.killAll();
			
			mdm.Image.ScreenCapture.toJpg(1280, 0, 800, 600, basePath + "tmp/" + wristbandPage.inputField.text + ".jpg");
			
			countdownPage.lookText.alpha = 1;
			countdownPage.visible = false;
			waitPage.visible = true;
			mdm.FileSystem.saveFileUnicode(basePath + "output/" + wristbandPage.inputField.text + ".xml", '<?xml version="1.0" encoding="UTF-8"?>\n' + customer.toXMLString());
			mdm.FileSystem.saveFileUnicode(basePath + "settings/urn.jsx",
				'var URN="'+wristbandPage.inputField.text
				+'"\nvar club_logo="../'+selectedTeam.logo
				+'"\nvar club_trophy="../'+selectedTeam.trophy
				+'"\nvar bkgImg="../'+selectedTeam.background + '"'
			);
			var photoshopExecutable:String = 'C:\\Program Files\\Adobe\\Adobe Photoshop CS5\\photoshop.exe';
			if (!mdm.FileSystem.fileExists(photoshopExecutable)) {
				photoshopExecutable = 'C:\\Program Files (x86)\\Adobe\\Adobe Photoshop CS5\\photoshop.exe';
			}
			mdm.System.execStdOut(photoshopExecutable + ' ' + basePath + "settings\\wrapup.jsx");
			mdm.Application.bringToFront();
			
			waitMoreCounter = 0;
			waitTimer.reset();
			waitTimer.start();
			
			waitPage.introText.alpha = waitPage.introTextSmall.alpha = 0;
			TweenMax.allTo([waitPage.introText, waitPage.introTextSmall], .1, {
				alpha:1,
				repeat:-1,
				repeatDelay:.7,
				yoyo:true
			});

		}
		
		
		/**
		 * Checks to see if photoshop has finished processing and have saved the resulting image, then stops the timer
		 */
		protected function handleWaitTimer(event:TimerEvent):void
		{
			var file:String = basePath + "output/" + wristbandPage.inputField.text + ".jpg";
			
			if (mdm.FileSystem.fileExists(file)) {
				// Wait a few more seconds to be sure that Photoshop has finished processing,
				// because Photoshop may not have finished saving the processed image
				waitMoreCounter++;
				if (waitMoreCounter > WAIT_MORE_SECONDS) {
					var request:URLRequest = new URLRequest(basePath + "output/" + wristbandPage.inputField.text + ".jpg");
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handlePhotoComplete, false, 0, true);
					loader.load(request);
					waitTimer.stop();
					
					TweenMax.killAll();
				}
			}
		}
		
		
		/**
		 * Resets the application if the photo never completed processing within the allowed time
		 */
		protected function handleWaitTimerTimeout(event:TimerEvent):void
		{
			waitPage.visible = false;
			reset();
		}
		
		
		/**
		 * Loads the photo for preview
		 */
		protected function handlePhotoComplete(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, handlePhotoComplete);
			
			mdm.Application.bringToFront();
			
			waitPage.visible = false;
			var img:Bitmap = event.target.content as Bitmap;
			
			var img2:Bitmap = new Bitmap(img.bitmapData);
			img2.width = 666.7;
			img2.height = 500;
			
			img.width = 800;
			img.height = 600;
			
			var p:Point = previewPage.imageHolder.globalToLocal(new Point(1280, 0));
			
			img.x = p.x;
			img.y = p.y;
			
			previewPage.imageHolder.addChild(img);
			previewPage.imageHolder.addChild(img2);
			previewPage.visible = true;
			
			finishTimer.reset();
			finishTimer.start();
		}
		
		/**
		 * hides the preview page and goes back to the preparation page
		 */
		protected function handleAgainClick(event:MouseEvent):void
		{
			var imageFile:String = basePath + "output/" + wristbandPage.inputField.text + ".jpg";			
			if (mdm.FileSystem.fileExists(imageFile)) {				
				var imageXML:String = basePath + "output/" + wristbandPage.inputField.text + ".xml";
				var imageTMP:String = basePath + "tmp/" + wristbandPage.inputField.text + ".jpg";
				mdm.FileSystem.deleteFile(imageFile);
				mdm.FileSystem.deleteFile(imageXML);
				mdm.FileSystem.deleteFile(imageTMP);
			}
			previewPage.visible = false;
			countdownPage.trophy.visible = true;
			countdownPage.trophy.alpha =1;
			finishTimer.stop();
			showPreparationPage();
			
			inactiveTimer.reset();
			inactiveTimer.start();
		}
		
		/**
		 * hides the preview page, resets data and goes back to the language selection page
		 */
		protected function reset(event:* = null):void
		{
			var imageTMP:String = basePath + "tmp/" + wristbandPage.inputField.text + ".jpg";
			mdm.FileSystem.deleteFile(imageTMP);
			finishTimer.stop();
			inactiveTimer.stop();
			countdownPage.trophy.visible = true;
			countdownPage.trophy.alpha =1;
			barcodePage.inputField.text = "";
			wristbandPage.inputField.text = "";
			registerPage.firstNameInput.text = "";
			registerPage.lastNameInput.text = "";
			securityPage.securityCombobox.selectedIndex = 0;
			securityPage.securityInput.text = "";
			securityPage.emailInput.text = "";
			trophyLoaded = false;
			teamPage.continueButton.visible = false;
			teamPage.teamHolder.highlight.visible = false;
			selectedTeam = null;
			termsDialog.visible = false;
			alertDialog.alpha = 0;
			alertDialog.visible = false;
			bookingPage.visible = false;	
			barcodePage.visible = false;
			registerPage.visible = false;
			securityPage.visible = false;
			wristbandPage.visible = false;
			teamPage.visible = false;
			instructionPage.visible = false;
			preparePage.visible = false;
			countdownPage.visible = false;
			waitPage.visible = false;
			previewPage.visible = false;
			languagePage.visible = true;

			var i:int = previewPage.imageHolder.numChildren;
			while (i--) {
				previewPage.imageHolder.removeChildAt(0);
			}
			i = countdownPage.trophy.numChildren;
			while (i--) {
				countdownPage.trophy.removeChildAt(0);
			}
		}
		
	}
}