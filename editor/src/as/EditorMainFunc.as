//------------------------------------------------------------
//
//  Dancing☆Onigiriエディター
//  参照関数
//
//------------------------------------------------------------

//------------------------------------------------------------
// キー数存在チェック
// [引数
//            keys : キー数]
// [返却値    true : 存在するキー, false : 存在しないキー]
//------------------------------------------------------------
function checkKeys(keys:String):Boolean
{
	var chk:String = keys;
	for (var j:Number = 0; j < keyListArray.length; j++) {
		if (String(keyListArray[j]) == chk) {
			return true;
		}
	}
	return false;
}

/*
	キー数情報格納
	@param	keys	キー数
	@param	obj		読込用オブジェクト
*/
function setKeys(keys:String, obj:Object, resetFlg:Boolean):Void
{
	var SPACE_MC_NUM:Number = 2;
	
	if (obj["keyNum" + keys] == undefined && inswfFlg == true) {
		receiveEditorHeader(keys, obj);
	}
	
	if(Number(tuneNumT.text) <= 0  || isNaN(parseInt(tuneNumT.text))){
		tune_num = 1;
	}else{
		tune_num = parseInt(tuneNumT.text);
	}
	if(tuningName.text != ""){
		tuning = tuningName.text;
	}

	var tmpKey:Number = parseInt(obj["keyNum" + keys]);
	keyLabelPre = keyLabel;
	keyLabel = (!isNaN(tmpKey) ? tmpKey : parseInt(keys));

	// 矢印種類設定
	arrBaseMC = obj["arrBaseMC" + keys].split(",");
	if (arrBaseMC.length <= 1) {
		arrBaseMC = new Array();
		for (var j:Number = 0; j < keyLabel; j+=2) {
			arrBaseMC[j]   = 0;
			arrBaseMC[j+1] = 3;
		}
	}
	spaceNum = 0;
	for (var j:Number = 0; j < keyLabel; j++) {
		if (arrBaseMC[j] == SPACE_MC_NUM) {
			spaceNum++;
		}
		arrBaseMC[j] = mcChar[arrBaseMC[j]];
	}

	// 矢印ヘッダー設定
	headerDat = [[]];
	var tmpHeaderGroup:Array = obj["headerDat" + keys].split("$");
	if (tmpHeaderGroup == undefined){
		tmpHeaderGroup = [""];
	}
	for (var j:Number = 1; j <= tmpHeaderGroup.length; j++) {
		headerDat[j] = tmpHeaderGroup[j - 1].split(",");
		frzHeader = ( j == 1 ? "frz" : "f");
		
		// 矢印名補完
		if(headerDat[j].length < keyLabel){
			var loopIdx = "";
			for(var k = 0, m = 0, n = 0; k < keyLabel; k++, m++){
				if(headerDat[j][k].length > 0)	continue;
				headerDat[j][k] = "arrow" + loopIdx + String.fromCharCode(65 + (m % 26));
				if(m % 26 == 25){
					loopIdx = String.fromCharCode(65 + n);
					n++;
				}
			}
		}
		// フリーズアロー名補完
		if(headerDat[j].length == keyLabel){
			var headerLength:Number = headerDat[j].length;
			for(var k:Number = 0; k < headerLength; k++){
				var targetName:String = headerDat[j][k];
				for(var m:Number = 0; m < arrFrzPtn.length; m++){
					targetName = str_replace(arrFrzPtn[m][0], frzHeader + arrFrzPtn[m][1], targetName);
				}
				for(var m:Number = 0; m < arrFrzDPtn.length; m++){
					targetName = str_replace(arrFrzDPtn[m][0], arrFrzDPtn[m][1], targetName);
				}
				headerDat[j].push(targetName);
			}
		}
	}

	// ソート順設定
	arrSort = [[]];
	arrSort[1] = new Array();
	arrSortInv = [[]];
	arrSortInv[1] = new Array();
	for (var j:Number = 0; j < keyLabel; j++) {
		arrSort[1][j] = j;
		arrSortInv[1][j] = j;
	}
	if (obj["arrSort" + keys].length == 0) {
	} else {
		tmpSortGroup = obj["arrSort" + keys].split("$");
		for (var j:Number = 0; j < tmpSortGroup.length; j++) {
			arrSort[j + 2] = tmpSortGroup[j].split(",");
			arrSortInv[j + 2] = new Array();
			for (var k:Number = 0; k < arrSort[j + 2].length; k++) {
				arrSort[j + 2][k] = Number(arrSort[j + 2][k]);
				arrSortInv[j + 2][arrSort[j + 2][k]] = k;
			}
		}
	}
	wideFlg = (obj["wide" + keys] == "true" ? true : false);
	if(wideFlg == false && keyLabel > 17){
		wideFlg = true;
	}
	arrowWidth = Math.round((wideFlg ? wideWidth : stdWidth) / (0.5 * spaceNum + keyLabel));
	spaceWidth = arrowWidth * 1.5;

	// ロードデータ初期位置
	speedPos = keyLabel * 2;
	boostPos = keyLabel * 2 + 1;
	rhythmPos = keyLabel * 2 + 2;

	speedVal = zeroPadding(keyLabel, 2, "0");
	rhythmVal = zeroPadding(keyLabel + 1, 2, "0");

	if(resetFlg != true){
		arrow_temp = new Array();
		for (var a:Number = 0; a <= rhythmPos; a++) {
			arrow_temp[a] = new Array();
		}
		if(keyLabelPre != keyLabel){
			tempKoma = new Array();
			for (var a:Number = 0; a <= boostPos; a++) {
				tempKoma[a] = new Array();
			}
		}
	
		// 初期値設定
		if (isNaN(parseFloat(firstbpm.text)) || parseFloat(firstbpm.text) == 0) {
			haba_array[0].blank = 25.0;
		} else {
			haba_array[0].blank = Math.round((1800 / parseFloat(firstbpm.text)) * 100000) / 100000;
		}
		lblArray = [0];
	}
	if(obj["temp4Ptn" + keys] != undefined){
		temp4Ptn = obj["temp4Ptn" + keys];
	}
	if(scoreChFlg == false){
		arrow_temp1 = new Array();
		for (var a:Number = 0; a <= rhythmPos; a++) {
			arrow_temp1[a] = new Array();
		}
	}
	
	keysTmp = keys;
}

function str_replace(word, newW, str)
{
	//word = 検索文字列　newW = 置換文字列　str = 全体の文字列
	var s_array = str.split(word);
	var newStr = s_array.join(newW);
	return newStr;
}

//------------------------------------------------------------
// ページ内のコマを削除・Interval更新
// [引数: startKoma		開始位置]
//------------------------------------------------------------
function delete_koma(startKoma:Number):Void
{
	rhythm_ch = false;
	var endKoma:Number = startKoma + pageKoma;
	var pageNum:Number = page - 1 + pagePos / pageKoma;

	for (var j:Number = startKoma; j < endKoma; j++) {
		for (var p:Number = 0; p <= keyLabel; p++) {
			var pl:String = zeroPadding(p, 2, "0");
			kbase["arrMC_" + pl + "_" + j].removeMovieClip();
		}
	}
	for (var j:Number = startKoma / 4; j < endKoma / 4; j++) {
		kbase["arrMC_" + rhythmVal + "_" + j].removeMovieClip();
	}
	kfix["fix__MC_" + pageNum].removeMovieClip();
	kfix["lbl__MC_" + pageNum].removeMovieClip();
	kfix["sel__MC_" + pageNum].removeMovieClip();

	// Interval更新
	if(head_num != "" && haba4_num != ""){
		for (var j:Number = haba_array.length - 1; j >= 0; j--) {
			if (Math.round(startKoma - haba_array[j].num * pageKoma) >= 0) {
				haba_array[j].header = parseFloat(head_num);
				haba_array[j].blank = parseFloat(haba4_num);
				break;
			}
		}
	}
}

//------------------------------------------------------------
// 画面表示リセット
// [引数: startKoma		開始位置]
//
// コマの削除を行わず、各種項目の更新のみ行う。
//------------------------------------------------------------
function delete_koma_scr(startKoma:Number):Void
{
	rhythm_ch = false;

	// Interval更新
	if(head_num != "" && haba4_num != ""){
		for (var j:Number = haba_array.length - 1; j >= 0; j--) {
			if (Math.round(startKoma - haba_array[j].num * pageKoma) >= 0) {
				haba_array[j].header = parseFloat(head_num);
				haba_array[j].blank = parseFloat(haba4_num);
				break;
			}
		}
	}
}


//------------------------------------------------------------
// ページ内のコマを作成
// [引数 startKoma		   開始位置]
//------------------------------------------------------------
function make_koma(startKoma:Number):Void
{
	var typeNum:Number = parseInt(_global.posi_type.slice(4));
	var arrPos:Array = arrSort[typeNum];
	var currentBar:Number = startKoma / pageKoma;
	var onigiriNum:Number = 0;
	var onigiriPlusWidth:Number = 0;
	
	divY = 0;
	kbase._y = 0;
	
	// 矢印・フリーズアロー
	var hKomaCnt:Number = arrPos.length;
	for (var p:Number = 0; p < hKomaCnt; p++) {
		
		// コマを作成
		var cp:Number = arrPos[p];
		var arrowName:String = arrBaseMC[cp];
		var pl:String = zeroPadding(cp, 2, "0");
		var widthNum:Number  = initWidth + p * arrowWidth;
		kbase[arrowName]._x = widthNum + onigiriPlusWidth;
		kbase[arrowName]._width = (arrBaseMC[cp] == "space_MC" ? spaceWidth + 1 : arrowWidth + 1);
		kbase[arrowName]._height = komaHeight;
		
		for (var j:Number = 0; j < pageKoma; j++) {
			var num:Number = startKoma + j;
			var komaName:String = "arrMC_" + pl + "_" + num;
			kbase[arrowName].duplicateMovieClip(komaName, num % pageKoma + pageKoma * p + 20);
			var komaObj:Object = kbase[komaName];
			komaObj._y = initHeight + j * komaHeight;
			komaObj.j = cp;
			komaObj.k = num;
		}
		
		if (arrowName == "space_MC") {
			onigiriNum++;
			onigiriPlusWidth = (spaceWidth - arrowWidth) * onigiriNum;
		}
		
		// 譜面を展開
		if(arrow_temp[p].length > 0){
			spreadScore(pl, cp, startKoma, 2, pageKoma);
			spreadScore(pl, cp + keyLabel, startKoma, 3, pageKoma);
		}
	}

	// 速度データ
	kbase.speed_MC._x = initWidth + hKomaCnt * arrowWidth + onigiriPlusWidth;
	kbase.speed_MC._height = komaHeight;
	for (var k:Number = 0; k < pageKoma; k++) {
		var num:Number = startKoma + k;
		var komaName:String = "arrMC_" + speedVal + "_" + num;
		
		kbase.speed_MC.duplicateMovieClip(komaName, num % pageKoma + pageKoma * keyLabel + 20);
		var komaObj:Object = kbase[komaName];
		komaObj._y = initHeight + k * komaHeight;
		komaObj.k = num;
	}
	if(arrow_temp[speedPos].length > 0){
		spreadScoreSpd(speedVal, speedPos, startKoma, 2, pageKoma);
		spreadScoreSpd(speedVal, boostPos, startKoma, 3, pageKoma);
	}

	// 拍子データ
	var rhyStart:Number = kbase.speed_MC._x + speedWidth - 2;
	var rhyStartKoma:Number = startKoma / 4;
	var rhyPageKoma:Number  = pageKoma / 4;
	var rhyEndKoma:Number   = rhyStartKoma + rhyPageKoma;
	kbase.rythm_MC._x = rhyStart;
	kbase.rythm_MC._height = komaHeight * 4;
	
	for (var k:Number = 0; k < rhyPageKoma; k++) {
		var num:Number = rhyStartKoma + k;
		var komaName:String = "arrMC_" + rhythmVal + "_" + num;
		
		kbase.rythm_MC.duplicateMovieClip(komaName, num % pageKoma + pageKoma * (keyLabel + 1) + 20);
		var komaObj:Object = kbase[komaName];
		komaObj._y = initHeight + k * komaHeight * 4;
		komaObj.k = num;
	}
	if(arrow_temp[rhythmPos].length > 0){
		spreadScoreRhythm(rhythmVal, rhythmPos, startKoma, 2, pageKoma);
	}
	
	kfix.fix_MC.duplicateMovieClip("fix__MC_" + currentBar,j + pageKoma * (keyLabel + 2) + 20);
	kfix["fix__MC_" + currentBar]._x = fixWidth;

	kfix.lbl_MC.duplicateMovieClip("lbl__MC_" + currentBar,j + pageKoma * (keyLabel + 3) + 20);
	kfix["lbl__MC_" + currentBar]._x = fixWidth;
	
	kfix.sel_MC.duplicateMovieClip("sel__MC_" + currentBar,j + pageKoma * (keyLabel + 4) + 20);
	kfix["sel__MC_" + currentBar]._x = fixWidth;
}

//------------------------------------------------------------
// ページ内のコマを再配置
// [引数 startKoma		   開始位置
//       beforeStartKoma   前回開始位置]
//------------------------------------------------------------
function make_koma_clear(startKoma:Number, beforeStartKoma:Number):Void
{
	var typeNum:Number = parseInt(_global.posi_type.slice(4));
	var arrPos:Array = arrSort[typeNum];
	var currentBar:Number = startKoma / pageKoma;
	var beforeBar:Number = beforeStartKoma / pageKoma;
	
	divY = 0;
	kbase._y = 0;
	
	// 拍子データのリセット
	//   移動対象のコマのうち、3連符のために非表示になっているコマは
	//   一旦表示に切り替えないと移動することができない。
	var rhyStartKoma:Number = startKoma / 4;
	var rhyBeforeStartKoma:Number = beforeStartKoma / 4;
	var rhyPageKoma:Number  = pageKoma / 4;
	var rhyEndKoma:Number   = (startKoma + pageKoma)/4;
	
	for (var k:Number = 0; k < rhyPageKoma; k++) {
		var num:Number = rhyStartKoma + k;
		var oldNum:Number = rhyBeforeStartKoma + k;
		var oldKomaName:String = "arrMC_" + rhythmVal + "_" + oldNum;
		var komaObj:Object = kbase[oldKomaName];
		if(komaObj._currentframe != 1){
			komaObj.gotoAndStop(1);
			resetKomaSize(oldNum);
		}
		komaObj._y = initHeight + (k * 4) * komaHeight;
		komaObj.k = num; 
		komaObj._name = "arrMC_" + rhythmVal + "_" + num + "tmp";
	}
	for (var k:Number = 0; k < rhyPageKoma; k++) {
		var num:Number = rhyStartKoma + k;
		var komaName:String = "arrMC_" + rhythmVal + "_" + num;
		
		kbase[komaName + "tmp"]._name = komaName;
	}
	
	// 矢印・フリーズアローの再配置・展開
	var hKomaCnt:Number = arrPos.length;
	for (var p:Number = 0; p < hKomaCnt; p++) {
		
		// コマの設定を取得
		var cp:Number = arrPos[p];
		var pl:String = zeroPadding(cp, 2, "0");
		
		for (var j:Number = 0; j < pageKoma; j++) {
			var num:Number = startKoma + j;
			var oldNum:Number = beforeStartKoma + j;
			var oldKomaName:String = "arrMC_" + pl + "_" + oldNum;
			var komaObj:Object = kbase[oldKomaName];
			
			if(komaObj._currentframe != 1){
				komaObj.gotoAndStop(1);
			}
			komaObj._y = initHeight + j * komaHeight;
//			komaObj.j = cp;
			komaObj.k = num;
			komaObj._name = "arrMC_" + pl + "_" + num + "tmp";
		}
		for (var j:Number = 0; j < pageKoma; j++) {
			var num:Number = startKoma + j;
			var komaName:String = "arrMC_" + pl + "_" + num;
			
			kbase[komaName + "tmp"]._name = komaName;
		}
		
		// 譜面を展開
		spreadScore(pl, cp, startKoma, 2, pageKoma);
		spreadScore(pl, cp + keyLabel, startKoma, 3, pageKoma);
	}

	// 速度データの再配置・展開
	for (var k:Number = 0; k < pageKoma; k++) {
		var num:Number = startKoma + k;
		var oldNum:Number = beforeStartKoma + k;
		var oldKomaName:String = "arrMC_" + speedVal + "_" + oldNum;
		var komaObj:Object = kbase[oldKomaName];
		if(komaObj._currentframe != 1){
			komaObj.gotoAndStop(1);
		}
		komaObj._y = initHeight + k * komaHeight;
		komaObj.k = num;
		komaObj._name = "arrMC_" + speedVal + "_" + num + "tmp";
	}
	for (var k:Number = 0; k < pageKoma; k++) {
		var num:Number = startKoma + k;
		var komaName:String = "arrMC_" + speedVal + "_" + num;
		kbase[komaName + "tmp"]._name = komaName;
	}
	spreadScoreSpd(speedVal, speedPos, startKoma, 2, pageKoma);
	spreadScoreSpd(speedVal, boostPos, startKoma, 3, pageKoma);

	// 拍子データの展開
	spreadScoreRhythm(rhythmVal, rhythmPos, startKoma, 2, pageKoma);

	if(kfix["fix__MC_" + beforeBar]._currentframe != 1){
		kfix["fix__MC_" + beforeBar].gotoAndStop(1);
	}
	kfix["fix__MC_" + beforeBar]._name = "fix__MC_" + currentBar;
	
	if(kfix["lbl__MC_" + beforeBar]._currentframe != 1){
		kfix["lbl__MC_" + beforeBar].gotoAndStop(1);
	}
	kfix["lbl__MC_" + beforeBar]._name = "lbl__MC_" + currentBar;
	
	if(kfix["sel__MC_" + beforeBar]._currentframe != 1){
		kfix["sel__MC_" + beforeBar].gotoAndStop(1);
	}
	kfix["sel__MC_" + beforeBar]._name = "sel__MC_" + currentBar;
}

// 下スクロール用コマ作成
function make_koma_scrdown(startKoma:Number, addLength:Number):Void
{
	var typeNum:Number = parseInt(_global.posi_type.slice(4));
	var arrPos:Array = arrSort[typeNum];
	var currentBar:Number = startKoma / pageKoma;
	var beforeBar:Number = (startKoma - addLength) / pageKoma;

	var addPos:Number  = pageKoma - addLength;
	var addStartKoma:Number = startKoma + addPos;
	
	divY += addLength;
	kbase._y -= komaHeight * addLength;
	
	
	// 拍子データのリセット
	//   移動対象のコマのうち、3連符のために非表示になっているコマは
	//   一旦表示に切り替えないと移動することができない。
	var rhyStartKoma:Number = startKoma / 4;
	var rhyPageKoma:Number  = pageKoma / 4;
	var rhyAddPos:Number = addPos / 4;
	var rhyAddStartKoma:Number = addStartKoma / 4;
	var rhyEndKoma:Number   = (startKoma + pageKoma)/4;
	
	for (var k:Number = rhyAddPos; k < rhyPageKoma; k++) {
		var num:Number = rhyStartKoma + k;
		var oldNum:Number = num - rhyPageKoma;
		var oldKomaName:String = "arrMC_" + rhythmVal + "_" + oldNum;
		if(kbase[oldKomaName]._currentframe != 1){
			kbase[oldKomaName].gotoAndStop(1);
			resetKomaSize(oldNum);
		}
		
		var komaName:String = "arrMC_" + rhythmVal + "_" + num;
		kbase[oldKomaName]._name = komaName;
		
		var komaObj:Object = kbase[komaName];
		komaObj._y = initHeight + (k * 4 + divY) * komaHeight;
		komaObj.k = num;
	}
	
	// 矢印・フリーズアローの再配置・展開
	var hKomaCnt:Number = arrPos.length;
	for (var p:Number = 0; p < hKomaCnt; p++) {
		
		// コマの設定を取得
		var cp:Number = arrPos[p];
		var pl:String = zeroPadding(cp, 2, "0");
		
		for (var j:Number = addPos; j < pageKoma; j++) {
			var num:Number = startKoma + j;
			var oldNum:Number = num - pageKoma;
			var oldKomaName:String = "arrMC_" + pl + "_" + oldNum;
			if(kbase[oldKomaName]._currentframe != 1){
				kbase[oldKomaName].gotoAndStop(1);
			}
			
			var komaName:String = "arrMC_" + pl + "_" + num;
			kbase[oldKomaName]._name = komaName;
			
			var komaObj:Object = kbase[komaName];
			komaObj._y = initHeight + (j + divY) * komaHeight;
//			komaObj.j = cp;
			komaObj.k = num;
		}
		
		// 譜面を展開（スクロール分）
		spreadScore(pl, cp, addStartKoma, 2, pageKoma);
		spreadScore(pl, cp + keyLabel, addStartKoma, 3, pageKoma);
	}

	// 速度データの再配置・展開
	for (var k:Number = addPos; k < pageKoma; k++) {
		var num:Number = startKoma + k;
		var oldNum:Number = num - pageKoma;
		var oldKomaName:String = "arrMC_" + speedVal + "_" + oldNum;
		if(kbase[oldKomaName]._currentframe != 1){
			kbase[oldKomaName].gotoAndStop(1);
		}
		
		var komaName:String = "arrMC_" + speedVal + "_" + num;
		kbase[oldKomaName]._name = komaName;
		
		var komaObj:Object = kbase[komaName];
		komaObj._y = initHeight + (k + divY) * komaHeight;
		komaObj.k = num;
	}
	spreadScoreSpd(speedVal, speedPos, addStartKoma, 2, pageKoma);
	spreadScoreSpd(speedVal, boostPos, addStartKoma, 3, pageKoma);
	
	// 拍子データの展開
	spreadScoreRhythm(rhythmVal, rhythmPos, addStartKoma, 2, pageKoma);

	if(kfix["fix__MC_" + beforeBar]._currentframe != 1){
		kfix["fix__MC_" + beforeBar].gotoAndStop(1);
	}
	kfix["fix__MC_" + beforeBar]._name = "fix__MC_" + currentBar;
	
	if(kfix["lbl__MC_" + beforeBar]._currentframe != 1){
		kfix["lbl__MC_" + beforeBar].gotoAndStop(1);
	}
	kfix["lbl__MC_" + beforeBar]._name = "lbl__MC_" + currentBar;
	
	if(kfix["sel__MC_" + beforeBar]._currentframe != 1){
		kfix["sel__MC_" + beforeBar].gotoAndStop(1);
	}
	kfix["sel__MC_" + beforeBar]._name = "sel__MC_" + currentBar;
}


// 上スクロール用コマ作成
function make_koma_scrup(startKoma:Number, addLength:Number):Void
{
	var typeNum:Number = parseInt(_global.posi_type.slice(4));
	var arrPos:Array = arrSort[typeNum];
	var currentBar:Number = startKoma / pageKoma;
	var beforeBar:Number = (startKoma + addLength) / pageKoma;

	var addStartKoma:Number = startKoma + addLength;
	
	divY -= addLength;
	kbase._y += komaHeight * addLength;
	
	
	// 拍子データのリセット
	//   移動対象のコマのうち、3連符のために非表示になっているコマは
	//   一旦表示に切り替えないと移動することができない。
	var rhyStartKoma:Number = startKoma / 4;
	var rhyPageKoma:Number  = pageKoma / 4;
	var rhyAddLength:Number = addLength / 4;
//	var rhyAddStartKoma:Number = addStartKoma / 4;
	var rhyEndKoma:Number   = addStartKoma /4;
	
	for (var k:Number = 0; k < rhyAddLength; k++) {
		var num:Number = rhyStartKoma + k;
		var oldNum:Number = num + rhyPageKoma;
		var oldKomaName:String = "arrMC_" + rhythmVal + "_" + oldNum;
		if(kbase[oldKomaName]._currentframe != 1){
			kbase[oldKomaName].gotoAndStop(1);
			resetKomaSize(oldNum);
		}
		
		var komaName:String = "arrMC_" + rhythmVal + "_" + num;
		kbase[oldKomaName]._name = komaName;
		
		var komaObj:Object = kbase[komaName];
		komaObj._y = initHeight + (k * 4 + divY) * komaHeight;
		komaObj.k = num;
	}
	
	// 矢印・フリーズアローの再配置・展開
	var hKomaCnt:Number = arrPos.length;
	for (var p:Number = 0; p < hKomaCnt; p++) {
		
		// コマの設定を取得
		var cp:Number = arrPos[p];
		var pl:String = zeroPadding(cp, 2, "0");
		
		for (var j:Number = 0; j < addLength; j++) {
			var num:Number = startKoma + j;
			var oldNum:Number = num + pageKoma;
			var oldKomaName:String = "arrMC_" + pl + "_" + oldNum;
			if(kbase[oldKomaName]._currentframe != 1){
				kbase[oldKomaName].gotoAndStop(1);
			}
			
			var komaName:String = "arrMC_" + pl + "_" + num;
			kbase[oldKomaName]._name = komaName;
			
			var komaObj:Object = kbase[komaName];
			komaObj._y = initHeight + (j + divY) * komaHeight;
//			komaObj.j = cp;
			komaObj.k = num;
		}
		
		// 譜面を展開（スクロール分）
		spreadScore(pl, cp, startKoma, 2, addLength);
		spreadScore(pl, cp + keyLabel, startKoma, 3, addLength);
	}

	// 速度データの再配置・展開
	for (var k:Number = 0; k < addLength; k++) {
		var num:Number = startKoma + k;
		var oldNum:Number = num + pageKoma;
		var oldKomaName:String = "arrMC_" + speedVal + "_" + oldNum;
		if(kbase[oldKomaName]._currentframe != 1){
			kbase[oldKomaName].gotoAndStop(1);
		}
		
		var komaName:String = "arrMC_" + speedVal + "_" + num;
		kbase[oldKomaName]._name = komaName;
		
		var komaObj:Object = kbase[komaName];
		komaObj._y = initHeight + (k + divY) * komaHeight;
		komaObj.k = num;
	}
	
	spreadScoreSpd(speedVal, speedPos, startKoma, 2, addLength);
	spreadScoreSpd(speedVal, boostPos, startKoma, 3, addLength);

	// 拍子データの展開
	spreadScoreRhythm(rhythmVal, rhythmPos, startKoma, 2, addLength);

	if(kfix["fix__MC_" + beforeBar]._currentframe != 1){
		kfix["fix__MC_" + beforeBar].gotoAndStop(1);
	}
	kfix["fix__MC_" + beforeBar]._name = "fix__MC_" + currentBar;
	
	if(kfix["lbl__MC_" + beforeBar]._currentframe != 1){
		kfix["lbl__MC_" + beforeBar].gotoAndStop(1);
	}
	kfix["lbl__MC_" + beforeBar]._name = "lbl__MC_" + currentBar;
	
	if(kfix["sel__MC_" + beforeBar]._currentframe != 1){
		kfix["sel__MC_" + beforeBar].gotoAndStop(1);
	}
	kfix["sel__MC_" + beforeBar]._name = "sel__MC_" + currentBar;
}

/*
	譜面を展開(矢印・フリーズアロー)
	@param	pl			左からの位置 (arrSortでは矢印順ではないため)
	@param	pos			矢印番号
	@param	startKoma	開始コマ番号
	@param	jmpFrame	矢印：2, フリーズアロー:3
*/
function spreadScore(pl:String, pos:Number, startKoma:Number, jmpFrame:Number, lengthKoma:Number):Void {
	
	var obj:Array = arrow_temp[pos];
	var objLength:Number = obj.length;
	var endKoma:Number = startKoma + lengthKoma;
	var popStart:Number = this.binarySearch(startKoma, obj, 0, objLength - 1);
	
	for (var v:Number = popStart; v < objLength; v++) {
		var arrTemp:Number = obj[v];
		if (arrTemp < startKoma) {
		} else if (arrTemp < endKoma) {
			kbase["arrMC_" + pl + "_" + arrTemp].gotoAndStop(jmpFrame);
		} else {
			break;
		}
	}
}

/*
	譜面を展開(速度データ)
	@param	pl			左からの位置 (arrSortでは矢印順ではないため)
	@param	pos			矢印番号
	@param	startKoma	開始コマ番号
	@param	jmpFrame	全体加速：2, 個別加速:3
*/
function spreadScoreSpd(pl:String, pos:Number, startKoma:Number, jmpFrame:Number, lengthKoma:Number):Void {
	
	var obj:Object = arrow_temp[pos];
	var objLength:Number = obj.length;
	var endKoma:Number = startKoma + lengthKoma;
	var popStart:Number = this.binarySearchSpd(startKoma, obj, 0, objLength - 1);
	
	for (var v:Number = popStart; v < objLength; v++) {
		var arrTemp:Number = obj[v].pos;
		if (arrTemp < startKoma) {
		} else if (arrTemp < endKoma) {
			kbase["arrMC_" + pl + "_" + arrTemp].gotoAndStop(jmpFrame);
			kbase["arrMC_" + pl + "_" + arrTemp].spd.text = obj[v].spd;
		} else {
			break;
		}
	}
}

/*
	譜面を展開(3連符切替)
	@param	pl			左からの位置 (arrSortでは矢印順ではないため)
	@param	pos			矢印番号
	@param	startKoma	開始コマ番号
	@param	jmpFrame	3連符：2
*/
function spreadScoreRhythm(pl:String, pos:Number, startKoma:Number, jmpFrame:Number, lengthKoma:Number):Void {
	
	var obj:Array = arrow_temp[pos];
	var objLength:Number = obj.length;
	var rhyStartKoma:Number = startKoma / 4;
	var rhyEndKoma:Number = (startKoma + lengthKoma) /4;
	var popStart:Number = this.binarySearch(rhyStartKoma, obj, 0, objLength - 1);
	
	for (var v:Number = popStart; v < objLength; v++) {
		var arrTemp:Number = obj[v];
		if (arrTemp < rhyStartKoma) {
		} else if (arrTemp < rhyEndKoma) {
			kbase["arrMC_" + pl + "_" + arrTemp].gotoAndStop(jmpFrame);
			changeKomaSize(arrTemp);
		} else {
			break;
		}
	}
}

//------------------------------------------------------------
// 3連符切替ボタン押下処理 (4拍子→3連符)
// [引数
//			rhyTemp : 4拍子→3連符に変更した小節位置]
//------------------------------------------------------------
function changeKomaSize(rhyTemp:Number):Void
{

	var heightC:Number = 4 * rhyTemp;
	for (var a:Number = 0; a < keyLabel; a++) {
		var pl:String = zeroPadding(a, 2, "0");

		for (var j:Number = heightC; j < heightC + 3; j++) {
			var cHeight:Number = kbase["arrMC_" + pl + "_" + j]._height;
			kbase["arrMC_" + pl + "_" + j]._height = komaHeight * 4 / 3;//8;
			kbase["arrMC_" + pl + "_" + j]._y += (j - heightC) * (komaHeight / 3);
		}
		kbase["arrMC_" + pl + "_" + j]._visible = false;
		kbase["arrMC_" + pl + "_" + j].gotoAndStop(1);

		popArrow(2 * a,j);
		popArrow(2 * a + 1,j);
	}

	var pl:String = zeroPadding(keyLabel, 2, "0");

	for (var j:Number = heightC; j < heightC + 3; j++) {
		var cHeight:Number = kbase["arrMC_" + pl + "_" + j]._height;
		kbase["arrMC_" + pl + "_" + j]._height = cHeight * 4 / 3;//.spdBtn._yscale = 133;//8;
		kbase["arrMC_" + pl + "_" + j]._y += (j - heightC) * (komaHeight / 3);
	}
	kbase["arrMC_" + pl + "_" + j]._visible = false;
	kbase["arrMC_" + pl + "_" + j].gotoAndStop(1);

	popArrow(2 * keyLabel,j);
}

function changeKomaSizeR(rhyTemp:Number, baseArrs:Array):Array
{

	var heightC:Number = 4 * rhyTemp;
	for (var a:Number = 0; a < keyLabel; a++) {
		var pl:String = zeroPadding(a, 2, "0");

		for (var j:Number = heightC; j < heightC + 3; j++) {
			var cHeight:Number = kbase["arrMC_" + pl + "_" + j]._height;
			kbase["arrMC_" + pl + "_" + j]._height = komaHeight * 4 / 3;//8;
			kbase["arrMC_" + pl + "_" + j]._y += (j - heightC) * (komaHeight / 3);
		}
		kbase["arrMC_" + pl + "_" + j]._visible = false;
		kbase["arrMC_" + pl + "_" + j].gotoAndStop(1);

		baseArrs[2 * a] = popArrowR(baseArrs[2 * a], j);
		baseArrs[2 * a + 1] = popArrowR(baseArrs[2 * a + 1], j);
	}

	var pl:String = zeroPadding(keyLabel, 2, "0");

	for (var j:Number = heightC; j < heightC + 3; j++) {
		var cHeight:Number = kbase["arrMC_" + pl + "_" + j]._height;
		kbase["arrMC_" + pl + "_" + j]._height = cHeight * 4 / 3;//spdBtn._yscale = 133;//8;
		kbase["arrMC_" + pl + "_" + j]._y += (j - heightC) * (komaHeight / 3);
	}
	kbase["arrMC_" + pl + "_" + j]._visible = false;
	kbase["arrMC_" + pl + "_" + j].gotoAndStop(1);

	baseArrs[2 * keyLabel] = popArrowR(baseArrs[2 * keyLabel], j);
	
	return baseArrs;
}

//------------------------------------------------------------
// 3連符切替ボタン押下処理 (3連符→4拍子)
// [引数
//			rhyTemp : 4拍子→3連符に変更した小節位置]
//------------------------------------------------------------
function resetKomaSize(rhyTemp:Number):Void
{

	var heightC:Number = 4 * rhyTemp;
	for (var a:Number = 0; a < keyLabel; a++) {
		var pl:String = zeroPadding(a, 2, "0");
		for (var j:Number = heightC; j < heightC + 3; j++) {
			kbase["arrMC_" + pl + "_" + j]._height = komaHeight;
			kbase["arrMC_" + pl + "_" + j]._y -= (j - heightC) * (komaHeight / 3);
		}
		kbase["arrMC_" + pl + "_" + j]._visible = true;
	}

	var pl:String = zeroPadding(keyLabel, 2, "0");
	for (var j:Number = heightC; j < heightC + 3; j++) {
		if(kbase["arrMC_" + pl + "_" + j]._currentframe == 1){
			kbase["arrMC_" + pl + "_" + j]._height = komaHeight;
		}else{
			kbase["arrMC_" + pl + "_" + j]._height = komaHeight * 2.25;
		}
		kbase["arrMC_" + pl + "_" + j]._y -= (j - heightC) * (komaHeight / 3);
	}
	kbase["arrMC_" + pl + "_" + j]._visible = true;
}

//------------------------------------------------------------
// テンポ変化設定
// [引数なし]
//------------------------------------------------------------
function set_interval(startBar:Number):Void
{
	// 小節数
	var barDiv:Number = barBlank * 4;
	var barNum:Number = Math.ceil(pageKoma / barDiv);
	
	// 初回のみフレーム情報用のテキストフィールドを作成
	if (kfix.timeline0 == undefined) {
		
		// フォーマット定義
		var fmt:TextFormat = new TextFormat();
		fmt.size = 12;
		fmt.font = "Times New Roman";
		
		var fmtTm:TextFormat = new TextFormat();
		fmtTm.size = 12;
		fmtTm.font = "Times New Roman";
		fmtTm.color = 0x0000cc;
		
		var fmtB:TextFormat = new TextFormat();
		fmtB.size = 12;
		fmtB.font = "Times New Roman";
		fmtB.align = "right";
		
		for (var j:Number = 0; j < timelineNum; j++) {
			
			var barY:Number = initHeight + j * komaHeight * barDiv;
			
			// 小節単位のフレーム数(4拍子のみ半小節)
			kfix["timeline" + j] = kfix.createTextField("text_field", -100 + j, -2, (barY + 2), 50, 20);
			kfix["timeline" + j].setNewTextFormat(fmt);
			kfix["timeline" + j].selectable = false;
			
			// 小節数
			kfix["barLineN" + j] = kfix.createTextField("text_field", -50 + j, -2, (barY + 2), 25, 20);
			kfix["barLineN" + j].setNewTextFormat(fmtB);
			kfix["barLineN" + j]._x = -25;
			kfix["barLineN" + j]._y = barY + 2;
			kfix["barLineN" + j].selectable = false;
			kfix["barLineN" + j].align = "right";
			
			// テンポ変化位置
			kfix["barLineR" + j]._y = barY;
			kfix["barLineR" + j].swapDepths(18000 + j);
			kfix["barLineR" + j]._visible = false;
			
			// ラベル位置
			kfix["barLineL" + j]._y = barY;
			kfix["barLineL" + j].swapDepths(15000 + j);
			kfix["barLineL" + j]._visible = false;
			
			// 範囲指定
			kfix["barLineT" + j]._y = barY;
			kfix["barLineT" + j].swapDepths(12000 + j);
			kfix["barLineT" + j]._visible = false;
			
			// swf時刻
			kfix["cTime" + j] = kfix.createTextField("text_field", 50 + j, -2, (initHeight + komaHeight * (barDiv * j + 2.5) + 2), 40, 20);
			kfix["cTime" + j].setNewTextFormat(fmtTm);
			kfix["cTime" + j].selectable = false;
		}
	}
	
	// 現在のページ位置
	var currentPageN:Number = (page - 1) * timelineNum + startBar;
	
	// テンポ変化位置のポインター
	var line:Number = 1;
	
	// ラベル位置のポインター
	var lineL:Number = 1;
	
	// 範囲指定のポインター
	var lineT:Number = 1;
	
	// テンポ変化位置検索
	var startFixCnt:Number = haba_array.length - 1;
	var startFixPos:Number = 0;
	while (startFixCnt >= 0)
	{
		startFixPos = Math.round(haba_array[startFixCnt].num * timelineNum);
		if (Math.round(currentPageN - startFixPos) >= 0) {
			kfix["fix__MC_" + haba_array[startFixCnt].num].gotoAndStop(2);
			break;
		}
		startFixCnt--;
	}
	var w:Number = (currentPageN - startFixPos) / timelineNum;
	
	// ラベル位置検索
	var startLblCnt:Number = lblArray.length - 1;
	var startLblPos:Number = 0;
	while (startLblCnt >= 0)
	{
		startLblPos = Math.round(lblArray[startLblCnt] * timelineNum);
		if (Math.round(currentPageN - startLblPos) >= 0) {
			kfix["lbl__MC_" + lblArray[startLblCnt]].gotoAndStop(2);
			break;
		}
		startLblCnt--;
	}
	
	// 範囲指定検索
	var startSelCnt:Number = selArray.length - 1;
	var startSelPos:Number = -1;
	while (startSelCnt >= 0)
	{
		startSelPos = Math.round(selArray[startSelCnt] * timelineNum);
		if (Math.round(currentPageN - startSelPos) >= 0) {
			kfix["sel__MC_" + selArray[startSelCnt]].gotoAndStop(2);
			break;
		}
		startSelCnt--;
	}
	
	// 4分間隔・BPM設定
	haba4_num = haba_array[startFixCnt].blank;
	bpm_num = Math.round(1800 / haba4_num * 10000) / 10000;
	
	// ファーストナンバー(head_num)・ページ先頭ナンバー(first_num)設定
	head_num = parseFloat(haba_array[startFixCnt].header);
	head_temp = head_num;// head_numとの比較用変数
	first_num = head_num + w * haba4_num * pageKoma / 2;
	
	var tmpFirst:Number = first_num;
	var tmpBlank:Number = haba4_num;

	// テンポ変化・ラベルバーの設定・各小節のフレーム数設定
	kfix.barLineR0._visible = (Math.round(currentPageN - startFixPos) == 0 ? true : false);
	kfix.barLineL0._visible = (Math.round(currentPageN - startLblPos) == 0 ? true : false);
	kfix.barLineT0._visible = (Math.round(currentPageN - startSelPos) == 0 ? true : false);
	kfix.barLineN0.text = (beatNum == 4 ? (currentPageN % 2 == 0 ? currentPageN / 2 : "") : currentPageN);
	if(selArray.length == 2 
	   && Math.round(currentPageN - selArray[0] * timelineNum) >= 0
	   && Math.round(currentPageN - selArray[1] * timelineNum) < 0){
		tBar._y = initHeight;
		if(currentPageN + (1 - selArray[1]) * timelineNum <= 0){
			tBar._height = pageKoma * komaHeight;
		}
	}else{
		tBar._y = -20;
		tBar._height = komaHeight;
	}
	
	var lineNum:Number = Math.round(10 * tmpFirst) / 10;
	kfix.timeline0.text = lineNum;
	
	var min:String = zeroPadding(Math.floor(lineNum / 3600), 2, "0");
	var sec:String = zeroPadding(Math.floor(lineNum / 60) % 60, 2, "0");
	kfix.cTime0.text = "[" + min + ":" + sec + "]";
	kfix.cTime0.background = true;
	
	currentPageN++;

	// ページ表示分ループ
	var df:Number = 0;
	for (var s:Number = 1; s < barNum; s++, currentPageN++) {
		
		// テンポ変化のライン位置
		if (haba_array[startFixCnt + line].num != undefined && currentPageN == Math.round(haba_array[startFixCnt + line].num * timelineNum)) {
			tmpFirst = parseFloat(haba_array[startFixCnt + line].header);
			tmpBlank = haba_array[startFixCnt + line].blank;
			df = s;
			kfix["barLineR" + s]._visible = true;
			line++;
		}else{
			kfix["barLineR" + s]._visible = false;
		}
		
		// ラベルのライン位置
		if (lblArray[startLblCnt + lineL] != undefined && currentPageN == Math.round(lblArray[startLblCnt + lineL] * timelineNum)) {
			kfix["barLineL" + s]._visible = true;
			lineL++;
		}else{
			kfix["barLineL" + s]._visible = false;
		}
		
		// 範囲指定のライン位置
		if (selArray[startSelCnt + lineT] != undefined && currentPageN == Math.round(selArray[startSelCnt + lineT] * timelineNum)) {
			kfix["barLineT" + s]._visible = true;
			if(selArray.length == 2){
				if(startSelCnt + lineT == 0){
					tBar._y = initHeight + s * komaHeight * barDiv;
					if((page - selArray[1]) * timelineNum + startBar <= 0){
						tBar._height = (barNum - s + 1) * komaHeight * barDiv;
					}
				}else{
					tBar._height = initHeight + s * komaHeight * barDiv - tBar._y;
				}
			}
			lineT++;
		}else{
			kfix["barLineT" + s]._visible = false;
		}
		
		var lineNum:Number = Math.round(10 * (tmpFirst + tmpBlank * barDiv / 2 * (s - df))) / 10;
		kfix["timeline" + s].text = lineNum;
		kfix["barLineN" + s].text = (beatNum == 4 ? (currentPageN % 2 == 0 ? currentPageN / 2 : "") : currentPageN);
		if(currentPageN % (timelineNum / 2) == 0 || kfix["barLineR" + s]._visible == true){
			var min:String = zeroPadding(Math.floor(lineNum / 3600), 2, "0");
			var sec:String = zeroPadding(Math.floor(lineNum / 60) % 60, 2, "0");
			kfix["cTime" + s].text = "[" + min + ":" + sec + "]";
			kfix["cTime" + s].textColor = (kfix["barLineR" + s]._visible == true ? 0x0000cc : 0x000033);
			kfix["cTime" + s].background = true;
		}else{
			kfix["cTime" + s].text = "";
			kfix["cTime" + s].background = false;
		}
	}
}

//------------------------------------------------------------
// ３連符のコード整理
// 　　連続して３連符になっている部分をまとめる（バースト部分の集約）
//　　 変換部分のコード処理もここで行っている
// [引数
//           rhy : 3連符/4拍子のタイムライン]
// [返却値なし]
//------------------------------------------------------------
function set_rhythm(rhy:Array):Void
{

	rhythm_save[0] = rhy[0];
	for (var l:Number = 0; l < rhy.length; l++) {
		var plus:Number = 0;
		rhythm_save[l] = rhy[l];
		rhy_temp.push(rhy[l] * 4 + 1);
		while (rhy[l + plus + 1] - rhy[l + plus] == 1)
		{
			rhythm_save[l + (++plus)] = "";
		}
		rhy_temp.push(rhy[l + plus] * 4 + 2);
		l += plus;
	}
	delete rhy;
}
//------------------------------------------------------------
// 3連符/4拍子の振り分け処理
// 　　振り分けを行うと同時に、値計算も一緒に行っている
// [引数
//           num : 番号, 
//           arr_data : 矢印のデータ, 
//           rhy_data : 3連符データ]
// [返却値なし]
//------------------------------------------------------------
function push_timeline(num:Number, arr_data:Array, rhy_data:Array):Void
{
	var a:Number = num;
	var q:Number = haba_array.length - 1;
	var v:Number = arr_data.length - 1;// arr_data : 矢印のデータ
	var w:Number = rhy_data.length - 2;// rhy_data : バースト部分をまとめた3連符データ
	var startKoma:Number = haba_array[q].num * pageKoma;
	var pointNum:Number = haba_array[q].header;
	var pointBlank:Number = haba_array[q].blank / 2;
	var tempoChFlg:Boolean = false;
	var judgeMin:Number = Infinity;

	while (v >= 0)
	{

		if (w == -2) {
			break;
		}
		while (arr_data[v] - startKoma < 0)
		{
			startKoma = haba_array[--q].num * pageKoma;
			pointNum = haba_array[q].header;
			pointBlank = haba_array[q].blank / 2;
			tempoChFlg = true;
		}

		if (arr_data[v] > rhy_data[w + 1]) {
			// 4拍子のタイムライン処理
			timeline[a].unshift(Math.round(pointNum + (arr_data[v--] - startKoma) * pointBlank));
		} else if (arr_data[v] >= rhy_data[w]) {
			// 3連符のタイムライン処理
			var arr_rhy:Number = arr_data[v] % 4;
			timeline[a].unshift(Math.round(pointNum + (arr_data[v--] - startKoma + arr_rhy / 3) * pointBlank));
		} else {
			w -= 2;
			continue;
		}

		// テンポ変化かつ値が逆転している場合は、ソートフラグを立てる
		// ソート対象の最終位置と、その中の最小値を特定する
		if (tempoChFlg == true) {
			if (timeline[a][1] != undefined && timeline[a][0] >= timeline[a][1]) {
				var cnt:Number = 1;
				if(judgeMin > timeline[a][1]){
					judgeMin = timeline[a][1];
					mergeVal = v + 2;
				}
				while (timeline[a][++cnt] != undefined)
				{
					if (timeline[a][0] < timeline[a][cnt]) {
						break;
					}
				}
				if (mergeMax < v + cnt) {
					mergeMax = v + cnt;
				}
				mergeFlg = true;
			}
			tempoChFlg = false;
		}
	}

	while (v >= 0)
	{
		while (arr_data[v] - startKoma < 0)
		{
			startKoma = haba_array[--q].num * pageKoma;
			pointNum = haba_array[q].header;
			pointBlank = haba_array[q].blank / 2;
			tempoChFlg = true;
		}
		timeline[a].unshift(Math.round(pointNum + (arr_data[v--] - startKoma) * pointBlank));

		// テンポ変化かつ値が逆転している場合は、ソートフラグを立てる
		if (tempoChFlg == true) {
			if (timeline[a][1] != undefined && timeline[a][0] >= timeline[a][1]) {
				var cnt:Number = 1;
				if(judgeMin > timeline[a][1]){
					judgeMin = timeline[a][1];
					mergeVal = v + 2;
				}
				while (timeline[a][++cnt] != undefined)
				{
					if (timeline[a][0] < timeline[a][cnt]) {
						break;
					}
				}
				if (mergeMax < v + cnt) {
					mergeMax = v + cnt;
				}
				mergeFlg = true;
			}
			tempoChFlg = false;
		}
	}
}

function push_timeline_spd(num:Number, arr_data:Array, rhy_data:Array):Void
{
	var a:Number = num;
	var q:Number = _root.haba_array.length - 1;
	var v:Number = arr_data.length - 1;// arr_data : 矢印のデータ
	var w:Number = rhy_data.length - 2;// rhy_data : バースト部分をまとめた3連符データ
	var startKoma:Number = haba_array[q].num * pageKoma;
	var pointNum:Number = haba_array[q].header;
	var pointBlank:Number = haba_array[q].blank / 2;
	var tempoChFlg:Boolean = false;
	var judgeMin:Number = Infinity;

	while (v >= 0)
	{

		if (w == -2) {
			break;
		}

		while (arr_data[v].pos - startKoma < 0)
		{
			startKoma = haba_array[--q].num * pageKoma;
			pointNum = haba_array[q].header;
			pointBlank = haba_array[q].blank / 2;
			tempoChFlg = true;
		}

		if (arr_data[v].pos > rhy_data[w + 1]) {
			// 4拍子のタイムライン処理
			timeline[a].unshift({pos:Math.round(pointNum + (arr_data[v].pos - startKoma) * pointBlank), spd:arr_data[v].spd});
			v--;
		} else if (arr_data[v].pos >= rhy_data[w]) {
			// 3連符のタイムライン処理
			var arr_rhy:Number = arr_data[v].pos % 4;
			timeline[a].unshift({pos:Math.round(pointNum + (arr_data[v].pos - startKoma + arr_rhy / 3) * pointBlank), spd:arr_data[v].spd});
			v--;
		} else {
			w -= 2;
			continue;
		}

		if (tempoChFlg == true) {
			if (timeline[a][1] != undefined && timeline[a][0].pos >= timeline[a][1].pos) {
				var cnt:Number = 1;
				if(judgeMin > timeline[a][1].pos){
					judgeMin = timeline[a][1].pos;
					mergeVal = v + 2;
				}
				while (timeline[a][++cnt] != undefined)
				{
					if (timeline[a][0].pos < timeline[a][cnt].pos) {
						break;
					}
				}
				if (mergeMax < v + cnt) {
					mergeMax = v + cnt;
				}
				mergeFlg = true;
			}
			tempoChFlg = false;
		}
	}

	while (v >= 0)
	{

		while (arr_data[v].pos - startKoma < 0)
		{
			startKoma = haba_array[--q].num * pageKoma;
			pointNum = haba_array[q].header;
			pointBlank = haba_array[q].blank / 2;
			tempoChFlg = true;
		}
		timeline[a].unshift({pos:Math.round(pointNum + (arr_data[v].pos - startKoma) * pointBlank), spd:arr_data[v].spd});
		v--;

		if (tempoChFlg == true) {
			if (timeline[a][1] != undefined && timeline[a][0].pos >= timeline[a][1].pos) {
				var cnt:Number = 1;
				if(judgeMin > timeline[a][1].pos){
					judgeMin = timeline[a][1].pos;
					mergeVal = v + 2;
				}
				while (timeline[a][++cnt] != undefined)
				{
					if (timeline[a][0].pos < timeline[a][cnt].pos) {
						break;
					}
				}
				if (mergeMax < v + cnt) {
					mergeMax = v + cnt;
				}
				mergeFlg = true;
			}
			tempoChFlg = false;
		}
	}
}
//------------------------------------------------------------
// 重複削除
// [引数
//           arr : タイムライン]
// [返却値重複計算後のタイムライン]
//------------------------------------------------------------
function deleteDuplication(arr:Array):Array
{

	var tmpObj:Object = new Object();
	var uniqueArr:Array = new Array();
	for (var j:Number = 0; j < arr.length; ++j) {
		var tmpValue:Number = arr[j];
		if (!tmpObj[tmpValue]) {
			tmpObj[tmpValue] = true;
			uniqueArr.push(tmpValue);
		}
	}

	return uniqueArr;
}

function deleteDuplicationSpd(arr:Array):Array
{

	var tmpObj:Object = new Object();
	var uniqueArr:Array = new Array();
	for (var j:Number = 0; j < arr.length; ++j) {
		var tmpValue:Number = arr[j].pos;
		if (!tmpObj[tmpValue]) {
			tmpObj[tmpValue] = true;
			uniqueArr.push({pos:tmpValue, spd:arr[j].spd});
		}
	}

	return uniqueArr;
}

// データ部分のソート
function sortTemp()
{
	for (var j:Number = 0; j < speedPos; j++) {
		quickSort(arrow_temp[j]);
	}
	arrow_temp[speedPos].sortOn("pos",16);
	arrow_temp[boostPos].sortOn("pos",16);
	quickSort(arrow_temp[rhythmPos]);
}
//------------------------------------------------------------
// 出力部分の整理
// [引数なし]
// [返却値譜面データ]
//------------------------------------------------------------
function print_out():String
{
	var typeNum = parseInt(_global.print_type.slice(4));
	var show_pre:String = "";

	if (headerOn == "ON" && headerInfo != undefined) {
		show_pre += headerInfo.split("\r").join("\r\n").split("&").join(separatorParam);
	}
	if (_global.print_type == "Type1") {
		var header:String = headerDat[typeNum];
		for (var j:Number = 0; j < header.length; j++) {
			show_pre += separatorParam + header[j] + tune_name + "_data=" + timeline[j];
		}
		show_pre += separatorParam + "boost" + tune_name + "_data=";
		var boostTmp:Array = new Array();
		for (var j:Number = 0; j < timeline[boostPos].length; j++) {
			boostTmp[j] = timeline[boostPos][j].pos + "," + timeline[boostPos][j].spd;
		}
		show_pre += boostTmp.toString();

		show_pre += separatorParam + "speed" + tune_name + (keysTmp == "5" ? "_data=" : "_change=");
		var speedTmp:Array = new Array();
		for (var j = 0; j < timeline[speedPos].length; j++) {
			speedTmp[j] = timeline[speedPos][j].pos + "," + timeline[speedPos][j].spd;
		}
		show_pre += speedTmp.toString();
		show_pre += separatorParam;

		if (inswfFlg == true) {
			for (var j:Number = 0; j < header.length; j++) {
				_level0._root[header[j] + "_data_edit"] = timeline[j];
			}
			_level0._root.tuning_edit = tuning;
		}

	} else if (_global.print_type == "Type2") {
		header = headerDat[typeNum];
		for (var j:Number = 0; j < header.length; j++) {
			show_pre += "&" + header[j] + tune_name + "Data=" + timeline[j] + "\r\n";
		}

		var speedTmp:Array = new Array();
		for (var j:Number = 0; j < timeline[speedPos].length; j++) {
			speedTmp[j] = timeline[speedPos][j].pos + "," + timeline[speedPos][j].spd;
		}
		var boostTmp:Array = new Array();
		for (var j:Number = 0; j < timeline[boostPos].length; j++) {
			boostTmp[j] = timeline[boostPos][j].pos + "," + timeline[boostPos][j].spd;
		}
		show_pre += "&speed" + tune_name + "Data=" + speedTmp.toString() + "\r\n&boost" + tune_name + "Data=" + boostTmp.toString();
	}
	if (colorOn == "ON" && footerInfo != undefined) {
		show_pre += footerInfo.split("\r").join("\r\n").split("&").join(separatorParam);
	}
	if (tune_on == "ON") {
		for (var v:Number = 0; v < _root.haba_array.length; v++) {
			first_temp[v] = _root.haba_array[v].header;
			haba_temp1[v] = _root.haba_array[v].blank;
			haba_temp2[v] = _root.haba_array[v].num;
		}
		show_pre += "\r\n\r\n&first_num=" + first_temp + "&haba_num=" + haba_temp1 +
					"&haba_page_num=" + haba_temp2 + "&rhythm_num=" + arrow_temp[rhythmPos] +
					"&label_num=" + lblArray + "&beat_num=" + beatNum + "&tuning=" + tuning + "&dataEnd=true";
	}
	if(editorMode == "HTML5"){
		show_pre +=  separatorParam + "tuning=" + tuning + separatorParam;
		show_pre = show_pre.split("'").join("&#39;");
	}

	return show_pre;
}

//------------------------------------------------------------
// セーブデータ出力
// [引数
//           printFlg : falseのとき、出力ボタンを押したときに一部処理をスキップ]
// [返却値なし]
//------------------------------------------------------------
function saveEditor(printFlg:Boolean):Void
{

	var show_save_pre:String = _root.keysTmp + "/";
	for (var a:Number = 0; a < speedPos; a++) {
		show_save_pre += arrow_temp[a] + "&";
	}
	var speedTmp:Array = new Array();
	for (var j:Number = 0; j < arrow_temp[speedPos].length; j++) {
		speedTmp[j] = arrow_temp[speedPos][j].pos + "=" + arrow_temp[speedPos][j].spd;
	}

	var boostTmp:Array = new Array();
	for (var j:Number = 0; j < arrow_temp[boostPos].length; j++) {
		boostTmp[j] = arrow_temp[boostPos][j].pos + "=" + arrow_temp[boostPos][j].spd;
	}
	show_save_pre += speedTmp + "&" + boostTmp + "&";

	if (!printFlg) {
		rhythm_save = [];
		if (!isNaN(parseFloat(arrow_temp[rhythmPos][0]))) {
			this.set_rhythm(arrow_temp[rhythmPos]);
		}
	}
	show_save_pre += rhythm_save + "&";

	if (tune_on != "ON" || !printFlg) {
		first_temp = [];
		haba_temp1 = [];
		haba_temp2 = [];

		for (var v = 0; v < haba_array.length; v++) {
			first_temp[v] = haba_array[v].header;
			haba_temp1[v] = haba_array[v].blank;
			haba_temp2[v] = haba_array[v].num * multiX;
		}
	}
	lblArrayP = [];
	for(var j = 0; j < lblArray.length; j++){
		lblArrayP[j] = lblArray[j] * multiX;
	}
	show_save_pre += first_temp + "&" + haba_temp1 + "&" + haba_temp2 + "&" + tune_num + "&" + pageMax + "&" + Math.floor(64/ beatNum / 4) * beatNum + "&" + barBlank + "&" + lblArrayP + "&\r\n\r\n";

	// ヘッダー
	if (headerInfo != "") {
		show_save_pre += headerInfo + "\r\n";
	}
	// 矢印色データ(フッター) 
	if (footerInfo != "") {
		show_save_pre += footerInfo + "\r\n";
	}
	show_save_pre += "&tuning=" + tuning + "&";

	show_save_num2 = str_replace("NaN,", "", show_save_pre);
	show_save_num = str_replace("NaN", "", show_save_num2);

	mySharedObject = SharedObject.getLocal("localdata");
	mySharedObject.data.message = show_save_num;
}

//------------------------------------------------------------
// セーブデータ出力（ドイル）
// [引数なし]
// [返却値なし]
//------------------------------------------------------------
function saveDoyleEditor():Void
{

	var tuneTmp:String = (tune_num == "1" ? "" : tune_num);
	var show_save_pre:String = "Dancing Onigiri Save Data";

	// ヘッダー抽出
	var headers:LoadVars = new LoadVars();
	headers.decode(headerInfo);
	var musicArr:Array = headers.musicTitle.split(",");
	show_save_pre += "&musictitle=" + (musicArr[0] == undefined ? "" : musicArr[0]) + "&artist=" + (musicArr[1] == undefined ? "" : musicArr[1]) + "&artisturl=" + (musicArr[2] == undefined ? "http://www.google.co.jp/" : musicArr[2]) + "&difName=" + (headers.difName == undefined ? "Normal" : headers.difName) + "&speedlock=" + (headers.speedlock == undefined ? "1" : headers.speedlock) + "&index=" + tuneTmp + "&key=" + keysTmp;

	// 譜面データ保存
	for (var a:Number = 0; a < keyLabel; a++) {
		show_save_pre += "&arrow_data(" + a + ")=" + arrow_temp[a];
	}
	for (var a:Number = 0; a < keyLabel; a++) {
		show_save_pre += "&frzarrow_data(" + a + ")=" + arrow_temp[a + keyLabel];
	}
	show_save_pre += "&speed_data=";
	var speedTmp:Array = new Array();
	for (var j:Number = 0; j < arrow_temp[speedPos].length; j++) {
		speedTmp[j] = arrow_temp[speedPos][j].pos + "," + arrow_temp[speedPos][j].spd;
	}
	show_save_pre += speedTmp.toString();
	var first_data_pre:String = "&first_data=";
	var interval_data_pre:String = "&interval_data=";
	var interval_pre:Number = 0;

	for (var v:Number = 0; v < haba_array.length; v++) {

		first_data_pre += haba_array[v].header;
		interval_data_pre += haba_array[v].blank;
		var interval_next:Number = (v < haba_array.length - 1 ? haba_array[v + 1].num * multiX : pageMax * 8);

		for (var u:Number = interval_pre; u < interval_next; u++) {
			first_data_pre += ",";
			interval_data_pre += ",";
		}
		interval_pre = interval_next;
	}
	show_save_pre += first_data_pre + interval_data_pre;
	show_save_pre += "&rhythmchange_data=" + arrow_temp[rhythmPos];
	show_save_pre += "&version=2.38&dosPath=&tuning=" + tuning;

	show_save_num2 = str_replace("NaN,", "", show_save_pre);
	show_save_num = str_replace("NaN", "", show_save_num2);

	mySharedObject = SharedObject.getLocal("localdata");
	mySharedObject.data.message = show_save_num;
}

//------------------------------------------------------------
// セーブデータ出力（FUJI ver2）
// [引数なし]
// [返却値なし]
//------------------------------------------------------------
function saveFujiEditor():Void
{
	var show_save_pre:String = "";
	var barInterval:Number;

	this.set_interval(pagePos / barBlank / 4);
	if (barBlank == 2) {
		barInterval = pageKoma / timelineNum;
	} else if (barBlank == 3) {
		barInterval = pageKoma / timelineNum / 2;
	} else {
		barInterval = pageKoma / timelineNum / 4;
	}

	var finalNum:Number = 0;
	for (var a:Number = 0; a < rhythmPos; a++) {
		var lastn:Number = arrow_temp[a].length - 1;
		if (finalNum < arrow_temp[a][lastn]) {
			finalNum = arrow_temp[a][lastn];
		}
	}
	var pageBar:Number = pageKoma / 4;
	var jmpCnt = (barBlank > 8 ? 4 : (barBlank > 4 ? 2 : 1));
	var jmpNum:Number = 16 * jmpCnt - barBlank * 4;
	var maxBar:Number = Math.ceil((finalNum + 1) / pageBar);
	if (maxBar < 120) {
		maxBar = 120;
	}

	var lastNumArray:Array = new Array();
	for (var a:Number = 0; a < haba_array.length; a++) {
		var tmpBaseFirstNum:Number = haba_array[a].header;
		var tmpBaseHabaNum:Number = haba_array[a].blank;
		var tmpBasePageNum:Number = haba_array[a].num * multiX;

		if (a == haba_array.length - 1) {
			lastNumArray[a] = tmpBaseHabaNum * (maxBar - tmpBasePageNum * 4) * barInterval;
			break;
		} else if (haba_array[a + 1].num * 4 * multiX > maxBar) {
			lastNumArray[a] = tmpBaseHabaNum * (maxBar - tmpBasePageNum * 4) * barInterval;
			break;
		} else {
			lastNumArray[a] = tmpBaseHabaNum * (haba_array[a + 1].num * multiX - tmpBasePageNum) * 4 * barInterval;
		}
	}

	// ヘッダ出力
	var expName:String = tuning;

	show_save_pre = keysTmp + "key2.00\r\n" + tune_num + "\r\n\r\n" + "0/" + (Math.round(haba_array[0].header * 10)) + ",";
	for (var a:Number = 1; a < haba_array.length; a++) {
		show_save_pre += (haba_array[a].num * 4 * multiX) + "/";
		if (haba_array[a - 1].header + lastNumArray[a - 1] == haba_array[a].header) {
			show_save_pre += (Math.round(haba_array[a].header * 10)) + ",";
		} else {
			var lastNum:Number = Math.round(haba_array[a - 1].header * 10) + Math.round(lastNumArray[a - 1] * 10);
			show_save_pre += lastNum + "/" + (Math.round(haba_array[a].header * 10)) + ",";
		}
	}
	var lastNum:Number = Math.round(haba_array[a - 1].header * 10) + Math.round(lastNumArray[haba_array.length - 1] * 10);
	show_save_pre += maxBar + "/" + lastNum + ",\r\n";

	// 拍飛ばし情報
	if (barBlank == 2) {
	} else {
		jmpData = "";
		for (var j:Number = -1 + jmpCnt; j < maxBar - 1; j += jmpCnt) {
			if(jmpNum > 16){
				jmpData += (j-1) + "/" + (jmpNum - 16);
				jmpData += "," + j + "/" + 16;
			} else {
				jmpData += j + "/" + jmpNum;
			}
			jmpData += ",";
		}
		jmpData += j + "/" + jmpNum;
		show_save_pre += jmpData;
	}

	show_save_pre += "\r\n;===以下譜面\r\n";

	// 小節部:00～15, 矢印部:0～6, 調整部:1桁

	// 譜面(矢印出力)
	var arrFdat:Array = new Array();

	for (var a:Number = 0; a < keyLabel; a++) {

		for (var b:Number = 0; b < arrow_temp[a].length; b++) {
			var tmpNum:Number = (barBlank != 2 ? arrow_temp[a][b] + jmpNum * Math.floor(arrow_temp[a][b] / (barBlank * 4)) : arrow_temp[a][b]);
			if (arrFdat[tmpNum] == undefined) {
				arrFdat[tmpNum] = new Array();
			}
			var mod16:Number = tmpNum % 16;
			var mod16_2d:String = mod16.toString(16);
			arrFdat[tmpNum].push(mod16_2d + a.toString(36) + "0");
		}

		// フリーズ開始：小節部:00～15, 矢印部:0～6, 調整部:1桁(開始Def:5)
		// 譜面(フリーズアロー出力)
		for (var b:Number = 0; b < arrow_temp[a + keyLabel].length; b++) {
			var tmpNum:Number = (barBlank != 2 ? arrow_temp[a + keyLabel][b] + jmpNum * Math.floor(arrow_temp[a + keyLabel][b] / (barBlank * 4)) : arrow_temp[a + keyLabel][b]);
			var tmpNum2:Number = (barBlank != 2 ? arrow_temp[a + keyLabel][b + 1] + jmpNum * Math.floor(arrow_temp[a + keyLabel][b + 1] / (barBlank * 4)) : arrow_temp[a + keyLabel][b + 1]);
			if (arrFdat[tmpNum] == undefined) {
				arrFdat[tmpNum] = new Array();
			}
			// フリーズ開始     
			if (b % 2 == 0) {
				var mod16s:Number = tmpNum % 16;
				var mod16s_2d:String = mod16s.toString(16);
				var frzHeader:String = mod16s_2d + a.toString(36) + "0+";

				var frzLength:Number = tmpNum2 - tmpNum;
				var frzMod_2d:String = zeroPadding(frzLength, 3, "0");
				arrFdat[tmpNum].push(frzHeader + frzMod_2d);

			// フリーズ終了 
			} else {
				var mod16e:Number = tmpNum % 16;
				var mod16e_2d:String = mod16e.toString(16);
				arrFdat[tmpNum].push(mod16e_2d + a.toString(36) + "0");
			}
		}
	}

	// 速度変化(全体)
	for (var b:Number = 0; b < arrow_temp[speedPos].length; b++) {
		var tmpNum:Number = (barBlank != 2 ? arrow_temp[speedPos][b].pos + jmpNum * Math.floor(arrow_temp[speedPos][b].pos / (barBlank * 4)) : arrow_temp[speedPos][b].pos);
		if (arrFdat[tmpNum] == undefined) {
			arrFdat[tmpNum] = new Array();
		}
		var mod16:Number = tmpNum % 16;
		var mod16_2d:String = mod16.toString(16);
		var spd16:String = "b";
		var spdZ:String  = Math.floor((arrow_temp[speedPos][b].spd + 16) % 16).toString(16).toUpperCase();
		if(arrow_temp[speedPos][b].spd >= 0){
			var spdS:String  = zeroPadding(Math.round(arrow_temp[speedPos][b].spd * 100) % 100, 2, "0");
		}else{
			var spdS:String  = zeroPadding((100 + Math.round(arrow_temp[speedPos][b].spd * 100)) % 100, 2, "0");
		}
		arrFdat[tmpNum].push(mod16_2d + spd16 + "0-" + spdZ + spdS);
	}

	// 速度変化(個別)
	for (var b:Number = 0; b < arrow_temp[boostPos].length; b++) {
		var tmpNum:Number = (barBlank != 2 ? arrow_temp[boostPos][b].pos + jmpNum * Math.floor(arrow_temp[boostPos][b].pos / (barBlank * 4)) : arrow_temp[boostPos][b].pos);
		if (arrFdat[tmpNum] == undefined) {
			arrFdat[tmpNum] = new Array();
		}
		var mod16:Number = tmpNum % 16;
		var mod16_2d:String = mod16.toString(16);
		var bst16:String = "c";
		var bstDat:String = zeroPadding(Math.abs(Math.round(arrow_temp[boostPos][b].spd * 100)), 3, "0");
		arrFdat[tmpNum].push(mod16_2d + bst16 + "0-" + bstDat);
	}

	var barIndex:Number = 0;
	for (var a:Number = 0; a < maxBar * 16; a++) {
		if (a % 16 == 0) {
			var barHeader = zeroPadding(barIndex, 3, "0");
			show_save_pre += barHeader + ":";
		}
		if (arrFdat[a] == undefined) {
		} else {
			show_save_pre += arrFdat[a] + ",";
		}
		if (a % 16 == 15) {
			show_save_pre += "\r\n";
			barIndex++;
		}
	}

	show_save_pre += ";===譜面製作者\r\n" + expName + "\r\n";
	show_save_pre += ";===ヘッダ\r\n";
	show_save_pre += headerInfo.split("\r").join("\r\n");
	show_save_pre += ";===フッタ\r\n";
	show_save_pre += footerInfo.split("\r").join("\r\n");
	show_save_pre += ";===ここまで";

	show_save_num2 = str_replace("NaN,", "", show_save_pre);
	show_save_num = str_replace("NaN", "", show_save_num2);

	mySharedObject = SharedObject.getLocal("localdata");
	mySharedObject.data.message = show_save_num.split("\r\n").join("\r");
}

//------------------------------------------------------------
// セーブデータ出力（FUJI nkey）
// [引数なし]
// [返却値なし]
//------------------------------------------------------------
function saveFujiNEditor():Void
{
	var show_save_pre:String = "";
	var barInterval:Number;

	this.set_interval(pagePos / barBlank / 4);
	if (barBlank == 2) {
		barInterval = pageKoma / timelineNum;
	} else if (barBlank == 3) {
		barInterval = pageKoma / timelineNum / 2;
	} else {
		barInterval = pageKoma / timelineNum / 4;
	}

	var finalNum:Number = 0;
	for (var a:Number = 0; a < rhythmPos; a++) {
		var lastn:Number = arrow_temp[a].length - 1;
		if (finalNum < arrow_temp[a][lastn]) {
			finalNum = arrow_temp[a][lastn];
		}
	}
	var pageBar:Number = pageKoma / 4;
	var jmpCnt = (barBlank > 8 ? 4 : (barBlank > 4 ? 2 : 1));
	var jmpNum:Number = 16 * jmpCnt - barBlank * 4;
	var maxBar:Number = Math.ceil((finalNum + 1) / pageBar);
	if (maxBar < 120) {
		maxBar = 120;
	}

	var lastNumArray:Array = new Array();
	for (var a:Number = 0; a < haba_array.length; a++) {
		var tmpBaseFirstNum:Number = haba_array[a].header;
		var tmpBaseHabaNum:Number = haba_array[a].blank;
		var tmpBasePageNum:Number = haba_array[a].num * multiX;

		if (a == haba_array.length - 1) {
			lastNumArray[a] = tmpBaseHabaNum * (maxBar - tmpBasePageNum * 4) * barInterval;
			break;
		} else if (haba_array[a + 1].num * 4 * multiX > maxBar) {
			lastNumArray[a] = tmpBaseHabaNum * (maxBar - tmpBasePageNum * 4) * barInterval;
			break;
		} else {
			lastNumArray[a] = tmpBaseHabaNum * (haba_array[a + 1].num * multiX  - tmpBasePageNum) * 4 * barInterval;
		}
	}

	// ヘッダ出力
	var expName:String = tuning;

	show_save_pre = "nkey1.000/template_" + keysTmp + "\r\n" + tune_num + "\r\n\r\n" + "0/" + (Math.round(haba_array[0].header * 10)) + ",";
	for (var a:Number = 1; a < haba_array.length; a++) {
		show_save_pre += (haba_array[a].num * 4 * multiX) + "/";
		if (haba_array[a - 1].header + lastNumArray[a - 1] == haba_array[a].header) {
			show_save_pre += (Math.round(haba_array[a].header * 10)) + ",";
		} else {
			var lastNum:Number = Math.round(haba_array[a - 1].header * 10) + Math.round(lastNumArray[a - 1] * 10);
			show_save_pre += lastNum + "/" + (Math.round(haba_array[a].header * 10)) + ",";
		}
	}
	var lastNum:Number = Math.round(haba_array[a - 1].header * 10) + Math.round(lastNumArray[haba_array.length - 1] * 10);
	show_save_pre += maxBar + "/" + lastNum + ",\r\n";

	// 拍飛ばし情報
	if (barBlank == 2) {
	} else {
		jmpData = "";
		for (var j:Number = -1 + jmpCnt; j < maxBar - 1; j += jmpCnt) {
			if(jmpNum > 16){
				jmpData += (j-1) + "/" + (jmpNum - 16);
				jmpData += "," + j + "/" + 16;
			} else {
				jmpData += j + "/" + jmpNum;
			}
			jmpData += ",";
		}
		jmpData += j + "/" + jmpNum;
		show_save_pre += jmpData;
	}

	show_save_pre += "\r\n;===以下譜面\r\n";

	// 小節部:00～15, 矢印部:0～6, 調整部:1桁

	// 譜面(矢印出力)
	var arrFdat:Array = new Array();

	for (var a:Number = 0; a < keyLabel; a++) {

		for (var b:Number = 0; b < arrow_temp[a].length; b++) {
			var tmpNum:Number = (barBlank != 2 ? arrow_temp[a][b] + jmpNum * Math.floor(arrow_temp[a][b] / (barBlank * 4)) : arrow_temp[a][b]);
			if (arrFdat[tmpNum] == undefined) {
				arrFdat[tmpNum] = new Array();
			}
			var mod16:Number = tmpNum % 16;
			var mod16_2d:String = mod16.toString(16).toUpperCase();
			arrFdat[tmpNum].push(mod16_2d + (a + 10).toString(36).toUpperCase() + "0");
		}

		// フリーズ開始：小節部:00～15, 矢印部:0～6, 調整部:1桁(開始Def:5)
		// 譜面(フリーズアロー出力)
		for (var b:Number = 0; b < arrow_temp[a + keyLabel].length; b++) {
			var tmpNum:Number = (barBlank != 2 ? arrow_temp[a + keyLabel][b] + jmpNum * Math.floor(arrow_temp[a + keyLabel][b] / (barBlank * 4)) : arrow_temp[a + keyLabel][b]);
			var tmpNum2:Number = (barBlank != 2 ? arrow_temp[a + keyLabel][b + 1] + jmpNum * Math.floor(arrow_temp[a + keyLabel][b + 1] / (barBlank * 4)) : arrow_temp[a + keyLabel][b + 1]);
			if (arrFdat[tmpNum] == undefined) {
				arrFdat[tmpNum] = new Array();
			}
			// フリーズ開始     
			if (b % 2 == 0) {
				var mod16s:Number = tmpNum % 16;
				var mod16s_2d:String = mod16s.toString(16).toUpperCase();
				var frzHeader:String = mod16s_2d + (a + 10).toString(36).toUpperCase() + "0+";

				var frzLength:Number = tmpNum2 - tmpNum;
				var frzMod_2d:String = zeroPadding(frzLength, 3, "0");
				arrFdat[tmpNum].push(frzHeader + frzMod_2d);

			// フリーズ終了 
			} else {
				var mod16e:Number = tmpNum % 16;
				var mod16e_2d:String = mod16e.toString(16).toUpperCase();
				arrFdat[tmpNum].push(mod16e_2d + (a + 10).toString(36).toUpperCase() + "0");
			}
		}
	}

	// 速度変化(全体)
	for (var b:Number = 0; b < arrow_temp[speedPos].length; b++) {
		var tmpNum:Number = (barBlank != 2 ? arrow_temp[speedPos][b].pos + jmpNum * Math.floor(arrow_temp[speedPos][b].pos / (barBlank * 4)) : arrow_temp[speedPos][b].pos);
		if (arrFdat[tmpNum] == undefined) {
			arrFdat[tmpNum] = new Array();
		}
		var mod16:Number = tmpNum % 16;
		var mod16_2d:String = mod16.toString(16).toUpperCase();
		var spd16:String = "U";
		var spdZ:String  = Math.floor((arrow_temp[speedPos][b].spd + 16) % 16).toString(16).toUpperCase();
		if(arrow_temp[speedPos][b].spd >= 0){
			var spdS:String  = zeroPadding(Math.round(arrow_temp[speedPos][b].spd * 100) % 100, 2, "0");
		}else{
			var spdS:String  = zeroPadding((100 + Math.round(arrow_temp[speedPos][b].spd * 100)) % 100, 2, "0");
		}
		arrFdat[tmpNum].push(mod16_2d + spd16 + "0-" + spdZ + spdS);
	}

	// 速度変化(個別)
	for (var b:Number = 0; b < arrow_temp[boostPos].length; b++) {
		var tmpNum:Number = (barBlank != 2 ? arrow_temp[boostPos][b].pos + jmpNum * Math.floor(arrow_temp[boostPos][b].pos / (barBlank * 4)) : arrow_temp[boostPos][b].pos);
		if (arrFdat[tmpNum] == undefined) {
			arrFdat[tmpNum] = new Array();
		}
		var mod16:Number = tmpNum % 16;
		var mod16_2d:String = mod16.toString(16).toUpperCase();
		var bst16:String = "V";
		var bstZ:String  = Math.floor((arrow_temp[boostPos][b].spd + 16) % 16).toString(16).toUpperCase();
		var bstS:String  = zeroPadding(Math.abs(Math.round(arrow_temp[boostPos][b].spd * 100) % 100), 2, "0");
		arrFdat[tmpNum].push(mod16_2d + bst16 + "0-" + bstZ + bstS);
	}

	var barIndex:Number = 0;
	for (var a:Number = 0; a < maxBar * 16; a++) {
		if (a % 16 == 0) {
			var barHeader = zeroPadding(barIndex, 3, "0");
			show_save_pre += barHeader + ":";
		}
		if (arrFdat[a] == undefined) {
		} else {
			show_save_pre += arrFdat[a] + ",";
		}
		if (a % 16 == 15) {
			show_save_pre += "\r\n";
			barIndex++;
		}
	}

	show_save_pre += ";===譜面製作者\r\n" + expName + "\r\n";
	show_save_pre += ";===ヘッダ\r\n";
	show_save_pre += headerInfo.split("\r").join("\r\n");
	show_save_pre += ";===フッタ\r\n";
	show_save_pre += footerInfo.split("\r").join("\r\n");
	show_save_pre += ";===ここまで";

	show_save_num2 = str_replace("NaN,", "", show_save_pre);
	show_save_num = str_replace("NaN", "", show_save_num2);

	mySharedObject = SharedObject.getLocal("localdata");
	mySharedObject.data.message = show_save_num.split("\r\n").join("\r");
}

//------------------------------------------------------------
// クイックソート (非再帰)
// [引数
//           array : ソート前配列]
// [返却値なし]
//------------------------------------------------------------
function quickSort(array:Array)
{

	var i:Number, j:Number;
	var work:Number;
	var pivot:Number;// 枢軸 
	var leftStack:Array = new Array();
	var rightStack:Array = new Array();// スタック 
	var sp:Number;//  スタックポインタ 
	var left:Number, right:Number;

	// スタックを初期化する 
	leftStack[0] = 0;
	rightStack[0] = array.length - 1;
	sp = 1;

	// スタックが空になるまで繰り返す 
	while (sp > 0)
	{
		// ソートする範囲をスタックからポップ 
		--sp;
		left = leftStack[sp];
		right = rightStack[sp];

		// ソート範囲に含まれる要素数が１つだけなら、何もする必要はない 
		if (left < right) {
			pivot = partition2(array, left, right);

			// 左右の部分のうち、小さい方の範囲を先に処理するようにする 
			if (pivot - left < right - pivot) {

				leftStack[sp] = pivot + 1;
				rightStack[sp++] = right;
				leftStack[sp] = left;
				rightStack[sp++] = pivot - 1;
			} else {
				leftStack[sp] = left;
				rightStack[sp++] = pivot - 1;
				leftStack[sp] = pivot + 1;
				rightStack[sp++] = right;
			}
		}
	}
}

//------------------------------------------------------------
// パーティション分割 (非再帰)
// [引数
//           array : 対象配列
//           i  : 左位置
//           j  : 右位置 ]
// [返却値軸位置 ]
//------------------------------------------------------------
function partition2(arr:Array, i:Number, j:Number):Number
{
	var left:Number = i - 1;
	var right:Number = j;

	var pivot:Number = arr[j];

	for (; ; ) {
		while (arr[++left] < pivot)
		{
		}
		while (left < --right && pivot < arr[right])
		{
		}
		if (left >= right) {
			break;
		}

		var tmp:Number = arr[left];
		arr[left] = arr[right];
		arr[right] = tmp;
	}
	var tmp:Number = arr[left];
	arr[left] = arr[j];
	arr[j] = tmp;

	return left;
}

//------------------------------------------------------------
// 2分探索 
// [引数
//           key: 探索対象,
//           arr: 探索対象配列,
//           low: 左端位置, 
//           high: 右端位置]
// [返却値対象位置(一致しない場合は値の小さい方を返却)]
//------------------------------------------------------------
function binarySearch(key:Number, arr:Array, low:Number, high:Number):Number
{

	while (low <= high)
	{
		var mid:Number = Math.floor((low + high) / 2);
		if (arr[mid] == key) {
			return mid;
		} else if (arr[mid] < key) {
			low = mid + 1;
		} else {
			high = mid - 1;
		}
	}
	return (high < 0 ? 0 : high);
}

function binarySearchSpd(key:Number, arr:Object, low:Number, high:Number):Number
{

	while (low <= high)
	{
		var mid:Number = Math.floor((low + high) / 2);
		if (arr[mid].pos == key) {
			return mid;
		} else if (arr[mid].pos < key) {
			low = mid + 1;
		} else {
			high = mid - 1;
		}
	}
	return (high < 0 ? 0 : high);
}


//------------------------------------------------------------
// 矢印挿入
// [引数
//           j : 矢印位置, 
//           komaArr: 対象コマ]
// [返却値なし]
//------------------------------------------------------------
function pushArrow(j:Number, komaArr:Array):Void
{

	var low:Number = 0;
	var high:Number = _root.arrow_temp[j].length - 1;

	// 挿入候補位置を検索
	var popStart:Number = this.binarySearch(komaArr[0], arrow_temp[j], low, high);

	for (var n:Number = 0; n < komaArr.length; n++) {
		for (var k:Number = popStart; k < arrow_temp[j].length; k++) {
			if (arrow_temp[j][k] > komaArr[n]) {
				var aftArr:Array = arrow_temp[j].splice(k);
				arrow_temp[j] = arrow_temp[j].concat([komaArr[n]], aftArr);
				break;
			}
		}
		if (k == arrow_temp[j].length) {
			arrow_temp[j].push(komaArr[n]);
		}
	}
}

function pushArrowR(baseArr:Array, addArr:Array):Array
{
	var low:Number = 0;
	var high:Number = baseArr.length - 1;

	// 挿入候補位置を検索
	var popStart:Number = this.binarySearch(addArr[0], baseArr, low, high);

	for (var n:Number = 0; n < addArr.length; n++) {
		for (var k:Number = popStart; k < baseArr.length; k++) {
			if (baseArr[k] > addArr[n]) {
				var aftArr:Array = baseArr.splice(k);
				baseArr = baseArr.concat([addArr[n]], aftArr);
				break;
			}
		}
		if (k == baseArr.length) {
			baseArr.push(addArr[n]);
		}
	}
	return baseArr;
}

//------------------------------------------------------------
// 矢印削除
// (コマを確実に消す必要があるため、binarySearchは使用しない)
// [引数
//           j : 矢印位置, 
//           koma: 対象コマ]
// [返却値なし]
//------------------------------------------------------------
function popArrow(j:Number, koma:Number):Void
{

	var low:Number = 0;
	var high:Number = _root.arrow_temp[j].length - 1;

	while (low <= high)
	{
		var mid:Number = Math.floor((low + high) / 2);
		if (arrow_temp[j][mid] == koma) {
			arrow_temp[j].splice(mid,1);
			break;

		} else if (arrow_temp[j][mid] < koma) {
			low = mid + 1;
		} else {
			high = mid - 1;
		}
	}
}

function popArrowR(baseArr:Array, koma:Number):Array
{
	var low:Number = 0;
	var high:Number = baseArr.length - 1;

	while (low <= high)
	{
		var mid:Number = Math.floor((low + high) / 2);
		if (baseArr[mid] == koma) {
			baseArr.splice(mid,1);
			break;

		} else if (baseArr[mid] < koma) {
			low = mid + 1;
		} else {
			high = mid - 1;
		}
	}
	return baseArr;
}

//------------------------------------------------------------
// 範囲指定内の矢印データ抽出
// [引数
//           j         : 矢印位置
//           startFrame: 開始位置
//           endFrame  : 終了位置
//           delFlg    : 範囲内のコマのカット有無 ]
// [返却値範囲内の矢印データ ]
//------------------------------------------------------------
function popArrowRange(j:Number, startFrame:Number, endFrame:Number, delFlg:Boolean):Array
{

	var low:Number = 0;
	var high:Number = _root.arrow_temp[j].length - 1;

	// 対象範囲の先頭位置を検索
	var popStart:Number = this.binarySearch(startFrame, arrow_temp[j], low, high);
	var delCnt:Number = 0;

	// どの位置までが対象範囲内かをカウント
	for (var n:Number = popStart; n < arrow_temp[j].length; n++) {
		if (arrow_temp[j][n] < startFrame) {
			popStart++;
		} else if (arrow_temp[j][n] < endFrame) {
			delCnt++;
		} else {
			break;
		}
	}

	// 範囲内の矢印データを抽出
	// (カット：配列から切り出し / コピー：配列からコピー)
	if (delCnt > 0) {
		var returnArr:Array = (delFlg ? arrow_temp[j].splice(popStart, delCnt) : arrow_temp[j].slice(popStart, popStart + delCnt));
		for (var j = 0; j < returnArr.length; j++) {
			returnArr[j] -= startFrame;
		}
	} else {
		var returnArr:Array = [];
	}

	return returnArr;
}

//------------------------------------------------------------
// 速度挿入
// [引数
//            j : 矢印位置, 
//            komaPosArr : 対象コマ位置, 
//            komaSpdArr: 速度]
// [返却値なし]
//------------------------------------------------------------
function pushArrowSpd(j:Number, komaPosArr:Array, komaSpdArr:Array):Void
{

	var low:Number = 0;
	var high:Number = arrow_temp[j].length - 1;

	// 挿入候補位置を検索
	var popStart:Number = this.binarySearchSpd(komaPosArr[0], arrow_temp[j], low, high);

	for (var n:Number = 0; n < komaPosArr.length; n++) {
		for (var k:Number = popStart; k < arrow_temp[j].length; k++) {
			if (arrow_temp[j][k].pos > komaPosArr[n]) {
				var aftArr:Array = arrow_temp[j].splice(k);
				arrow_temp[j] = arrow_temp[j].concat([{pos:komaPosArr[n], spd:komaSpdArr[n]}], aftArr);
				break;
			}
		}
		if (k == arrow_temp[j].length) {
			arrow_temp[j].push({pos:komaPosArr[n], spd:komaSpdArr[n]});
		}
	}

}

//------------------------------------------------------------
// 速度削除
// (コマを確実に消す必要があるため、binarySearchSpdは使用しない)
// [引数
//           j : 矢印位置, 
//           koma: 対象コマ]
// [返却値なし]
//------------------------------------------------------------
function popArrowSpd(j:Number, koma:Number):Void
{

	var low:Number = 0;
	var high:Number = arrow_temp[j].length - 1;

	while (low <= high)
	{
		var mid:Number = Math.floor((low + high) / 2);
		if (arrow_temp[j][mid].pos == koma) {
			arrow_temp[j].splice(mid,1);
			break;

		} else if (arrow_temp[j][mid].pos < koma) {
			low = mid + 1;
		} else {
			high = mid - 1;
		}
	}
}

//------------------------------------------------------------
// 範囲指定内の速度データ抽出
// [引数
//           j         : 矢印位置
//           startFrame: 開始位置
//           endFrame  : 終了位置
//           delFlg    : 範囲内のコマのカット有無 ]
// [返却値範囲内の速度データ ]
//------------------------------------------------------------
function popArrowSpdRange(j:Number, startFrame:Number, endFrame:Number, delFlg:Boolean):Array
{

	var low:Number = 0;
	var high:Number = arrow_temp[j].length - 1;

	// 対象範囲の先頭位置を検索
	var popStart:Number = this.binarySearchSpd(startFrame, arrow_temp[j], low, high);
	var delCnt:Number = 0;

	// どの位置までが対象範囲内かをカウント
	for (var n:Number = popStart; n < arrow_temp[j].length; n++) {
		if (arrow_temp[j][n].pos < startFrame) {
			popStart++;
		} else if (arrow_temp[j][n].pos < endFrame) {
			delCnt++;
		} else {
			break;
		}
	}

	// 範囲内の速度データを抽出
	// (カット：配列から切り出し / コピー：配列からコピー)
	var returnArr:Array = new Array();
	
	if (delCnt > 0) {
		var tmpArr:Array = (delFlg ? arrow_temp[j].splice(popStart, delCnt) : 
							arrow_temp[j].slice(popStart, popStart + delCnt));
		for (var j:Number = 0; j < tmpArr.length; j++){
			returnArr[j] = {pos : tmpArr[j].pos - startFrame, spd : tmpArr[j].spd};
		}
	}
	return returnArr;
}

//------------------------------------------------------------
// テンポ変化位置挿入
// [引数
//           fixPos : 対象位置]
// [返却値なし]
//------------------------------------------------------------
function pushFix(fixPos:Number):Void
{

	for (var k:Number = 0; k < haba_array.length; k++) {
		if (haba_array[k].num > fixPos) {
			var aftArr:Array = haba_array.splice(k);
			haba_array = haba_array.concat([{num:fixPos, header:head_num, blank:haba4_num}], aftArr);
			break;
		}
	}
	if (k == haba_array.length) {
		haba_array.push({num:fixPos, header:head_num, blank:haba4_num});
	}

}

//------------------------------------------------------------
// 挿入
// [引数
//           array : 配列, 
//           listPos : 挿入位置]
// [返却値挿入後配列]
//------------------------------------------------------------
function pushList(arr:Array, listPos:Number):Array
{

	for (var k:Number = 0; k < arr.length; k++) {
		if (arr[k] > listPos) {
			var aftArr:Array = arr.splice(k);
			arr = arr.concat([listPos], aftArr);
			break;
		}
	}
	if (k == arr.length) {
		arr.push(listPos);
	}
	return arr;
}

//------------------------------------------------------------
// 下スクロール設定
// [引数
//           resetFlg : コマを一回クリアするかどうかのフラグ ]
// [返却値なし]
//------------------------------------------------------------
function scrollDown(resetFlg:Boolean):Void
{
	if (page != pageMax) {
		var delPosCnt:Number  = 0;
		var delPageCnt:Number = 0;
		
		delPosCnt += barBlank * 4 * scrollSpd;
		if (pagePos + delPosCnt >= pageKoma) {
			delPageCnt++;
			if(page + delPageCnt >= pageMax){
				delPosCnt = pageKoma - pagePos;
			}
		}
		
		if (resetFlg == true) {
			delete_koma_scr(pageKoma * (page - 1) + pagePos);
		}
		pagePos = (pagePos + delPosCnt) % pageKoma;
		page += delPageCnt;
		
		if (barBlank == 2 && scrollSpd == 1) {
			deleteLines();
			drawLines(pagePos);
		}
		if (page >= pageMax) {
			this.pageBtnUnabled("next");
		} else if (page == 1 && pagePos > 0) {
			this.pageBtnEnabled("prev");
		}
		make_koma_scrdown(pageKoma * (page - 1) + pagePos, delPosCnt);
		set_interval(pagePos / barBlank / 4);
	}
}

//------------------------------------------------------------
// 下スクロール設定(次のラベルへ)
// [引数なし]
// [返却値なし]
//------------------------------------------------------------
function scrollNextLabel():Void
{
	if (page != pageMax) {
		var currentKoma:Number = pageKoma * (page - 1) + pagePos;
		var currentPage:Number = currentKoma / pageKoma;
		delete_koma_scr(currentKoma);
		var beforeStartKoma:Number = currentKoma;
		for (var j:Number = 0; j < lblArray.length; j++) {
			if (currentPage < lblArray[j]) {
				currentPage = lblArray[j];
				currentKoma = currentPage * pageKoma;
				break;
			}
		}
		tmpPage = Math.floor(currentPage) + 1;
		tmpPagePos = currentKoma - (tmpPage - 1) * pageKoma;
		
		var endNum:Number = 0;
		for (var j = 0; j < speedPos; j++) {
			if (!isNaN(parseFloat(arrow_temp[j][0]))) {
				var k:Number = arrow_temp[j].length - 1;
				if (endNum < parseInt(arrow_temp[j][k])) {
					endNum = parseInt(arrow_temp[j][k]);
				}
			}
		}
		pageLast = Math.floor(endNum / pageKoma) + 1;
		
		if(page < pageLast && (pageLast < tmpPage || page == tmpPage)){
			page = pageLast;
			pagePos = 0;
			currentKoma = (pageLast -1) * pageKoma;
		}else{
			page = tmpPage;
			pagePos = tmpPagePos;
		}
		
		if (barBlank == 2) {
			deleteLines();
			drawLines(pagePos);
		}
		if (page >= pageMax) {
			this.pageBtnUnabled("next");
			this.pageBtnEnabled("prev");
		} else if (page > 1 || pagePos > 0) {
			this.pageBtnEnabled("prev");
		}
		make_koma_clear(currentKoma, beforeStartKoma);
		set_interval(pagePos / barBlank / 4);
	}
}

//------------------------------------------------------------
// 上スクロール設定
// [引数
//           resetFlg : コマを一回クリアするかどうかのフラグ ]
// [返却値なし]
//------------------------------------------------------------
function scrollUp(resetFlg:Boolean):Void
{
	if (page == 1 && pagePos == 0) {
	} else {
		var delPosCnt:Number  = 0;
		var delPageCnt:Number = 0;
		
		delPosCnt += barBlank * 4 * scrollSpd;
		if (pagePos - delPosCnt < 0) {
			if(page == 1){
				delPosCnt = pagePos;
			}else{
				delPageCnt++;
			}
		}
		
		if (resetFlg == true) {
			delete_koma_scr(pageKoma * (page - 1) + pagePos);
		}
		pagePos = (pagePos + pageKoma - delPosCnt) % pageKoma;
		page -= delPageCnt;
		
		if (barBlank == 2 && scrollSpd == 1) {
			deleteLines();
			drawLines(pagePos);
		}
		if (page == 1 && pagePos == 0) {
			this.pageBtnUnabled("prev");
			deleteLines();
			drawLines(pagePos);
		} else if (page == pageMax - 1) {
			this.pageBtnEnabled("next");
		}
		make_koma_scrup(pageKoma * (page - 1) + pagePos, delPosCnt);
		set_interval(pagePos / barBlank / 4);
	}
}

//------------------------------------------------------------
// 上スクロール設定(前のラベルへ)
// [引数なし]
// [返却値なし]
//------------------------------------------------------------
function scrollPrevLabel():Void
{
	if (page == 1 && pagePos == 0) {
	} else {
		var currentKoma:Number = pageKoma * (page - 1) + pagePos;
		var currentPage:Number = currentKoma / pageKoma;
		delete_koma_scr(currentKoma);
		var beforeStartKoma:Number = currentKoma;
		for (var j = lblArray.length - 1; j >= 0; j--) {
			if (currentPage > lblArray[j]) {
				currentPage = lblArray[j];
				currentKoma = currentPage * pageKoma;
				break;
			}
		}
		tmpPage = Math.floor(currentPage) + 1;
		tmpPagePos = currentKoma - (tmpPage - 1) * pageKoma;
		
		var endNum:Number = 0;
		for (var j = 0; j < speedPos; j++) {
			if (!isNaN(parseFloat(arrow_temp[j][0]))) {
				var k:Number = arrow_temp[j].length - 1;
				if (endNum < parseInt(arrow_temp[j][k])) {
					endNum = parseInt(arrow_temp[j][k]);
				}
			}
		}
		pageLast = Math.floor(endNum / pageKoma) + 1;
		
		if(page > pageLast && (pageLast > tmpPage || page == tmpPage)){
			page = pageLast;
			pagePos = 0;
			currentKoma = (pageLast -1) * pageKoma;
		}else{
			page = tmpPage;
			pagePos = tmpPagePos;
		}
		
		if (barBlank == 2) {
			deleteLines();
			drawLines(pagePos);
		}
		if (page == 1 && pagePos == 0) {
			this.pageBtnUnabled("prev");
			this.pageBtnEnabled("next");
		} else if (page < pageMax) {
			this.pageBtnEnabled("next");
		}
		make_koma_clear(currentKoma, beforeStartKoma);
		set_interval(pagePos / barBlank / 4);
	}
}

//------------------------------------------------------------
// ページ移動
// [引数
//           pushCnt : 押下状態(0でリセット)]
// [返却値押下状態]
//------------------------------------------------------------
function pageRight(pageNum:Number, pushCnt:Number, resetFlg:Boolean):Number
{

	var pageUp:Number = pageNum;// 「shift」を押しながらで５ページ進む

	if (page >= pageMax) {
	} else {
		if (pushCnt == 0 && resetFlg == true) {
			rollStartKoma = pageKoma * (page - 1) + pagePos;
			delete_koma_scr(rollStartKoma);
			
		//	if (barBlank == 2) {
				deleteLines();
		//	}
		}
		var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
		page += pageUp;
		pagePos = (resetFlg == true ? 0 : pagePos);
		if (page >= pageMax) {
			page = pageMax;
			this.pageBtnUnabled("next");
		} else if (page - pageUp == 1) {
			this.pageBtnEnabled("prev");
		}
		if (resetFlg == false) {
			make_koma_clear(pageKoma * (page - 1) + pagePos, beforeStartKoma);
		}
		set_interval(pagePos / barBlank / 4);
	}
	return ++pushCnt;
}

//------------------------------------------------------------
// ページ移動
// [引数
//            pushCnt : 押下状態(0でリセット)]
// [返却値押下状態]
//------------------------------------------------------------
function pageLeft(pageNum:Number, pushCnt:Number, resetFlg:Boolean):Number
{

	var pageDown:Number = (resetFlg == true && pagePos != 0 ? pageNum - 1 : pageNum);// 「shift」を押しながらで５ページ戻る

	if (page <= 1 && pagePos == 0) {
	} else {
		if (pushCnt == 0 && resetFlg == true) {
			rollStartKoma = pageKoma * (page - 1) + pagePos;
			delete_koma_scr(rollStartKoma);
			
		//	if (barBlank == 2) {
				deleteLines();
		//	}
		}
		var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
		page -= pageDown;
		pagePos = (resetFlg == true ? 0 : pagePos);
		if (page <= 1) {
			page = 1;
			this.pageBtnUnabled("prev");
		} else if (page + pageDown == pageMax) {
			// 最後のページだけフレーム移動
			this.pageBtnEnabled("next");
		}
		if (resetFlg == false) {
			make_koma_clear(pageKoma * (page - 1) + pagePos, beforeStartKoma);
		}
		set_interval(pagePos / barBlank / 4);
	}
	return ++pushCnt;
}

function pageBtnUnabled(dir:String)
{
	this.btnUnabled(dir + "Btn");
	this.btnUnabled(dir + "5Btn");
	this.btnUnabled(dir + "ScrBtn");
}
function pageBtnEnabled(dir:String):Void
{
	this.btnEnabled(dir + "Btn");
	this.btnEnabled(dir + "5Btn");
	this.btnEnabled(dir + "ScrBtn");
}

function btnUnabled(mc:String):Void
{
	this.sidebg[mc].enabled = false;
	this.sidebg[mc]._alpha = 30;
}
function btnEnabled(mc:String):Void
{
	this.sidebg[mc].enabled = true;
	this.sidebg[mc]._alpha = 100;
}

function deleteLines():Void
{
	for (j = 0; j <= measure; j++) {
		kfix["barLine" + j].removeMovieClip();
	}
}

function drawLines(pagePos:Number):Void
{
	var modNum:Number = (pagePos % 16 == 0 ? 0 : 2);
	
	for (j = 0; j <= measure; j++) {
		if (j % lineBlank == modNum) {
			kfix.barLine.duplicateMovieClip("barLine" + j,j);
			kfix["barLine" + j]._x = barStartPos;
		} else {
			kfix.barLinem.duplicateMovieClip("barLine" + j,j);
			if(j % barBlank != 0){
				kfix["barLine" + j]._x = barMidStartPos;
				kfix["barLine" + j]._width = barMidWidth;
			}
		}
		kfix["barLine" + j]._y = initHeight + j * komaHeight * 4;
	}
}

//------------------------------------------------------------
// 矢印コピー・カット(範囲指定)
// [引数
//           startKoma : 開始位置
//           lengthKoma: 対象コマ数
//           copyFlg   : 範囲内のコマのコピー有無
//           delFlg    : 範囲内のコマのカット有無 ]
// [返却値なし]
//------------------------------------------------------------
function komaCut(startKoma:Number, lengthKoma:Number, copyFlg:Boolean, delFlg:Boolean)
{

	var startFrame:Number = startKoma;
	var endFrame:Number = startKoma + lengthKoma;

	// 矢印・フリーズアロー
	for (var k:Number = 0; k < speedPos; k++) {
		var tmpArr:Array = [];

		// 範囲内の矢印データを抽出
		if (!isNaN(parseFloat(arrow_temp[k][0])) && _root.arrow_temp[k][arrow_temp[k].length - 1] >= startFrame) {
			tmpArr = popArrowRange(k, startFrame, endFrame, delFlg);
		}
		// コピーの場合は抽出データを退避     
		if (copyFlg == true) {
			tempKoma[k] = tmpArr.concat();
		}
	}

	// 速度成分
	for (var k:Number = speedPos; k <= boostPos; k++) {
		var tmpArr:Array = [];
		if (!isNaN(parseFloat(arrow_temp[k][0].pos)) && arrow_temp[k][arrow_temp[k].length - 1].pos >= startFrame) {
			tmpArr = popArrowSpdRange(k, startFrame, endFrame, delFlg);
		}
		if (copyFlg == true) {
			tempKoma[k] = tmpArr.concat();
		}
	}

	// リズム部分
	var startFrame2:Number = startFrame / 4;
	var endFrame2:Number = endFrame / 4;
	var tmpArr:Array = [];

	if (!isNaN(parseFloat(arrow_temp[rhythmPos][0])) && arrow_temp[rhythmPos][arrow_temp[rhythmPos].length - 1] >= startFrame2) {
		tmpArr = popArrowRange(rhythmPos, startFrame2, endFrame2, delFlg);
	}
	if (copyFlg == true) {
		tempKoma[rhythmPos] = tmpArr.concat();
	}
	copyKeys = keysTmp;
}


//------------------------------------------------------------
// 矢印ペースト(範囲指定)
// [引数    startKoma : 開始位置
//          dupliFlg  : ペーストの重ね有無
//          (false : 上書きペースト, true : 重ねペースト)
//          copyFlg   : 範囲内のコマのコピー有無
//          delFlg    : 範囲内のコマのカット有無 ]
// [返却値なし]
//------------------------------------------------------------
function komaPaste(startKoma:Number, tempKoma:Object, dupliFlg:Boolean)
{
	// コマをペースト（重ねペースト）
	var rhy:Number = startKoma;
	var rhy2:Number = rhy / 4;
	var rhys:Array = [];
	var copyKeyNum:Number = parseInt(copyKeys);
	var minKeys:Number = (copyKeyNum < keyLabel ? copyKeyNum : keyLabel);

	for (var i:Number = 0; i < minKeys; i++) {
		pl = (i < 10 ? "0" + i : i);

		rhys = [];
		for (var q:Number = 0; q < tempKoma[i].length; q++) {
			rhys[q] = parseInt(rhy + tempKoma[i][q]);
		}
		if(rhys.length > 0){
			pushArrow(i,rhys);
		}
		
		if(i + copyKeyNum < keyLabel && copyKeyNum > keyLabel){
		} else {
			rhys = [];
			for (var q:Number = 0; q < tempKoma[i + copyKeyNum].length; q++) {
				rhys[q] = parseInt(rhy + tempKoma[i + copyKeyNum][q]);
			}
			if(rhys.length > 0){
				pushArrow(i + keyLabel,rhys);
			}
		}
	}

	rhys = [];
	spds = [];
	for (var q:Number = 0; q < tempKoma[2 * copyKeyNum].length; q++) {
		rhys[q] = parseInt(rhy + tempKoma[2 * copyKeyNum][q].pos);
		spds[q] = tempKoma[2 * copyKeyNum][q].spd;
	}
	if(rhys.length > 0){
		pushArrowSpd(speedPos,rhys,spds);
	}

	rhys = [];
	spds = [];
	for (var q:Number = 0; q < tempKoma[2 * copyKeyNum + 1].length; q++) {
		rhys[q] = parseInt(rhy + tempKoma[2 * copyKeyNum + 1][q].pos);
		spds[q] = tempKoma[2 * copyKeyNum + 1][q].spd;
	}
	if(rhys.length > 0){
		pushArrowSpd(boostPos,rhys,spds);
	}

	rhys = [];
	for (var q:Number = 0; q < tempKoma[2 * copyKeyNum + 2].length; q++) {
		rhys[q] = parseInt(rhy2 + tempKoma[2 * copyKeyNum + 2][q]);
	}
	if(rhys.length > 0){
		pushArrow(rhythmPos,rhys);
	}

	// 重複排除処理
	if (dupliFlg == true) {
		for (var i:Number = 0; i < speedPos; i++) {
			arrow_temp[i] = deleteDuplication(arrow_temp[i]);
		}
		arrow_temp[speedPos] = deleteDuplicationSpd(arrow_temp[speedPos]);
		arrow_temp[boostPos] = deleteDuplicationSpd(arrow_temp[boostPos]);
		arrow_temp[rhythmPos] = deleteDuplication(arrow_temp[rhythmPos]);
	}
}

//------------------------------------------------------------
// 譜面の押し上げ・押し下げ
// [引数    num       : 譜面の移動方向 (1 : 押し下げ, -1 : 押し上げ)
//          startKoma : 開始位置
//          mov       : 譜面の移動幅 ]
// [返却値なし]
//------------------------------------------------------------
function pageShift(num:Number, startKoma:Number, mov:Number)
{

	for (var j:Number = 0; j < speedPos; j++) {
		for (var k:Number = 0; k < arrow_temp[j].length; k++) {
			if (arrow_temp[j][k] < startKoma - mov) {
			} else if (arrow_temp[j][k] < startKoma) {
				if (num == -1) {
					return;
				}
			} else {
				arrow_temp[j][k] += num * mov;
			}
		}
	}
	for (var j:Number = speedPos; j <= boostPos; j++) {
		for (var k:Number = 0; k < arrow_temp[j].length; k++) {
			if (arrow_temp[j][k].pos < startKoma - mov) {
			} else if (arrow_temp[j][k].pos < startKoma) {
				if (num == -1) {
					return;
				}
			} else {
				arrow_temp[j][k].pos += num * mov;
			}
		}
	}
	for (var k:Number = 0; k < arrow_temp[rhythmPos].length; k++) {
		if (arrow_temp[rhythmPos][k] < (startKoma - mov) / 4) {
		} else if (arrow_temp[rhythmPos][k] < startKoma / 4) {
			if (num == -1) {
				return;
			}
		} else {
			arrow_temp[rhythmPos][k] += num * mov / 4;
		}
	}
	for (var k:Number = 1; k < lblArray.length; k++) {
		if (lblArray[k] < (startKoma - mov) / pageKoma) {
		} else if (lblArray[k] < startKoma / pageKoma) {
			if (num == -1) {
				return;
			}
		} else {
			lblArray[k] += num * mov / pageKoma;
		}
	}

	delete_koma_scr(startKoma);

	for (var k:Number = 1; k < haba_array.length; k++) {
		if (haba_array[k].num < (startKoma - mov) / pageKoma) {
		} else if (haba_array[k].num < startKoma / pageKoma) {
			if (num == -1) {
				make_koma_clear(startKoma, startKoma);
				set_interval(pagePos / barBlank / 4);
				return;
			}
		} else {
			haba_array[k].num += num * mov / pageKoma;
		}
	}
	if (num == 1) {
		if (mov == pageKoma) {
			pageRight(1,0,false);
		} else {
			scrollDown(false);
		}
	} else {
		if (mov == pageKoma) {
			pageLeft(1,0,false);
		} else {
			scrollUp(false);
		}
	}
	resetUndoList();
	resetRedoList();
}

function komaShift(num:Number, startKoma:Number)
{
	// ページ内のコマを上シフト・下シフト
	var del:Number = num;
	var startFrame:Number = startKoma;
	var endFrame:Number = startKoma + pageKoma;

	delete_koma_scr(startKoma);// 一度コマを全削除
	for (var k:Number = 0; k < speedPos; k++) {
		var popStart:Number = binarySearch(startFrame, arrow_temp[k], 0, arrow_temp[k].length - 1);
		for (var l:Number = popStart; l < arrow_temp[k].length; l++) {
			if (arrow_temp[k][l] < startFrame) {
			} else if (arrow_temp[k][l] < endFrame) {
				if (arrow_temp[k][l] == startFrame && del == -1) {
					arrow_temp[k].splice(l,1);
				} else if (arrow_temp[k][l] == endFrame - 1 && del == 1) {
					arrow_temp[k].splice(l,1);
				} else {
					arrow_temp[k][l] += del;
				}
			} else {
				break;
			}
		}
	}

	for (var k:Number = speedPos; k <= boostPos; k++) {
		var popStart:Number = binarySearchSpd(startFrame, arrow_temp[k], 0, arrow_temp[k].length - 1);
		for (var l:Number = popStart; l < arrow_temp[k].length; l++) {
			if (arrow_temp[k][l].pos < startFrame) {
			} else if (arrow_temp[k][l].pos < endFrame) {
				if (arrow_temp[k][l].pos == startFrame && del == -1) {
					arrow_temp[k].splice(l,1);
				} else if (arrow_temp[k][l].pos == endFrame - 1 && del == 1) {
					arrow_temp[k].splice(l,1);
				} else {
					arrow_temp[k][l].pos += del;
				}
			} else {
				break;
			}
		}
	}
	make_koma_clear(startKoma, startKoma);
	set_interval(pagePos / barBlank / 4);
	resetUndoList();
	resetRedoList();
}

function changeViewer(typeNum:Number):Void
{
	_global.posi_type = "Type" + typeNum;
	showMC.print_label2.text = _global.posi_type;
	if(keyLabel > arrSort[typeNum].length){
		arrowWidthTmp = 0.5 + arrSort[typeNum].length;
	}else{
		arrowWidthTmp = 0.5 * spaceNum + keyLabel;
	}
	if(wideFlg == false && arrSort[typeNum].length > 17){
		wideFlg = true;
		nextSideBtn._visible = true;
	}else{
		wideFlg = false;
		nextSideBtn._visible = false;
		kbase._x = 0;
	}
	arrowWidth = Math.round((wideFlg ? wideWidth : stdWidth) / arrowWidthTmp);
	spaceWidth = arrowWidth * 1.5;
}

//------------------------------------------------------------
// 譜面ペーストチェック
// [引数    currentKoma: 確認対象開始位置 (コマ数基準)
//          lengthKoma : 確認対象幅 ]
// [返却値  true: 対象範囲にコマなし / false: 対象範囲にコマあり]
//------------------------------------------------------------
function pasteCheck(currentKoma:Number, lengthKoma:Number){
	
	var minVal:Number = currentKoma;
	var maxVal:Number = currentKoma + lengthKoma;
	var checkMaxVal:Number = currentKoma + lengthKoma;
	
	for(var j:Number = 0; j < speedPos; j++){
		if(!isNaN(parseFloat(arrow_temp[j][0]))){
			checkMaxVal = arrow_temp[j][this.binarySearch(maxVal, arrow_temp[j], 0, arrow_temp[j].length-1)];
			if(minVal <= checkMaxVal && checkMaxVal < maxVal){
				return false;
			}
		}
	}
	
	for(var j:Number = speedPos; j <= boostPos; j++){
		if(!isNaN(parseFloat(arrow_temp[j][0]))){
			checkMaxVal = arrow_temp[j][this.binarySearchSpd(maxVal, arrow_temp[j], 0, arrow_temp[j].length-1)];
			if(minVal <= checkMaxVal && checkMaxVal < maxVal){
				return false;
			}
		}
	}
	
	if(!isNaN(parseFloat(arrow_temp[rhythmPos][0]))){
		checkMaxVal = arrow_temp[rhythmPos][this.binarySearch(maxVal / 4, arrow_temp[j], 0, arrow_temp[j].length-1)];
		if(minVal <= checkMaxVal * 4 && checkMaxVal * 4 < maxVal){
			return false;
		}
	}
	
	return true;
}


//----------------------------------------------------------

// カット
function cmdCut(currentKoma:Number, startKoma:Number, lengthKoma:Number){
	
	rangeNum = lengthKoma;
	
	// ペースト活性化
	menuCm.customItems[C_PASTE].enabled = true;
	menuCm.customItems[C_PASTED].enabled = true;
	menu = menuCm;
	
	delete_koma_scr(currentKoma);
	komaCut(startKoma, lengthKoma, true, true);
	make_koma_clear(currentKoma, currentKoma);
	set_interval(pagePos/barBlank/4);
}

// コピー
function cmdCopy(currentKoma:Number, lengthKoma:Number){

	rangeNum = lengthKoma;
	
	// ペースト活性化
	menuCm.customItems[C_PASTE].enabled = true;
	menuCm.customItems[C_PASTED].enabled = true;
	menu = menuCm;
	
	komaCut(currentKoma, lengthKoma, true, false);
}


// ペースト前処理
function cmdPrePaste(currentKoma:Number, dupliFlg:Boolean){
	
	pasteDupli = dupliFlg;
	tmpCurrentKoma = currentKoma;
	tmpLengthKoma = rangeNum;
	
	if((precheckFlg && pasteCheck(tmpCurrentKoma, tmpLengthKoma)) ||
	   !precheckFlg){
		
		if(dupliFlg){
			cmdPasteD(tmpCurrentKoma, tmpLengthKoma);
		}else{
			cmdPaste(tmpCurrentKoma, tmpLengthKoma);
		}
		menuCm.customItems[C_TCUT].enabled = false;
		menuCm.customItems[C_TCOPY].enabled = false;
		menu = menuCm;
		resetUndoList();
		resetRedoList();
		
	}else{
		openConfirm();
		endMask.gotoAndPlay(2);
	}
}


// 上書きペースト
function cmdPaste(currentKoma:Number){
	
	selArray = [];
	delete_koma_scr(currentKoma);
	copyKeysTmp = copyKeys;
	komaCut(currentKoma, rangeNum, false, true);
	copyKeys = copyKeysTmp;
	komaPaste(currentKoma, tempKoma, false);
	make_koma_clear(currentKoma, currentKoma);
	set_interval(pagePos/barBlank/4);
}

// 重ねペースト
function cmdPasteD(currentKoma:Number){
	
	selArray = [];
	delete_koma_scr(currentKoma);
	komaPaste(currentKoma, tempKoma, true);
	make_koma_clear(currentKoma, currentKoma);
	set_interval(pagePos/barBlank/4);
}

// Undoデータの積み上げ
function pushUndoList(posNum:Number, lineNum:Number, actDat:String):Void{
	undoList.push({pos: posNum, line:lineNum, act:actDat});
	if(undoList.length == 1){
		sidebg.undoBtn._visible = true;
	}
}

// Undoデータの取り出し・Redoデータの積み上げ
function popUndoList():Void{
	var posObj:Object = new Object();
	posObj = undoList.pop();
	redoList.push({pos: posObj.pos, line: posObj.line, act: (posObj.act == "push" ? "pop" : "push")});
	resetKoma(posObj);
	if(undoList.length == 0){
		sidebg.undoBtn._visible = false;
	}
	if(redoList.length == 1){
		sidebg.redoBtn._visible = true;
	}
}

// Redoデータの取り出し・Undoデータの積み上げ
function popRedoList():Void{
	var posObj:Object = new Object();
	posObj = redoList.pop();
	undoList.push({pos: posObj.pos, line: posObj.line, act: (posObj.act == "push" ? "pop" : "push")});
	resetKoma(posObj);
	if(redoList.length == 0){
		sidebg.redoBtn._visible = false;
	}
	if(undoList.length == 1){
		sidebg.undoBtn._visible = true;
	}
}

// コマ戻し処理
function resetKoma(posObj:Object):Void{
	var startKoma:Number = pageKoma * (page - 1) + pagePos;
	var endKoma:Number = pageKoma * page + pagePos;
	var pos:Number = (posObj.pos >= keyLabel ? posObj.pos - keyLabel : posObj.pos);
	var line:Number = posObj.line;
	var posz:String = zeroPadding(pos, 2, "0");
	
	// 表示外のコマ戻しを行う場合は一旦ページ移動
	if(posObj.line < startKoma || posObj.line >= endKoma){
		delete_koma_scr(startKoma);
		var beforeStartKoma:Number = startKoma;
		page = Math.floor(posObj.line / pageKoma) + 1;
		pagePos = 0;
		if (page >= pageMax) {
			page = pageMax;
			pageBtnUnabled("next");
			pageBtnEnabled("prev");
		} else if (page == 1) {
			pageBtnUnabled("prev");
			pageBtnEnabled("next");
		} else {
			pageBtnEnabled("prev");
			pageBtnEnabled("next");
		}
		make_koma_clear(pageKoma * (page - 1), beforeStartKoma);
		set_interval(0);
	}
	
	switch(posObj.act){
		case "push":
			// pop
			if(posObj.pos < speedPos){
				if(posObj.pos < keyLabel){
					arrow_temp[pos] = popArrowR(arrow_temp[pos], line);
				}else{
					arrow_temp[posObj.pos] = popArrowR(arrow_temp[posObj.pos], line);
				}
				kbase["arrMC_" + posz + "_" + line].gotoAndStop(1);
				
			}else{
				if(posObj.pos == speedPos){
					popArrowSpd(speedPos, line);
				}else if(posObj.pos == boostPos){
					popArrowSpd(boostPos, line);
				}
				kbase["arrMC_" + speedVal + "_" + line].gotoAndStop(1);
			}
			
		break;
		case "pop":
			// push
			if(posObj.pos < speedPos){
				if(posObj.pos < keyLabel){
					arrow_temp[pos] = pushArrowR(arrow_temp[pos], [line]);
					kbase["arrMC_" + posz + "_" + line].gotoAndStop(2);
				}else{
					arrow_temp[posObj.pos] = pushArrowR(arrow_temp[posObj.pos], [line]);
					kbase["arrMC_" + posz + "_" + line].gotoAndStop(3);
				}
				
			}else{
				if(posObj.pos == speedPos){
					pushArrowSpd(speedPos, [line], [1]);
					kbase["arrMC_" + speedVal + "_" + line].gotoAndStop(2);
				}else{
					pushArrowSpd(boostPos, [line], [1]);
					kbase["arrMC_" + speedVal + "_" + line].gotoAndStop(3);
				}
			}
		break;
	}
}

function resetUndoList():Void{
	undoList = [];
	sidebg.undoBtn._visible = false;
}

function resetRedoList():Void{
	redoList = [];
	sidebg.redoBtn._visible = false;
}

//------------------------------------------------------------
// パディング処理
// [引数
//          val : 対象数値, len : 文字長, conv : パディング文字]
// [返却値パディング後文字列]
//------------------------------------------------------------
function zeroPadding(val:Number, len:Number, conv:String):String
{
	var str:String = val.toString();
	while (str.length < len)
	{
		str = conv + str;
	}
	return str;
}

