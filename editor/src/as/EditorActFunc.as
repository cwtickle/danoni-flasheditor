//------------------------------------------------------------
//
//  Dancing☆Onigiriエディター
//  ボタン・右クリックアクション
//
//------------------------------------------------------------

mTCut = new ContextMenuItem();
mTCut.caption = "カット[範囲指定](Z+X)";
mTCut.enabled = false;
mTCut.separatorBefore = false;
mTCut.visible = true;
mTCut.onSelect = function(){
	
	var currentKoma:Number = _root.pageKoma * (_root.page -1) + _root.pagePos;
	var cutStartKoma:Number = _root.selArray[0] * _root.pageKoma;
	var lengthKoma:Number = (_root.selArray[1]-_root.selArray[0]) * _root.pageKoma;
	
	// カット実行
	_root.cmdCut(currentKoma, cutStartKoma, lengthKoma);
};

mTCopy = mTCut.copy();
mTCopy.caption = "コピー[範囲指定](Z+C)";
mTCopy.enabled = false;
mTCopy.onSelect = function(){
	
	var cutStartKoma:Number = _root.selArray[0] * _root.pageKoma;
	var lengthKoma:Number = (_root.selArray[1]-_root.selArray[0]) * _root.pageKoma;
	
	// コピー実行
	_root.cmdCopy(cutStartKoma, lengthKoma);
};

mCut = new ContextMenuItem();
mCut.caption = "カット[ページ](X)";
mCut.enabled = true;
mCut.separatorBefore = false;
mCut.visible = true;
mCut.onSelect = function(){
	
	var currentKoma:Number = _root.pageKoma * (_root.page -1) + _root.pagePos;
	var lengthKoma:Number = _root.pageKoma;

	// カット実行
	_root.cmdCut(currentKoma, currentKoma, lengthKoma);
};

mCopy = mCut.copy();
mCopy.caption = "コピー[ページ](C)";
mCopy.enabled = true;
mCopy.separatorBefore = false;
mCopy.onSelect = function(){
	
	var currentKoma:Number = _root.pageKoma * (_root.page -1) + _root.pagePos;
	var lengthKoma:Number = _root.pageKoma;
	
	// コピー実行
	_root.cmdCopy(currentKoma, lengthKoma);
};

mPaste = mCut.copy();
mPaste.caption = "上書きペースト(V)";
mPaste.enabled = false;
mPaste.separatorBefore = true;
mPaste.onSelect = function(){
	
	var currentKoma:Number = _root.pageKoma * (_root.page -1) + _root.pagePos;
	
	_root.cmdPrePaste(currentKoma, false);
	
};

mPasteD = mCut.copy();
mPasteD.caption = "重ねペースト(B)";
mPasteD.enabled = false;
mPasteD.separatorBefore = false;
mPasteD.onSelect = function(){
	
	var currentKoma:Number = _root.pageKoma * (_root.page -1) + _root.pagePos;
	
	_root.cmdPrePaste(currentKoma, true);
	
};

mPageDown = mCut.copy();
mPageDown.caption = "押し下げ[ページ](L)";
mPageDown.enabled = true;
mPageDown.separatorBefore = true;
mPageDown.onSelect = function(){
	var currentKoma:Number = _root.pageKoma * (_root.page -1) + _root.pagePos;
	var lengthKoma:Number = _root.pageKoma;
	
	_root.pageShift(1,currentKoma,lengthKoma);
};

mPageUp = mCut.copy();
mPageUp.caption = "押し上げ[ページ](O)";
mPageUp.enabled = true;
mPageUp.separatorBefore = false;
mPageUp.onSelect = function(){
	var currentKoma:Number = _root.pageKoma * (_root.page -1) + _root.pagePos;
	var lengthKoma:Number = _root.pageKoma;
	
	if(currentKoma > lengthKoma){
		_root.pageShift(-1,currentKoma,lengthKoma);
	}
};

var menuArray = [mCut, mTCut, mCopy, mTCopy, mPaste, mPasteD, mPageDown, mPageUp];
menuCm.customItems = menuArray;
_root.menu = menuCm;

function itemUnabled()
{
	kbase._visible = false;
	kfix._visible = false;
	prevScrBtn._visible = false;
	nextScrBtn._visible = false;
	sidebg._visible = false;
	
	var menuArray = [];
	menuCm.customItems = menuArray;
	_root.menu = menuCm;
}
function itemEnabled()
{
	kbase._visible = true;
	kfix._visible = true;
	prevScrBtn._visible = true;
	nextScrBtn._visible = true;
	sidebg._visible = true;
	
	var menuArray = [mCut, mTCut, mCopy, mTCopy, mPaste, mPasteD, mPageDown, mPageUp];
	menuCm.customItems = menuArray;
	_root.menu = menuCm;
}

// マウスホイールの設定
waitCnt = 0;
mouseObj = new Object();
mouseObj.onMouseWheel = function(val, scrollTarget)
{
	if (_root.lockFlg == false) {
		_root.waitCnt = (_root.waitCnt >= _root.dragAttempt ? 0 : ++_root.waitCnt);
		if(_root.waitCnt == 0){
			if (val > 0) {
				_root.scrollUp(true);
			} else {
				_root.scrollDown(true);
			}
		}
	}
};
Mouse.addListener(mouseObj);
function unabledPageBtn()
{
	if (page == 1 && pagePos == 0) {
		this.pageBtnUnabled("prev");
	} else if (page == pageMax) {
		this.pageBtnUnabled("next");
	}
}

// 各種閉じるボタン
function openConfirm()
{
	endMask._visible = true;
	itemUnabled();
	opt._visible = false;
	menuBar._visible = false;
	lockFlg = true;
}
function closeConfirm()
{
	endMask._visible = false;
	itemEnabled();
	unabledPageBtn();
	menuBar._visible = true;
	lockFlg = false;
}

function headerSave(){
	if(opt._currentframe == 1){
		tuning = opt.tuningName.text;
		headerInfo = opt.headerInfoData.text;
		footerInfo = opt.footerInfoData.text;
	}
}

// オプションボタン
function openOpt()
{
	opt._visible = true;
	for(var j = 0; j < keyLabel; j++){
		opt["test" + j].removeMovieClip();
	}
	opt.keyCol1.removeMovieClip();
	opt.keyCol2.removeMovieClip();
	
	opt.gotoAndPlay("option1");
	itemUnabled();
	lockFlg = true;
}
function closeOpt()
{
	itemEnabled();
	opt._visible = false;
	for(var j = 0; j < keyLabel; j++){
		opt["test" + j].removeMovieClip();
	}
	opt.keyCol1.removeMovieClip();
	opt.keyCol2.removeMovieClip();
	headerSave();
	unabledPageBtn();
	lockFlg = false;
}

// ショートカットボタン
function openShort()
{
	opt._visible = true;
	for(var j = 0; j < keyLabel; j++){
		opt["test" + j].removeMovieClip();
	}
	opt.keyCol1.removeMovieClip();
	opt.keyCol2.removeMovieClip();
	
	headerSave();
	opt.gotoAndStop("shortcut");
	itemUnabled();
	lockFlg = true;
}
function closeShort()
{
	itemEnabled();
	opt._visible = false;
	unabledPageBtn();
	lockFlg = false;
}

// 矢印数カウントボタン
function openArrCnt()
{
	opt._visible = true;
	headerSave();
	opt.gotoAndStop("arrcnt");
	itemUnabled();
	lockFlg = true;

	opt.arrowC.text = "";
	opt.arrowC2.text = "";
	opt.fArrowC.text = "";
	opt.fArrowC2.text = "";
	opt.spdC.text = "";
	var sumA:Number = 0;
	var sumF:Number = 0;
	var header:String = "";
	var objX:Number = 45;
	var objY:Number = 12;
	if(keyLabel <= 17){
		objX = 100;
		opt.arrowC._x = 125;
		opt.fArrowC._x = 179;
	}
	
	for (var j = 0; j < keyLabel; j++) {
		if(keyLabel > 17 && j == Math.round(keyLabel / 2)){
			header = "2";
			objX = 165;
			objY = 30;
		} else {
			objY += 18;
		}
		var num:Number = (j < 9 ? "0" + (j + 1) : (j + 1));
		opt["arrowC" + header].text += num + ") " + arrow_temp[j].length + "\r";
		opt["fArrowC" + header].text += "+" + arrow_temp[j + keyLabel].length / 2 + "\r";
		sumA += arrow_temp[j].length;
		sumF += arrow_temp[j + keyLabel].length / 2;
		
		var arrowName:String = arrBaseMC[cp];
		opt.attachMovie(arrBaseMC[j],"test" + j,j);
		opt["test" + j]._x = objX;
		opt["test" + j]._y = objY;
	}
	opt.spdC.text += "合計 :" + sumA + "+" + sumF + "=" + (sumA + sumF);
	opt.spdC.text += " / 全体加速 :" + arrow_temp[speedPos].length + " / 個別加速 :" + arrow_temp[boostPos].length;

}

// 矢印スワップ用コンボボックス作成
function addSwapCombo(){
	
	opt.createClassObject(mx.controls.ComboBox, "keyCol1", 1000);
	opt.keyCol1.move(10,375);
	opt.createClassObject(mx.controls.ComboBox, "keyCol2", 1001);
	opt.keyCol2.move(140,375);
	
	for (var j = 0; j < keyLabel; j++) {
		var num:Number = (j < 9 ? "0" + (j + 1) : (j + 1));
		opt.keyCol1.addItem({data: j, label: num + ":" + headerDat[1][j]});
		opt.keyCol2.addItem({data: j, label: num + ":" + headerDat[1][j]});
	}
	
	col1Idx = 0;
	col2Idx = 0;

	var cbListener1:Object = new Object();
	cbListener1.change = function (col1Obj:Object){
		_root.col1Idx = col1Obj.target.selectedIndex;
	}

	var cbListener2:Object = new Object();
	cbListener2.change = function (col2Obj:Object){
		_root.col2Idx = col2Obj.target.selectedIndex;
	}
	
	opt.keyCol1.addEventListener("change",cbListener1);
	opt.keyCol2.addEventListener("change",cbListener2);
}


function closeArrCnt()
{
	itemEnabled();
	opt._visible = false;
	for(var j = 0; j < keyLabel; j++){
		opt["test" + j].removeMovieClip();
	}
	opt.keyCol1.removeMovieClip();
	opt.keyCol2.removeMovieClip();
	unabledPageBtn();
	lockFlg = false;
}

// 画面を閉じずに一部オブジェクトを削除
function nonCloseArrCnt()
{
	for(var j = 0; j < keyLabel; j++){
		opt["test" + j].removeMovieClip();
	}
}


// 譜面プレビュー  未実装
function openScoreDat()
{
	opt._visible = true;
	for(var j = 0; j < keyLabel; j++){
		opt["test" + j].removeMovieClip();
	}
	opt.keyCol1.removeMovieClip();
	opt.keyCol2.removeMovieClip();
	
	opt.gotoAndStop("printOut");
	itemUnabled();
	lockFlg = true;
}
function closeScoreDat()
{
	itemEnabled();
	opt._visible = false;
	for(var j = 0; j < keyLabel; j++){
		opt["test" + j].removeMovieClip();
	}
	unabledPageBtn();
	lockFlg = false;
}

function switchScore(scoreCur:Number){
	
	scoreChFlg = true;
	delete_koma(pageKoma * (page - 1) + pagePos);
	_root["keysTmp" + scoreNum] = keysTmp;
	_root["arrow_temp" + scoreNum] = arrow_temp.concat();
	_root["haba_array" + scoreNum] = haba_array.concat();
	_root["lblArray" + scoreNum] = lblArray.concat();
	_root["headerInfo" + scoreNum] = headerInfo;
	_root["footerInfo" + scoreNum] = footerInfo;
	_root["tune_num" + scoreNum] = tune_num;
	_root["barBlank" + scoreNum] = barBlank;
	_root["undoList" + scoreNum] = undoList.concat();
	_root["redoList" + scoreNum] = redoList.concat();
	
	if(_root["arrow_temp" + scoreCur] != undefined){
		
		keysTmp = _root["keysTmp" + scoreCur];
		setKeys(keysTmp, loadMC, true);
		for(var j = 0; j < timelineNum; j++){
			deleteLines();
			kfix["timeline" + j].removeTextField();
			delete kfix["timeline" + j];
			kfix["barLineR" + j]._y = -20;
			kfix["barLineL" + j]._y = -20;
			kfix["barLineT" + j]._y = -20;
		}
		
		arrow_temp = _root["arrow_temp" + scoreCur].concat();
		haba_array = _root["haba_array" + scoreCur].concat();
		lblArray = _root["lblArray" + scoreCur].concat();
		headerInfo = _root["headerInfo" + scoreCur];
		footerInfo = _root["footerInfo" + scoreCur];
		tune_num = _root["tune_num" + scoreCur];
		barBlank = _root["barBlank" + scoreCur];
		undoList = _root["undoList" + scoreCur].concat();
		redoList = _root["redoList" + scoreCur].concat();
		beatNum = (barBlank == 2 ? 4 : barBlank);
		lineBlank = (barBlank == 2 ? 4 : barBlank);
		measure = Math.floor(maxPageKoma / beatNum / 4) * beatNum;
		timelineNum = measure / barBlank;
		pageKoma = 4 * measure;
		
		drawLines(pagePos);
		sidebg.undoBtn._visible = (undoList.length > 0 ? true : false);
		sidebg.redoBtn._visible = (redoList.length > 0 ? true : false);
		
		opt.headerInfoData.text = headerInfo;
		opt.footerInfoData.text = footerInfo;
		
	}else{
		
		arrow_temp = new Array();
		for (var a:Number = 0; a <= rhythmPos; a++) {
			arrow_temp[a] = new Array();
		}
		// 初期値設定
		haba_array = new Array();
		haba_array[0] = {num:0, header:200, blank:10};
		lblArray = [0];
		headerInfo = "";
		footerInfo = "";
		tune_num = 1;
		resetUndoList();
		resetRedoList();
	}
}


// 譜面作成実行
function execGo():Void{
	delete_koma_scr(pageKoma * (page - 1) + pagePos);
	var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
	headerSave();

	timeline = new Array();
	for (var a = 0; a <= rhythmPos; a++) {
		timeline[a] = new Array();
	}
	tune_name = _root.tune_num;

	// 変数表記
	if (tune_num == "1") {
		tune_name = "";
	}
	// 拍子セーブ部分編集 
	rhy_temp = [];// バースト部分をまとめた3連符データ
	rhythm_save = [];// セーブ用3連符データ
	if (!isNaN(parseFloat(arrow_temp[rhythmPos][0]))) {
		set_rhythm(arrow_temp[rhythmPos]);
	}

	for (var a = 0; a < speedPos; a++) {
		if (!isNaN(parseFloat(arrow_temp[a][0]))) {
			mergeFlg = false;
			mergeMax = 0;
			mergeMin = 0;

			//  ３/４拍子の振り分け処理
			push_timeline(a,arrow_temp[a],rhy_temp);

			if (haba_array.length > 1 && mergeFlg == true) {

				for (var j = mergeVal; j > 0; j--) {
					if (timeline[a][j] < timeline[a][mergeVal]) {
						mergeMin = j;
						break;
					}
				}

				var aftData:Array = [];
				if (mergeMax + 1 < timeline[a].length) {
					aftData = timeline[a].splice(mergeMax + 1);
				}
				var mergeData:Array = timeline[a].splice(mergeMin);

				// 重複排除、ソート
				mergeData = deleteDuplication(mergeData);
				quickSort(mergeData);

				timeline[a] = timeline[a].concat(mergeData, aftData);
			}
		}
	}
	for (var a = speedPos; a <= boostPos; a++) {

		if (!isNaN(parseFloat(arrow_temp[a][0].pos))) {
			mergeFlg = false;
			mergeMax = 0;
			mergeMin = 0;

			//  ３/４拍子の振り分け処理
			push_timeline_spd(a,arrow_temp[a],rhy_temp);

			if (haba_array.length > 1 && mergeFlg == true) {

				for (var j = mergeVal; j > 0; j--) {
					if (timeline[a][j].pos < timeline[a][mergeVal].pos) {
						mergeMin = j;
						break;
					}
				}

				var aftData:Array = [];
				if (_root.mergeMax + 1 < timeline[a].length) {
					aftData = timeline[a].splice(_root.mergeMax + 1);
				}
				var mergeData:Array = timeline[a].splice(_root.mergeMin);

				// 重複排除、ソート
				mergeData = deleteDuplicationSpd(mergeData);
				mergeData.sortOn("pos",16);

				timeline[a] = timeline[a].concat(mergeData, aftData);
			}
		}
	}

	show_num = "";
	show_num = str_replace("NaN,", "", print_out());
	System.setClipboard(show_num);
	
	// セーブデータ
	saveEditor(true);

	delete timeline;

	pagePos = 0;
	make_koma_clear(pageKoma * (page - 1), beforeStartKoma);
	set_interval(0);
}

// セーブ実行
function execSave():Void{
	headerSave();
	saveEditor(false);
	System.setClipboard(_root.show_save_num);
}

function execSaveD():Void{
	saveEditor(false);
	openConfirm();
	endMask.gotoAndPlay("sav");
}

// オプション表示実行
function execOpt():Void{
	if(opt._visible == false || opt._currentframe != 2){
		openOpt();
	}else{
		if(opt._currentframe == 2){
			_root.tuning = opt.tuningName.text;
			_root.headerInfo = opt.headerInfoData.text;
			_root.footerInfo = opt.footerInfoData.text;
		}
		closeOpt();
	}
}

// ショートカット表示実行
function execShort():Void{
	if(opt._visible == false || opt._currentframe != 3){
		if(opt._currentframe == 2){
			_root.tuning = opt.tuningName.text;
			_root.headerInfo = opt.headerInfoData.text;
			_root.footerInfo = opt.footerInfoData.text;
		}
		openShort();
	}else{
		closeShort();
	}
}

// 矢印カウント表示実行
function execArrCnt():Void{
	if(opt._visible == false || opt._currentframe != 4){
		if(opt._currentframe == 2){
			_root.tuning = opt.tuningName.text;
			_root.headerInfo = opt.headerInfoData.text;
			_root.footerInfo = opt.footerInfoData.text;
		}
		openArrCnt();
		addSwapCombo();
	}else{
		closeArrCnt();
	}
}

// 矢印スワップ実行
function execSwapArrow(col1:Number, col2:Number):Void{

	var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
	delete_koma_scr(beforeStartKoma);

	var swapArr = new Array();
	var swapFArr = new Array();
	
	swapArr = arrow_temp[col1];
	arrow_temp[col1] = arrow_temp[col2];
	arrow_temp[col2] = swapArr;
	
	swapArr = arrow_temp[keyLabel + col1];
	arrow_temp[keyLabel + col1] = arrow_temp[keyLabel + col2];
	arrow_temp[keyLabel + col2] = swapArr;
	
	make_koma_clear(beforeStartKoma, beforeStartKoma);
}

// ページジャンプ実行
function execJump():Void{
	delete_koma_scr(pageKoma * (page - 1) + pagePos);
	var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
	page = Math.round(jump_num != undefined ? jump_num : 1);

	pageBtnEnabled("next");
	pageBtnEnabled("prev");

	if (page >= pageMax) {
		page = pageMax;
		pageBtnUnabled("next");
	} else if (page <= 1) {
		page = 1;
		pageBtnUnabled("prev");
	}
	pagePos = 0;
	make_koma_clear(pageKoma * (page - 1), beforeStartKoma);
	set_interval(0);
}

// 5ページ戻る
function execPrev5():Void{
	var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
	pageLeft(5,0,true);
	pagePos = 0;
	drawLines(0);
	make_koma_clear(pageKoma * (page - 1), beforeStartKoma);
	set_interval(0);
}

// 1ページ戻る
function execPrev():Void{
	var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
	pageLeft(1,0,true);
	pagePos = 0;
	drawLines(0);
	make_koma_clear(pageKoma * (page - 1), beforeStartKoma);
	set_interval(0);
}

// 1ページ進む
function execNext():Void{
	var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
	pageRight(1,0,true);
	pagePos = 0;
	drawLines(0);
	make_koma_clear(pageKoma * (page - 1), beforeStartKoma);
	set_interval(0);
}

// 5ページ進む
function execNext5():Void{
	var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
	pageRight(5,0,true);
	pagePos = 0;
	drawLines(0);
	make_koma_clear(pageKoma * (page - 1), beforeStartKoma);
	set_interval(0);
}

// 3連符・4拍子変換
function execChange():Void{
	var rhyKoma:Number = pageKoma / 4;
	var rhy:Number = (page - 1) * rhyKoma + pagePos / 4;
	plTmp = keyLabel + 1;
	plMax = (plTmp < 10 ? "0" + plTmp : plTmp);

	if (rhythm_ch == false) {
		rhythm_ch = true;

		for (var i = 0; i < rhyKoma; i++) {
			var rhys:Number = rhy + i;
			var judge4:Number = 4 * rhys + 3;
			if (kbase["arrMC_00_" + judge4]._visible != false) {
				pushArrow(_root.rhythmPos,[rhys]);
				kbase["arrMC_" + _root.rhythmVal + "_" + rhys].gotoAndStop(2);
				arrow_temp = changeKomaSizeR(rhys, arrow_temp);
			}
		}
	} else {
		rhythm_ch = false;

		for (var i = 0; i < rhyKoma; i++) {
			var rhys:Number = rhy + i;
			var judge4:Number = 4 * rhys + 3;
			if (kbase["arrMC_00_" + judge4]._visible != true) {
				popArrow(rhythmPos,rhys);
				kbase["arrMC_" + rhythmVal + "_" + rhys].gotoAndStop(1);
				resetKomaSize(rhys);
			}
		}
	}
}

// Interval調整
function execIntMinus():Void{
	var startFixCnt:Number = haba_array.length - 1;
	var diff:Number = 0;
	var targetPos:Number = page + pagePos / pageKoma;
	var basePos:Number = targetPos - 1;
	var bpmChFlg:Boolean = false;
	while (startFixCnt >= 0)
	{
		if (targetPos > haba_array[startFixCnt].num) {
			diff = targetPos - haba_array[startFixCnt].num;
			if(basePos < haba_array[startFixCnt].num) {
				bpmChFlg = true;
			}
			break;
		}
		startFixCnt--;
	}
	var chBlank:Number = Math.round((2 / diff / pageKoma) * 100000
						* (Key.isDown(16) ? 0.25 : 1))/100000;
	
	if(bpmChFlg){
		haba_array[startFixCnt].blank -= chBlank;
	}else{
		haba4_num -= chBlank;
	}
}

// Interval調整
function execIntPlus():Void{
	var startFixCnt:Number = haba_array.length - 1;
	var diff:Number = 0;
	var targetPos:Number = page + pagePos / pageKoma;
	var basePos:Number = targetPos - 1;
	var bpmChFlg:Boolean = false;
	
	// 速度変化位置に最も近い場所を検索
	while (startFixCnt >= 0)
	{
		if (targetPos > haba_array[startFixCnt].num) {
			diff = targetPos - haba_array[startFixCnt].num;
			
			// 1ページ以内に速度変化していないかチェック
			if(basePos < haba_array[startFixCnt].num) {
				bpmChFlg = true;
			}
			break;
		}
		startFixCnt--;
	}
	var chBlank:Number = Math.round((2 / diff / pageKoma) * 100000
						* (Key.isDown(16) ? 0.25 : 1))/100000;
	
	// 1ページ以内に速度変化している場合：対象のIntervalデータを書き換え
	if(bpmChFlg){
		haba_array[startFixCnt].blank += chBlank;

	// 1ページ以上速度変化していない場合：Intervalデータに代入(delete_komaでデータ反映)
	}else{
		haba4_num += chBlank;
	}
}

// 4分譜面作成
function execMake4():Void{
	tune_name = "";
	var beforeStartKoma:Number = pageKoma * (page - 1) + pagePos;
	delete_koma_scr(beforeStartKoma);
	headerSave();
	
	var temp4_data:Array = new Array();
	for(var j = 0; j <= rhythmPos; j++){
		temp4_data[j] = new Array();
	}
	var temp4PtnS:String = _root.temp4Ptn;
	var temp4PtnList:Array = temp4PtnS.split(",");
	
	if(isNaN(parseFloat(temp4PtnList[0]))){
		temp4PtnList[0] = 0;
		listNum = 1;
	}else{
		for(var j = 0; j < temp4PtnList.length; j++){
			if(temp4PtnList[j] > 0 && temp4PtnList[j] <= keyLabel){
				temp4PtnList[j] = parseInt(temp4PtnList[j])-1;
			}else{
				temp4PtnList[j] = -1;
			}
		}
	}
	
	// 途中から4分譜面を作成するかどうかで分岐
	if(temp4LastFlg == true){
		
		// ラベル位置検索
		var currentPageN:Number = (page - 1) * timelineNum + pagePos / barBlank / 4;
		var startLblCnt:Number = lblArray.length - 1;
		var startLblPos:Number = 0;
		while (startLblCnt >= 0)
		{
			startLblPos = Math.round(lblArray[startLblCnt] * timelineNum);
			if (Math.round(currentPageN - startLblPos) >= 0) {
				break;
			}
			startLblCnt--;
		}
		var startNum:Number = Math.round(lblArray[startLblCnt] * pageKoma);
	
	}else{
		var startNum:Number = 0;
	}
	
	if(isNaN(parseFloat(page4Num))){
		page4Num = 20;
	}else{
		page4Num = parseFloat(_root.page4Num);
		if(page4Num >= 500)	page4Num = 500;
	}
	for(var j = 0; j < 0 + _root.measure * page4Num; j+=temp4PtnList.length){
		for(var k = 0; k < temp4PtnList.length; k++){
			if(temp4PtnList[j] == -1){
				continue;
			}
			temp4_data[temp4PtnList[k]].push((j + k) * 4);
		}
	}
	
	// 4分譜面上書きする場合の処理 (すべて上書きではなく、指定ページ以降の譜面は残る)
	if(temp4UpdFlg == true){
		_root.komaCut(startNum, pageKoma * page4Num, false, true);
		_root.komaPaste(startNum, temp4_data, false);
	}
	
	timeline = new Array();
	for(var a =0; a <= rhythmPos; a++){
		timeline[a] = new Array();
	}
	for(var a = 0; a < speedPos; a++){
		if(!isNaN(parseFloat(temp4_data[a][0]))){
			
			//  ３/４拍子の振り分け処理
			push_timeline(a, temp4_data[a], []);
		}
	}
	show_num = str_replace("NaN,", "", print_out());
	System.setClipboard(show_num);
	
	delete timeline;
	
	pagePos = 0;
	make_koma_clear(pageKoma * (page-1), beforeStartKoma);
	set_interval(0);
}
