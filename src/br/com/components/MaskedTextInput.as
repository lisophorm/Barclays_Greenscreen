package br.com.components
{
	
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.operations.PasteOperation;
	
	import spark.components.TextInput;
	import spark.components.TextSelectionHighlighting;
	import spark.events.TextOperationEvent;
	
	/**
	 * @author Rafael Zimmermann
	 * <br>TextInput com máscara<br>
	 * # - Letras<br>
	 * 9 - Números<br>
	 * $ - Letras e Números<br>
	 *
	 */
	public class MaskedTextInput extends TextInput
	{
		
		private var _mascara:String = "";
		private var _branco:String = "_";
		private var isMascarado:Boolean = false;
		private var posicaoAtual:int = 0;
		private var posicaoAnt:int = 0;
		private var posicaoNova:int = -1;
		private var mascaraPadrao:String = "";
		private var textoAntigo:String = "";
		private var removerAt:int = -1;
		private var tamanhoMax:int = 0;
		private var inicioselection:int = -1;
		private var fimselection:int = -1;
		private var repoemTexto:String = "";
		private var pasteOperation:Boolean = false;
		private var _fullText:String = "";
		private const KEYRIGHT:uint = 39;
		private const KEYLEFT:uint = 37;
		
		
		public function MaskedTextInput()
		{
			this.selectionHighlighting = TextSelectionHighlighting.ALWAYS;
			this.selectable = true;
			
		}
		
		override protected function childrenCreated():void
		{
			
			this.addEventListener(KeyboardEvent.KEY_DOWN,keyDown_Handler);
			//            this.addEventListener(KeyboardEvent.KEY_UP,keyUp_Handler);
			this.addEventListener(TextOperationEvent.CHANGING,textChanging_Handler);
			this.addEventListener(TextOperationEvent.CHANGE,textChange_Handler);
			this.addEventListener(MouseEvent.CLICK,mouseClick_Handler);
			this.addEventListener(FocusEvent.FOCUS_OUT,focusOut_Handler);
			
			
		}
		
		
		
		
		
		protected function focusOut_Handler(event:FocusEvent):void{
			var i:int;
			for(i = 0; i < _mascara.length; i++){
				if(validateChar(_mascara.charAt(i)))
					if(!validaCaracterMascara(_mascara.charAt(i),this.text.charAt(i)) || text.charAt(i) == _branco){
						text = mascaraPadrao;
						selectRange(0,0);
						posicaoAnt = 0;
					}
			}
			
			if(mascaraPadrao.length != text.length){
				text = mascaraPadrao;
			}
		}
		
		protected function keyUp_Handler(event:KeyboardEvent):void{
			var i:int;
			trace("KEYUP")
			selectRange(selectionAnchorPosition,selectionAnchorPosition);
			for(i = 0; i < mascaraPadrao.length; i++){
				if(!validaCaracterMascara(_mascara.charAt(i),this.text.charAt(i))){
					text = text.substring(0, i)+mascaraPadrao.charAt(i)+ text.substring(i+1,mascaraPadrao.length);
					
				}
			}
			
		}
		
		protected function textChanging_Handler(event:TextOperationEvent):void{
			trace("CHANGING");
			selectRange(selectionAnchorPosition,selectionAnchorPosition);
			inicioselection = selectionAnchorPosition;
			fimselection = selectionActivePosition;
			
			if(event.operation is PasteOperation){
				pasteOperation = true;
			}else{
				pasteOperation = false;
			}
			
			
			
		}
		
		
		
		protected function mouseClick_Handler(event:MouseEvent):void{
			posicaoAtual = selectionAnchorPosition;
			var p1:int = posicaoAtual;
			posicaoAnt = p1;
			if(!validateChar(_mascara.charAt(p1))){
				p1++;
				selectRange(p1,p1);
				posicaoAnt = p1;
				posicaoAtual++;
				
			}
			
		}
		
		protected function textChange_Handler(event:TextOperationEvent):void{
			
			trace("CHANGE");
			event.preventDefault();
			selectRange(selectionAnchorPosition,selectionAnchorPosition);
			if(removerAt != -1){
				text = text.substring(0, removerAt)+ text.substring(removerAt,text.length);
				posicaoAtual = selectionAnchorPosition;
				selectRange(posicaoAtual,posicaoAtual);
			}
			
			if(posicaoNova != -1){
				selectRange(posicaoNova,posicaoNova);
			}
			
			if(repoemTexto != ""){
				
				if(inicioselection < fimselection){
					text = text.substring(0, inicioselection+1)+repoemTexto+ text.substring(inicioselection+1,text.length);
					selectRange(inicioselection+1,inicioselection+1);
					posicaoAnt = inicioselection+1;
				}else{
					text = text.substring(0, fimselection+1)+repoemTexto+ text.substring(fimselection+1,text.length);
					selectRange(fimselection+1,fimselection+1);
					posicaoAnt = fimselection+1;
				}
				for(i = 0; i < mascaraPadrao.length; i++){
					if(!validaCaracterMascara(_mascara.charAt(i),this.text.charAt(i))){
						text = text.substring(0, i)+mascaraPadrao.charAt(i)+ text.substring(i+1,mascaraPadrao.length);
						
					}
				}
				
				if(!validateChar(_mascara.charAt(posicaoAnt))){
					posicaoAnt++;
					selectRange(posicaoAnt,posicaoAnt);
				}
				
				repoemTexto = "";
			}
			
			if(pasteOperation && inicioselection != fimselection){
				
				var ini:int = 0;
				var fim:int = 0;
				if(inicioselection < fimselection){
					ini = inicioselection;
					fim = fimselection;
				}else{
					ini = fimselection;
					fim = inicioselection;
				}
				
				
				var i:int = 0;
				var novaStr:String = "";
				for(i = 0; i < fim-selectionAnchorPosition;i++){
					novaStr += mascaraPadrao.charAt(selectionAnchorPosition+i);
				}
				
				text = text.substring(0, selectionAnchorPosition)+novaStr+ text.substring(selectionAnchorPosition,text.length);
				
				
				
				for(i = 0; i < mascaraPadrao.length; i++){
					if(!validaCaracterMascara(_mascara.charAt(i),this.text.charAt(i))){
						text = text.substring(0, i)+mascaraPadrao.charAt(i)+ text.substring(i+1,mascaraPadrao.length);
						
					}
				}
				
			}
			
			pasteOperation = false;
			
			
		}
		
		protected function keyDown_Handler(event:KeyboardEvent):void{
			removerAt = -1;
			posicaoNova = -1;
			posicaoAtual = selectionAnchorPosition;
			var p1:int = posicaoAtual;
			selectRange(p1,p1);
			trace("KEYDOWN"+event.keyCode)
			if(event.keyCode != Keyboard.BACKSPACE && event.keyCode != Keyboard.DELETE && !event.ctrlKey){
				if(event.keyCode != KEYRIGHT && event.keyCode != KEYLEFT && event.charCode > 0){
					posicaoAnt = p1+1;
					if(selectionAnchorPosition == selectionActivePosition){
						//valida o caracter de entrada em relacao a máscara
						if(validaCaracterMascara(_mascara.charAt(p1),numToChar(event.charCode))){
							trace(numToChar(event.charCode))
							text = text.substring(0, p1)+ text.substring(p1+1,text.length);
							textoAntigo = text;
							
							
							if(validateChar(_mascara.charAt(p1+1))){
								selectRange(p1,p1);
								
							}else{
								selectRange(p1,p1);
								posicaoNova = p1+2;
								posicaoAnt++;
							}
						}else{
							
							removerAt = p1;
						}
					}else{
						inicioselection = selectionAnchorPosition;
						fimselection = selectionActivePosition;
						insereCaracterEmSelecao();
						
						
					}
					
				}else{
					if(event.keyCode == KEYLEFT){
						
						posicaoAnt = p1;
						if(!validateChar(_mascara.charAt(p1))){
							p1--;
							posicaoAnt--;
							selectRange(p1,p1);
						}
					}else if(event.keyCode == KEYRIGHT){
						posicaoAnt = p1;
						if(!validateChar(_mascara.charAt(p1))){
							p1++;
							posicaoAnt++;
							selectRange(p1,p1);
						}
					}
				}
				
			}else if(event.charCode == Keyboard.BACKSPACE){
				if(inicioselection == fimselection && posicaoAnt > 0){
					substituirPorBranco(posicaoAnt-1);
					selectRange(posicaoAnt,posicaoAnt);
				}else if(inicioselection != fimselection){
					deleta();
					selectRange(fimselection,fimselection);
					posicaoAnt = fimselection;
				}
				
			}else if(event.keyCode == Keyboard.DELETE){
				
				
				if(inicioselection == fimselection && posicaoAnt < tamanhoMax){
					insereBranco(posicaoAnt);
					selectRange(posicaoAnt,posicaoAnt);
				}else if(inicioselection != fimselection){
					deleta();
					selectRange(inicioselection,inicioselection);
					posicaoAnt = inicioselection;
				}
				
			}
			
			
		}
		
		private function insereCaracterEmSelecao():void{
			var i:int = 0;
			var newText:String = "";
			if(inicioselection < fimselection){
				for(i = inicioselection+1; i <fimselection;i++){
					newText += mascaraPadrao.charAt(i);
				}
				repoemTexto = newText;
				
			}else{
				for(i = fimselection+1; i < inicioselection;i++){
					newText += mascaraPadrao.charAt(i);
				}
				repoemTexto = newText;
				
			}
			
		}
		
		private function deleta():void{
			
			var i:int = 0;
			var newText:String = "";
			if(inicioselection < fimselection){
				for(i = inicioselection; i <fimselection;i++){
					newText += mascaraPadrao.charAt(i);
				}
				text = text.substring(0, inicioselection)+newText+ text.substring(inicioselection,text.length);
			}else{
				for(i = fimselection; i < inicioselection;i++){
					newText += mascaraPadrao.charAt(i);
				}
				text = text.substring(0, fimselection)+newText+ text.substring(fimselection,text.length);
			}
		}
		
		private function insereBranco(index:uint):void{
			if(validateChar(_mascara.charAt(index)))
				text = text.substring(0, index)+ _branco+ text.substring(index,text.length);
			else
				text = text.substring(0, index) + _mascara.charAt(index)+_branco+text.substring(index+1,text.length);
		}
		
		private function substituirPorBranco(index:uint):void{
			if(validateChar(_mascara.charAt(index))){
				text = text.substring(0, index)+ _branco+ text.substring(index,text.length);
				posicaoAnt--;
			}else{
				text = text.substring(0, index-1)+_branco+ _mascara.charAt(index)+ text.substring(index,text.length);
				posicaoAnt-=2;
			}
		}
		
		
		
		private function numToChar(num:int):String {
			trace("numToChar:"+num)
			if (num > 47 && num < 58) {
				var strNums:String = "0123456789";
				return strNums.charAt(num - 48);
			} else if (num > 64 && num < 91) {
				var strCaps:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
				return strCaps.charAt(num - 65);
			} else if (num > 96 && num < 123) {
				var strLow:String = "abcdefghijklmnopqrstuvwxyz";
				return strLow.charAt(num - 97);
			}
			return null;
			
		}
		
		public function set fullText(fullText:String):void{
			var i:int;
			var padraoOK:Boolean = true;
			if(fullText == ""){
				text = mascaraPadrao;
			}else{
				for(i = 0; i < _mascara.length; i++){
					if(i < fullText.length){
						if(validateChar(_mascara.charAt(i))){
							if(!validaCaracterMascara(_mascara.charAt(i),fullText.charAt(i))){
								padraoOK = false;
							}
						}else if(fullText.charAt(i) != _mascara.charAt(i)){
							fullText = fullText.substr(0,i)+_mascara.charAt(i)+fullText.substring(i,fullText.length);
						}
					}
				}
				
				
				if(padraoOK && fullText.length == _mascara.length)
					text = fullText;
				else
					text = mascaraPadrao;
			}
		}
		
		public function get fullText():String{
			var i:int;
			var retorno:String = "";
			for(i = 0; i < _mascara.length; i++){
				if(validateChar(_mascara.charAt(i)) && text.charAt(i) != _branco){
					retorno += text.charAt(i);
				}
			}
			return retorno;
		}
		
		/**
		 * Seta a máscara Ex. Mascara CPF: 999.999.999-99
		 * Ex. Placa automóvel: ###-9999
		 */
		public function set mascara(mascara:String):void{
			text = "";
			_mascara = mascara;
			this.maxChars = _mascara.length;
			if(mascara == "" || mascara == null){
				isMascarado = false;
			}else{
				isMascarado = true;
				
				var i:int = 0;
				for(i=0; i < mascara.length; i++){
					if(validateChar(mascara.charAt(i)))
						mascaraPadrao = mascaraPadrao.substring(0, i) + _branco + mascaraPadrao.substring(i + 1);
					else{
						mascaraPadrao = mascaraPadrao.substring(0, i)+ mascara.charAt(i) + mascaraPadrao.substring(i + 1);
					}
				}
				text = mascaraPadrao;
				textoAntigo = text;
				tamanhoMax = mascaraPadrao.length;
			}
			
			
		}
		
		public function get mascara():String{
			return _mascara;
		}
		/**
		 * Seta o caracter que representará o campo como vazio
		 *
		 */
		public function set whiteSpace(branco:String):void{
			_branco = branco;
		}
		
		/**
		 * @param templateChar The template char
		 * @return The validate result
		 */
		public function validateChar(maskChar:String):Boolean{
			switch(maskChar){
				case "#":
					return true;
				case "@":
					return true;
				case "9":
					return true;
				default:
					return false;
			}
		}
		
		public function ehBranco(char:String):Boolean{
			if(char == _branco){
				return true
			}
			return false;
		}
		/**
		 * Valida Caracter da Máscara<br>
		 * If you want to work with another band of characters, just extend the class and override this method.
		 */
		private function validaCaracterMascara(caractermascara:String,entrada:String):Boolean{
			
			var pattern:RegExp = /""/;
			switch(caractermascara){
				case "#":
					pattern = /[a-zA-Z]/
					break;
				case "@":
					pattern = /[^`]/
					break;
				case "9":
					pattern = /[0-9]/
					break;
				default:
					pattern = /""/;
					break;
			}
			
			return pattern.test(entrada);
		}
	}
}