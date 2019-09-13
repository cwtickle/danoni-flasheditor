//------------------------------------------------------------
//
//  Dancing☆Onigiriエディター
//  データロード関数
//
//------------------------------------------------------------

// テキスト優先フラグ(初期はショートカット優先)
textLoadFlg = false;

//
// ショートカット
btnListener = new Object();
btnListener.onKeyDown = function(){
	switch(Key.getCode()){
		case Key.ENTER :
			if(!Key.isDown(_root.KEY_SLASH) && _root.textLoadFlg == false){
				Selection.setFocus(null);
				_root.loadBtn();
				Key.removeListener(this);
			}
			break;
			
		case Key.SPACE :
			if(!Key.isDown(_root.KEY_SLASH) && !Key.isDown(_root.KEY_SHIFT) && _root.textLoadFlg == false){
				Selection.setFocus(null);
				mySharedObject = SharedObject.getLocal("localdata");
				load_num = mySharedObject.data.message;
			}
			break;
		
		case Key.ESCAPE :
			gotoAndPlay("title");
			Key.removeListener(this);
			break;
	}
}
Key.addListener(btnListener);

// タイトルへ戻るボタン
prevBtn.onRelease = function() {
	if(scoreChFlg == true){
		gotoAndPlay("pageStart");
		_root.make_koma(_root.pageKoma * (_root.page - 1) + _root.pagePos);
		_root.set_interval(_root.pagePos / _root.barBlank / 4);
	}else{
		gotoAndPlay("title");
	}
}

// キー変更ボタン
keyChBtn.onRelease = function() {
	if(inswfFlg == false){
		listNum = (listNum < keyListArray.length-1 ? ++listNum : 0);
		keys.text = keyListArray[listNum];
		setKeys(keys.text, loadMC);
	}
}

// Revivalボタン
lRevivalBtn.onRelease = function() {
	mySharedObject = SharedObject.getLocal("localdata");
	_root.load_num = mySharedObject.data.message;
}

// Loadボタン
lLoadBtn.onRelease = function() {
	loadBtn();
	Key.removeListener(btnListener);
}

// sm難易度変更ボタン
smDifBtn.onRelease = function(){
	switch(_global.dif_check){
		case "Beginner":
			_global.dif_check = "Easy";       break;
		case "Easy":
			_global.dif_check = "Medium";   break;
		case "Medium":
			_global.dif_check = "Hard";      break;
		case "Hard":
			_global.dif_check = "Beginner"; break;
	}
	_root.dif_label.text = _global.dif_check;
}

// ヘッダー・フッター部分読込対象(デフォルト)
headerList = ["musicTitle", "difData", "difStep", "difName", "speedlock", "setColor", "frzColor", "startFrame", "headerUrl", "editorUrl"];
footerList = ["color", "acolor", "word"];
HEADER_NUM = 7;		// headerListのうちOption Editor2で設定できる数

// ヘッダー・フッター部分カスタマイズ
if (loadMC.headerVal == undefined) {
} else {
	var headerValArr:Array = loadMC.headerVal.split(",");
	for (var j = 0; j < headerValArr.length; j++) {
		if (headerValArr[j] != "") {
			headerList.push(headerValArr[j]);
		}
	}
}
if (loadMC.footerVal == undefined) {
} else {
	var footerValArr:Array = loadMC.footerVal.split(",");
	for (var j = 0; j < footerValArr.length; j++) {
		if (footerValArr[j] != "") {
			footerList.push(footerValArr[j]);
		}
	}
}


// 難易度ラベル
// Easy : １譜面目、Medium : ２譜面目、Hard : ３譜面目、Beginner : ４譜面目
_global.dif_check = "Easy";

allSpdFlg = false;

//------------------------------------------------------------
// ステップマニアデータ読込
// 　　separeterは通常改行コード。
//　　 ファイル読込かテキスト貼り付けにより改行コードが異なる
// [引数
//           val       : 読込データ
//           separater : 区切り文字]
// [返却値なし]
//------------------------------------------------------------
function read_sm(val:String, separeter:String)
{
	sm = val.split(separeter);
	sm.pop();
	//データ解析
	//
	//曲名、ジャンル、アーティスト
	title = sm[0].substring(7, sm[0].length - 1);
	genre = sm[1].substring(10, sm[1].length - 1);
	artist = sm[2].substring(8, sm[2].length - 1);

	//
	speed = sm[16].split(",");
	speed.shift();
	for (i = 0; i < speed.length; i++) {
		speed[i] = parseInt(speed[i]);
	}
	//
	//難易度抽出
	var def = 0;
	var load_comp = false;
	var note_start = 0;
	for (i = 0; i < sm.length; i++) {
		if ("#NOTES:" == sm[i]) {
			if ("     " + _global.dif_check + ":" == sm[i + 3]) {
				def = sm[i + 4].substr(5, 1);
				note_start = i + 6;
				load_comp = true;
			}
		}
		if (load_comp == true) {
			break;
		}
	}
	//
	//
	//譜面抽出、最大値計算
	note = [];
	max_value = 0;
	var k = -1;
	for (var j = note_start; sm[j] != ";"; j++) {
		note.push(sm[j]);
		k++;
		if (sm[j].charAt(0) == ',') {
			if (max_value < k) {
				max_value = k;
			}
			k = -1;
		}
	}
	if (max_value < 16) {
		max_value = 16;

	}
	// 
	//BPM＆BPM変化
	sm[16] = sm[16].slice(6, -1);
	bpm = sm[16].split(",");
	bpmPage = new Array();
	bpmData = new Array();
	var minBpm:Number = Infinity;
	var maxBpm:Number = 0;
	for (var i = 0; i < bpm.length; i++) {
		var bpmTmp:Array = bpm[i].split("=");
		var chkPage:Number = parseFloat(bpmTmp[0]) / (16 / max_value);

		//if(chkPage == Math.round(chkPage)){
		bpmPage[i] = parseFloat(bpmTmp[0]) / (4 * 64 / max_value);
		bpmData[i] = parseFloat(bpmTmp[1]);
		if (bpmData[i] < minBpm) {
			minBpm = bpmData[i];
		}
		if (bpmData[i] > maxBpm) {
			maxBpm = bpmData[i];
		}
		//} 
	}
	if (minBpm == maxBpm) {
		bpms = minBpm;
	} else {
		bpms = minBpm + "-" + maxBpm;
	}
	//
	//
	//譜面コンバート
	note = smTOdos(note);
	//
	//
	//出力
	error_msg = title + "," + genre + "," + artist + "," + bpms + "," + def + "," + "*_" + file_name + "," + "*" + ",";
	load_num = note;
	delete sm;
	directRead();
}

//------------------------------------------------------------
// ステップマニアデータ変換
// 　　Dancing☆Onigiri用のデータに変換
// [引数
//           load_num : データ]
// [返却値   変換先データ]
//------------------------------------------------------------
function smTOdos(load_num)
{
	var dos = new Array();
	//--------------------------------------
	//
	//譜面分配（１小節ごと、１行ごとに配列化）
	load_num = load_num.join("\r");
	sm = load_num.split(",");
	for (var i = 0; i < sm.length; i++) {
		sm[i] = sm[i].split("\r");
	}
	for (i = 0; i < sm.length; i++) {
		if (i != 0) {
			sm[i].shift();
		}
		if (i != sm.length - 1) {
			sm[i].pop();
		}
	}
	//--------------------------------------
	//
	//最初の空白小節を削除する
	var space_count = 0;
	var speed_load = speed.concat();

	while (true)
	{
		if (sm[0].join("").indexOf("1") == -1) {
			sm.shift();
			space_count++;
		} else {
			break;
		}
	}
	for (i = 0; i < speed_load.length; i++) {
		var bpmSpd:Number = (isNaN(bpmData[i + 1] / bpmData[0]) ? 1 : Math.round((bpmData[i + 1] / bpmData[0]) * 1000) / 1000);
		speed_load[i] = speed_load[i] * max_value / 4 - (space_count * max_value) + "=" + bpmSpd;
	}
	//--------------------------------------
	//
	//最大数に合わせ、入れ込む（譜面部以外には挿入しない）
	for (i = 0; i < sm.length; i++) {
		for (var j = 0; j < sm[i].length; j++) {
			if (!isNaN(parseFloat(sm[i][j].charAt(0)))) {
				dos.push(sm[i][j]);
				in_line = max_value / sm[i].length - 1;
				for (var k = 0; k < in_line; k++) {
					dos.push("00000000");
				}
			}
		}
	}
	//--------------------------------------
	//
	//曲開始～初めに矢印が来るまでの余白をカット
	cnt = 0;
	flg = false;
	for (i = 0; i < dos.length; i++) {
		if (!isNaN(parseFloat(dos[i].charAt(0)))) {
			chk = dos[i].substr(0, 8);
			if (chk == "00000000") {
				cnt++;
			} else {
				flg = true;
				break;
			}
		}
		if (flg == true) {
			break;
		}
	}
	//cnt = Math.floor(cnt / max_value)*max_value;
	dos.splice(0,cnt);
	//--------------------------------------
	//
	//矢印データ用配列
	var key_num = _global.key_label;
	var arrow_load = new Array();
	var f_arrow_load = new Array();
	for (j = 0; j < key_num; j++) {
		arrow_load[j] = new Array();
		f_arrow_load[j] = new Array();
	}

	//
	//配列から"１"のつくものだけを抽出、出力
	//フリーズアロー開始は"２", 終了は"３"となっている
	for (i = 0; i < dos.length; i++) {
		for (j = 0; j < key_num; j++) {
			if (dos[i].charAt(j) == "1") {
				arrow_load[j].push(i);
			} else if (dos[i].charAt(j) == "2" || dos[i].charAt(j) == "3") {
				f_arrow_load[j].push(i);
			}
		}
	}
	//
	//
	//四分間隔計算
	var firstTmp:Array = new Array();
	var intervalTmp:Array = new Array();
	for (j = 0; j < bpmData.length; j++) {
		if (j == 0) {
			firstTmp[j] = 200;
		} else {
			firstTmp[j] = firstTmp[j - 1] + intervalTmp[j - 1] * (bpmPage[j] - bpmPage[j - 1]) * 32;
		}
		intervalTmp[j] = Math.round(3600 / bpmData[j] * 100) / 100 / (max_value / 8);

		if (allSpdFlg == true) {
			break;
		}
	}
	//
	load_num = "";
	//
	//矢印、フリーズアローデータ挿入
	for (j = 0; j < key_num; j++) {
		load_num += arrow_load[j] + "&";
	}
	for (j = 0; j < key_num; j++) {
		load_num += f_arrow_load[j] + "&";
	}
	//
	//first_num, ４分間隔などの詳細設定。first_numのデフォルト値は２００。
	//この部分がエディターによって異なるので必要があれば直すこと
	load_num += speed_load + "&&&" + firstTmp + "&" + intervalTmp + "&" + bpmPage + "&1&100&16&2&";

	return load_num;
}

//------------------------------------------------------------
// FUJIさんエディター(Ver1.15用)データ読込
// 　　Dancing☆Onigiri用のデータに変換
// [引数
//           flg : ファイルから読込 / テキストから直に読込]
// [返却値なし]
//------------------------------------------------------------
function read_fuji115(flg:Boolean)
{
	if (flg == true) {
		var tmpData:Array = load_num.split("\r");
	} else {
		var tmpData2:Array = load_num.split("\r\n").join("\n");
		var tmpData:Array = tmpData2.split("\n");
	}

	// 1行目：キー数
	chk = -1;
	for (j = 0; j < tmpData[0].length; j++) {
		if (tmpData[0].charAt(j) == "k") {
			chk = j;
			break;
		}
	}
	if (chk != -1) {
		if (checkKeys(tmpData[0].substring(0, chk)) == true) {
			setKeys(tmpData[0].substring(0, chk), loadMC);
		}
	}
	// 3行目：譜面番号 
	tune_num = (tmpData[2] != undefined ? parseFloat(tmpData[2]) : 1);
	if(tune_num == 0){
		tune_num = 1;
	}
	
	// 6行目：拍飛ばし(初めのデータのみ確認) 
	var tmpJump:Array = tmpData[5].split(",");
	var tmpJump2:Array = tmpJump[0].split("/");

	if (tmpJump2.length >= 2) {
		if (tmpJump2[0] == "0") {
			rhythm_val = (16 - Number(tmpJump2[1])) / 4;
			tmp4 = 2;
		} else if (tmpJump2[0] == "1") {
			rhythm_val = (32 - Number(tmpJump2[1])) / 4;
			tmp4 = 4;
		} else if (tmpJump2[0] == "2") {
			tmpJump2[1] = Number(tmpJump2[1]) + 16;
			rhythm_val = (64 - Number(tmpJump2[1])) / 4;
			tmp4 = 4;
		} else if (tmpJump2[0] == "3") {
			rhythm_val = (64 - Number(tmpJump2[1])) / 4;
			tmp4 = 4;
		}
		barBlank = rhythm_val;
	} else {
		rhythm_val = 4;
		tmp4 = 2;
		barBlank = 2;
	}
	timelineNum = Math.floor(maxPageKoma / barBlank / 4);
	measure = barBlank * timelineNum;
	pageKoma = 4 * measure;

	// 5行目：FNデータ
	var tmpHaba:Array = tmpData[4].split(",");
	var tmpHaba2:Array = tmpHaba[0].split("/");
	for (j = 0; j < tmpHaba.length - 2; j++) {
		if (tmpHaba2.length == 2) {
			haba_array[j] = {num:Math.ceil(parseInt(tmpHaba2[0]) / 4)/multiX, header:parseInt(tmpHaba2[1]), blank:25};
		} else {
			haba_array[j] = {num:Math.ceil(parseInt(tmpHaba2[0]) / 4)/multiX, header:parseInt(tmpHaba2[2]), blank:25};
		}
		tmpHaba2 = tmpHaba[j + 1].split("/");
		haba_array[j].blank = (parseInt(tmpHaba2[1])) / ((parseInt(tmpHaba2[0]) - haba_array[j].num * 4) * 4 * rhythm_val / tmp4);
	}
	head_num = haba_array[0].header;
	haba4_num = haba_array[0].blank;

	// 8行目以降の譜面データ読込(7key部分)
	j = 7;
	var barIndex:Number = 0;

	frzFlg = new Array();
	for (var k = 0; k < keyLabel; k++) {
		frzFlg[k] = false;
	}

	while (tmpData[j] != ";===以下譜面2" && tmpData[j] != undefined)
	{
		var lineData:Array = tmpData[j].split(",");
		for (var k = 0; k < lineData.length - 1; k++) {
			if (lineData[k].charAt(0) == "2") {
			} else if (lineData[k].charAt(0) == "4") {
			} else {
				var rowData = parseInt(lineData[k].substring(0, 2));
				var arr = parseInt(lineData[k].substring(2, 3));
				var afFlg = lineData[k].substring(3, 4);
				var baseData:Number = rowData + 16 * barIndex;

				if (rhythm_val == 4) {
				} else if (rhythm_val == 3) {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 16);
				} else {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 32);
				}

				// 全体加速
				if (arr == 7) {
					arrow_temp[speedPos].push({pos:baseData, spd:1});
					// 個別加速
				} else if (arr == 8) {
					arrow_temp[boostPos].push({pos:baseData, spd:1});

				} else if (afFlg == "0") {
					// フリーズアロー(終点)
					if (frzFlg[arr] == true) {
						arrow_temp[arr + keyLabel].push(baseData);
						frzFlg[arr] = false;
						// 単発矢印
					} else {
						arrow_temp[arr].push(baseData);
					}
					// フリーズアロー(始点)
				} else if (afFlg == "5") {
					arrow_temp[arr + keyLabel].push(baseData);
					frzFlg[arr] = true;
				}
			}
		}
		j++;
		barIndex++;
	}

	// 譜面データ読込(5key部分)
	j++;
	barIndex = 0;
	for (var k = 0; k < keyLabel; k++) {
		frzFlg[k] = false;
	}

	while (tmpData[j] != undefined)
	{
		lineData = tmpData[j].split(",");
		for (var k = 0; k < lineData.length - 1; k++) {
			if (lineData[k].charAt(0) == "2") {
			} else if (lineData[k].charAt(0) == "4") {
			} else {
				var rowData:Number = parseInt(lineData[k].substring(0, 2));
				var arr:Number = parseInt(lineData[k].substring(2, 3));
				var afFlg:Number = lineData[k].substring(3, 4);

				var baseData:Number = rowData + 16 * barIndex;

				// 拍子ごとにコマを詰める処理
				if (rhythm_val == 4) {
				} else if (rhythm_val == 3) {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 16);
				} else if (rhythm_val <= 8) {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 32);
				} else {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 64);
				}

				// 全体加速
				if (arr == 7) {
					arrow_temp[speedPos].push({pos:baseData, spd:1});

				// 個別加速
				} else if (arr == 8) {
					arrow_temp[boostPos].push({pos:baseData, spd:1});

				} else if (afFlg == "0") {
					// フリーズアロー(終点)
					if (frzFlg[arr] == true) {
						arrow_temp[arr + 7 + keyLabel].push(baseData);
						frzFlg[arr] = false;
					
					// 単発矢印
					} else {
						arrow_temp[arr + 7].push(baseData);
					}
				
				// フリーズアロー(始点)
				} else if (afFlg == "5") {
					arrow_temp[arr + 7 + keyLabel].push(baseData);
					frzFlg[arr] = true;
				}
			}
		}
		j++;
		barIndex++;
	}
	readyToStart();
}

//------------------------------------------------------------
// FUJIさんエディター(Ver2用)データ読込
// 　　Dancing☆Onigiri用のデータに変換
// [引数
//           flg : ファイルから読込 / テキストから直に読込]
// [返却値なし]
//------------------------------------------------------------
function read_fuji(flg:Boolean)
{
	if (flg == true) {
		var tmpData:Array = load_num.split("\r");
	} else {
		var tmpData2:Array = load_num.split("\r\n").join("\n");
		var tmpData:Array = tmpData2.split("\n");
	}

	// 1行目：キー数
	var chk:Number = -1;
	for (j = 0; j < tmpData[0].length; j++) {
		if (tmpData[0].charAt(j) == "k") {
			chk = j;
			break;
		}
	}
	if (chk != -1) {
		if (checkKeys(tmpData[0].substring(0, chk)) == true) {
			setKeys(tmpData[0].substring(0, chk), loadMC);
		}
	}
	// 2行目：譜面番号 
	tune_num = (tmpData[1] != undefined ? parseFloat(tmpData[1]) : 1);
	if(tune_num == 0){
		tune_num = 1;
	}

	// 5行目：拍飛ばし(初めのデータのみ確認)
	var tmpJump:Array = tmpData[4].split(",");
	var tmpJump2:Array = tmpJump[0].split("/");
	if (tmpJump2.length >= 2) {
		if (tmpJump2[0] == "0") {
			rhythm_val = (16 - Number(tmpJump2[1])) / 4;
			tmp4 = 2;
		} else if (tmpJump2[0] == "1") {
			rhythm_val = (32 - Number(tmpJump2[1])) / 4;
			tmp4 = 4;
		} else if (tmpJump2[0] == "2") {
			tmpJump2[1] = Number(tmpJump2[1]) + 16;
			rhythm_val = (64 - Number(tmpJump2[1])) / 4;
			tmp4 = 4;
		} else if (tmpJump2[0] == "3") {
			rhythm_val = (64 - Number(tmpJump2[1])) / 4;
			tmp4 = 4;
		}
		barBlank = rhythm_val;
	} else {
		rhythm_val = 4;
		tmp4 = 2;
		barBlank = 2;
	}
	timelineNum = Math.floor(maxPageKoma / barBlank / 4);
	measure = barBlank * timelineNum;
	pageKoma = 4 * measure;

	// 4行目：FNデータ
	var tmpHaba:Array = tmpData[3].split(",");
	var tmpHaba2:Array = tmpHaba[0].split("/");
	for (j = 0; j < tmpHaba.length - 2; j++) {
		if (tmpHaba2.length == 2) {
			haba_array[j] = {num:parseInt(tmpHaba2[0]) / 4 /multiX, header:parseInt(tmpHaba2[1]) / 10, blank:25};
			startPN = parseInt(tmpHaba2[1]) / 10;
		} else {
			haba_array[j] = {num:parseInt(tmpHaba2[0]) / 4 /multiX, header:parseInt(tmpHaba2[2]) / 10, blank:25};
			startPN = parseInt(tmpHaba2[2]) / 10;
		}
		tmpHaba2 = tmpHaba[j + 1].split("/");
		haba_array[j].blank = (parseInt(tmpHaba2[1]) / 10 - startPN) / ((parseInt(tmpHaba2[0]) - haba_array[j].num * 4) * 4 * rhythm_val / tmp4);
	}
	head_num = _root.haba_array[0].header;
	haba4_num = _root.haba_array[0].blank;

	// 7行目以降の譜面データ読込
	j = 6;
	var barIndex:Number = 0;

	frzFlg = new Array();
	for (var k = 0; k < keyLabel; k++) {
		frzFlg[k] = false;
	}
	while (tmpData[j] != undefined && tmpData[j] != ";===譜面製作者")
	{

		// 小節データを各矢印データに分割(行番号データは削除)
		var lineData:Array = tmpData[j].split(",");
		lineData[0] = lineData[0].substring(4);

		for (var k = 0; k < lineData.length - 1; k++) {

			// 矢印データは3文字以上のため、それ以外のデータはスキップ
			if (lineData[k].length >= 3) {
				var rowData:Number = parseInt(lineData[k].charAt(0), 16);
				var arr:Number = parseInt(lineData[k].charAt(1), 36);
				var baseData:Number = rowData + 16 * barIndex;

				// 拍子ごとにコマを詰める処理
				if (rhythm_val == 4) {
				} else if (rhythm_val == 3) {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 16);
				} else if (rhythm_val <= 8) {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 32);
				} else {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 64);
				}
				
				// フリーズアロー(始点)、速度変化
				if (lineData[k].length == 7) {

					if (lineData[k].charAt(3) == "+") {

						// フリーズアロー(始点)
						frzFlg[arr] = true;
						arrow_temp[arr + keyLabel].push(baseData);

					} else if (lineData[k].charAt(3) == "-") {

						// 速変
						var spdStr:String = lineData[k].slice(4);
						if(isNaN(parseFloat(spdStr))){
							var spdZ:Number = parseInt(spdStr.substring(0,1),16) - 16;
							var spdS:Number = parseInt(spdStr.slice(1)) / 100;
							var spdTmp:Number = spdZ + spdS;
						}else{
							var spdTmp:Number = Number(spdStr) / 100;
						}
						if (arr == 11) {// b
							arrow_temp[speedPos].push({pos:baseData, spd:spdTmp});

						} else if (arr == 12) {// c
							arrow_temp[boostPos].push({pos:baseData, spd:spdTmp});
						}
					}
				} else {
					// フリーズアロー(終点)
					if (frzFlg[arr] == true) {
						arrow_temp[arr + keyLabel].push(baseData);
						frzFlg[arr] = false;

						// 単発矢印
					} else {
						arrow_temp[arr].push(baseData);
					}
				}
			}
		}
		j++;
		barIndex++;
	}
	j++;

	// 譜面製作者
	if (tmpData[j] != undefined && tmpData[j] != "" && tmpData[j] != ";===ヘッダ") {
		tuning = tmpData[j];
		j++;
	}
	j++;
	// ヘッダ情報取得
	headerInfo = "";
	while (tmpData[j] != undefined && tmpData[j] != ";===フッタ" && tmpData[j] != ";===ここまで")
	{
		headerInfo += tmpData[j] + "\r";
		j++;
	}
	j++;
	// フッタ情報取得
	footerInfo = "";
	while (tmpData[j] != undefined && tmpData[j] != ";===ここまで")
	{
		footerInfo += tmpData[j] + "\r";
		j++;
	}
	readyToStart();
}

//------------------------------------------------------------
// FUJIさんエディター(Nkey用)データ読込
// 　　Dancing☆Onigiri用のデータに変換
// [引数
//           flg : ファイルから読込 / テキストから直に読込]
// [返却値なし]
//------------------------------------------------------------
function read_fujiN(flg:Boolean)
{
	if (flg == true) {
		var tmpData:Array = load_num.split("\r");
	} else {
		var tmpData2:Array = load_num.split("\r\n").join("\n");
		var tmpData:Array = tmpData2.split("\n");
	}

	// 1行目：キー数	
	if (checkKeys(tmpData[0].slice(19)) == true) {
		setKeys(tmpData[0].slice(19), loadMC);
	}
	
	// 2行目：譜面番号 
	tune_num = (tmpData[1] != undefined ? parseFloat(tmpData[1]) : 1);
	if(tune_num == 0){
		tune_num = 1;
	}

	// 5行目：拍飛ばし(初めのデータのみ確認)
	var tmpJump:Array = tmpData[4].split(",");
	var tmpJump2:Array = tmpJump[0].split("/");
	if (tmpJump2.length >= 2) {
		if (tmpJump2[0] == "0") {
			rhythm_val = (16 - Number(tmpJump2[1])) / 4;
			tmp4 = 2;
		} else if (tmpJump2[0] == "1") {
			rhythm_val = (32 - Number(tmpJump2[1])) / 4;
			tmp4 = 4;
		} else if (tmpJump2[0] == "2") {
			tmpJump2[1] = Number(tmpJump2[1]) + 16;
			rhythm_val = (64 - Number(tmpJump2[1])) / 4;
			tmp4 = 4;
		} else if (tmpJump2[0] == "3") {
			rhythm_val = (64 - Number(tmpJump2[1])) / 4;
			tmp4 = 4;
		}
		barBlank = rhythm_val;
	} else {
		rhythm_val = 4;
		tmp4 = 2;
		barBlank = 2;
	}
	timelineNum = Math.floor(maxPageKoma / barBlank / 4);
	measure = barBlank * timelineNum;
	pageKoma = 4 * measure;

	// 4行目：FNデータ
	var tmpHaba:Array = tmpData[3].split(",");
	var tmpHaba2:Array = tmpHaba[0].split("/");
	for (j = 0; j < tmpHaba.length - 2; j++) {
		if (tmpHaba2.length == 2) {
			haba_array[j] = {num:parseInt(tmpHaba2[0]) / 4 /multiX, header:parseInt(tmpHaba2[1]) / 10, blank:25};
			startPN = parseInt(tmpHaba2[1]) / 10;
		} else {
			haba_array[j] = {num:parseInt(tmpHaba2[0]) / 4 /multiX, header:parseInt(tmpHaba2[2]) / 10, blank:25};
			startPN = parseInt(tmpHaba2[2]) / 10;
		}
		tmpHaba2 = tmpHaba[j + 1].split("/");
		haba_array[j].blank = (parseInt(tmpHaba2[1]) / 10 - startPN) / ((parseInt(tmpHaba2[0]) - haba_array[j].num * 4) * 4 * rhythm_val / tmp4);
	}
	head_num = _root.haba_array[0].header;
	haba4_num = _root.haba_array[0].blank;

	// 7行目以降の譜面データ読込
	j = 6;
	var barIndex:Number = 0;

	frzFlg = new Array();
	for (var k = 0; k < keyLabel; k++) {
		frzFlg[k] = false;
	}
	while (tmpData[j] != undefined && tmpData[j] != ";===譜面製作者")
	{

		// 小節データを各矢印データに分割(行番号データは削除)
		var lineData:Array = tmpData[j].split(",");
		lineData[0] = lineData[0].substring(4);

		for (var k = 0; k < lineData.length - 1; k++) {

			// 矢印データは3文字以上のため、それ以外のデータはスキップ
			if (lineData[k].length >= 3) {
				var rowData:Number = parseInt(lineData[k].charAt(0), 16);
				var arr:Number = parseInt(lineData[k].charAt(1), 36) - 10;
				var baseData:Number = rowData + 16 * barIndex;

				// 拍子ごとにコマを詰める処理
				if (rhythm_val == 4) {
				} else if (rhythm_val == 3) {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 16);
				} else if (rhythm_val <= 8) {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 32);
				} else {
					baseData -= Number(tmpJump2[1]) * Math.floor(baseData / 64);
				}
				
				// フリーズアロー(始点)、速度変化
				if (lineData[k].length == 7) {

					if (lineData[k].charAt(3) == "+") {

						// フリーズアロー(始点)
						frzFlg[arr] = true;
						arrow_temp[arr + keyLabel].push(baseData);

					} else if (lineData[k].charAt(3) == "-") {

						// 速変
						var spdStr:String = lineData[k].slice(4);
						if(isNaN(parseFloat(spdStr))){
							var spdZ:Number = parseInt(spdStr.substring(0,1),16) - 16;
							var spdS:Number = parseInt(spdStr.slice(1)) / 100;
							var spdTmp:Number = spdZ + spdS;
						}else{
							var spdTmp:Number = Number(spdStr) / 100;
						}
						if (arr == 20) {// u
							arrow_temp[speedPos].push({pos:baseData, spd:spdTmp});

						} else if (arr == 21) {// v
							arrow_temp[boostPos].push({pos:baseData, spd:spdTmp});
						}
					}
				} else {
					// フリーズアロー(終点)
					if (frzFlg[arr] == true) {
						arrow_temp[arr + keyLabel].push(baseData);
						frzFlg[arr] = false;

						// 単発矢印
					} else {
						arrow_temp[arr].push(baseData);
					}
				}
			}
		}
		j++;
		barIndex++;
	}
	j++;

	// 譜面製作者
	if (tmpData[j] != undefined && tmpData[j] != "" && tmpData[j] != ";===ヘッダ") {
		tuning = tmpData[j];
		j++;
	}
	j++;
	// ヘッダ情報取得
	headerInfo = "";
	while (tmpData[j] != undefined && tmpData[j] != ";===フッタ" && tmpData[j] != ";===ここまで")
	{
		headerInfo += tmpData[j] + "\r";
		j++;
	}
	j++;
	// フッタ情報取得
	footerInfo = "";
	while (tmpData[j] != undefined && tmpData[j] != ";===ここまで")
	{
		footerInfo += tmpData[j] + "\r";
		j++;
	}
	readyToStart();
}

//------------------------------------------------------------
// ドイルさんエディターデータ読込
// 　　Dancing☆Onigiri用のデータに変換
// [引数
//           objDos : 読込先ルート]
// [返却値なし]
//------------------------------------------------------------
function read_doyle(objDos:Object)
{
	if (checkKeys(objDos.key) == true) {
		setKeys(objDos.key, loadMC);
	}
	// ヘッダー取込 
	headerInfo = "";
	if (objDos.musictitle != "") {
		headerInfo += "&musicTitle=" + objDos.musictitle + "," + objDos.artist + "," + objDos.artisturl + "&\r";
	}
	var difStepArr:Array = new Array();
	var difNum:Array = objDos.difName.split(",");
	for (var j = 0; j < difNum.length; j++) {
		difStepArr.push(keyLabel);
	}
	headerInfo += "&difStep=" + (difStepArr.length == 0 ? keyLabel : difStepArr) + "&difName=" + (objDos.difName == undefined ? "Normal" : objDos.difName) + "&speedlock=" + (objDos.speedlock == undefined ? "1" : objDos.speedlock) + "&\r";

	arrow_temp = new Array();
	for (var j = 0; j < keyLabel; j++) {
		arrow_temp[j] = objDos["arrow_data(" + j + ")"].split(",");
		arrow_temp[j + keyLabel] = objDos["frzarrow_data(" + j + ")"].split(",");
		if(isNaN(parseFloat(arrow_temp[j][0]))){
			arrow_temp[j] = new Array();
		}
		if(isNaN(parseFloat(arrow_temp[j + keyLabel][0]))){
			arrow_temp[j + keyLabel] = new Array();
		}
	}
	var speed_temp:Array = objDos.speed_data.split(",");
	arrow_temp[speedPos] = new Array();
	if(!isNaN(parseFloat(speed_temp[0]))){
		for (var j = 0; j < speed_temp.length; j += 2) {
			arrow_temp[speedPos].push({pos:parseFloat(speed_temp[j]), spd:parseFloat(speed_temp[j + 1])});
		}
	}
	arrow_temp[boostPos] = new Array();
	arrow_temp[rhythmPos] = objDos.rhythmchange_data.split(",");

	haba_array = new Array();
	first_array = objDos.first_data.split(",");
	interval_array = objDos.interval_data.split(",");
	prevNum = 0;
	intervalCnt = -1;
	for (j = 0; j < first_array.length; j++) {
		if (isNaN(parseFloat(first_array[j])) && isNaN(parseFloat(interval_array[j]))) {
		} else {
			barLength = (j - prevNum) * 32;
			if (isNaN(parseFloat(first_array[j]))) {
				first_num_temp = _root.haba_array[intervalCnt].header + barLength * _root.haba_array[intervalCnt].blank;
			} else {
				first_num_temp = Number(first_array[j]);
			}
			if (isNaN(parseFloat(interval_array[j]))) {
				interval_num_temp = _root.haba_array[intervalCnt].blank;
			} else {
				interval_num_temp = Number(interval_array[j]);
			}
			haba_array[++intervalCnt] = {num:j/multiX, header:first_num_temp, blank:interval_num_temp};
		}
	}
	tune_num = (isNaN(parseFloat(objDos.index)) ? "1" : objDos.index);
	if(objDos.tuning != undefined){
		tuning = objDos.tuning.split("\r")[0];
	}
	pageMax = 100;
	readyToStart();
}

//------------------------------------------------------------
// セーブデータ読込
// 　　
// [引数
//           objDos : 読込先ルート]
// [返却値なし]
//------------------------------------------------------------
function directRead(objDos:Object)
{
	load_kd = _root.load_num.split("/");
	delete _root.load_num;

	// エディターで指定されている場合はキーを設定
	if (checkKeys(load_kd[0]) == true) {
		load_temp = load_kd[1].split("&");
		setKeys(load_kd[0], loadMC);
	} else {
		load_temp = load_kd[0].split("&");
		
		// 開始が矢印データであることを確認
		var checkArr:Array = load_temp[0].split(",");
		if (checkArr[0] == "" || !isNaN(parseFloat(checkArr[0]))) {
			var keyCand:Number = (load_temp.length - 9) / 2;
			if (keyCand != keyLabel) {
				if (checkKeys(keyCand) == true) {
					setKeys(Math.floor(keyCand), loadMC);
				}
			}
		}
	}
	delete load_kd;
	arrow_load = new Array();
	for (var j = 0; j <= rhythmPos; j++) {
		arrow_load[j] = new Array();
		arrow_load[j] = load_temp[j].split(",");
		if(isNaN(parseFloat(arrow_load[j][0]))){
			arrow_load[j] = [];
		}
	}

	// 速度データ変換
	for(var j = speedPos; j <= boostPos; j++){
		if (!isNaN(parseFloat(arrow_load[j][0]))) {
			var speed_load:Array = arrow_load[j].concat();
			for (var k = 0; k < speed_load.length; k++) {
				var spdTmp:Array = speed_load[k].split("=");
				arrow_temp[j][k] = {pos:parseFloat(spdTmp[0]), spd:1};
				if (spdTmp[1] == undefined) {
				} else {
					arrow_temp[j][k].spd = parseFloat(spdTmp[1]);
				}
			}
		}
	}

	// リズムデータ展開 
	if (!isNaN(parseFloat(arrow_load[rhythmPos][0]))) {
		for (var k = 0; k < arrow_load[rhythmPos].length; k++) {
			if (arrow_load[rhythmPos][k] == "") {
				arrow_temp[rhythmPos][k] = parseInt(arrow_temp[rhythmPos][k - 1]) + 1;
			} else {
				arrow_temp[rhythmPos][k] = parseInt(arrow_load[rhythmPos][k]);
			}
		}
	}
	
	if (objDos.rhythm_num != undefined) {
		var rhythmTemp:Array = objDos.rhythm_num.split(",");
		if(!isNaN(parseFloat(rhythmTemp[0]))){
			for (var k = 0; k < rhythmTemp.length; k++) {
				if (rhythmTemp[k] == "") {
					arrow_temp[rhythmPos][k] = parseInt(rhythmTemp[k - 1]) + 1;
				} else {
					arrow_temp[rhythmPos][k] = parseInt(rhythmTemp[k]);
				}
			}
		}
	}

	first_temp = load_temp[rhythmPos + 1].split(",");
	haba_temp1 = load_temp[rhythmPos + 2].split(",");
	haba_temp2 = load_temp[rhythmPos + 3].split(",");

	// フッターデータ取込
	if (objDos.first_num != undefined) {
		first_temp = objDos.first_num.split(",");
	}
	if (objDos.haba_num != undefined) {
		haba_temp1 = objDos.haba_num.split(",");
	}
	if (objDos.haba_page_num != undefined) {
		haba_temp2 = objDos.haba_page_num.split(",");
	}

	if (isNaN(parseFloat(first_temp[0])) || isNaN(parseFloat(haba_temp1[0])) || isNaN(parseFloat(haba_temp2[0]))) {
		haba_array[0] = {num:0, header:200, blank:10};
		first_temp = [haba_array[0].header];
		haba_temp1 = [haba_array[0].blank];
		haba_temp2 = [haba_array[0].num];
	} else {
		for (var v:Number = 0; v < haba_temp1.length; v++) {
			haba_array[v] = {num:parseFloat(haba_temp2[v])/multiX, header:parseFloat(first_temp[v]), blank:parseFloat(haba_temp1[v])};
		}
	}
	head_num = haba_array[0].header;
	haba4_num = haba_array[0].blank;
	tune_num = load_temp[rhythmPos + 4];
	pageMax = load_temp[rhythmPos + 5];
//	tmpMeasure = load_temp[rhythmPos + 6];
	barBlank = load_temp[rhythmPos + 7];
	if (objDos.beat_num != undefined) {
		beatNum = (isNaN(parseFloat(objDos.beat_num)) ? 4 : parseFloat(objDos.beat_num));
	}
	lblArray = load_temp[rhythmPos + 8].split(",");
	if (objDos.label_num != undefined) {
		lblArray = objDos.label_num.split(",");
	}
	for(var j = 0; j < lblArray.length; j++){
		lblArray[j] = parseFloat(lblArray[j]) / multiX;
	}
	if (isNaN(parseFloat(lblArray[0]))) {
		lblArray = [0];
	}
	for (var j = 0; j < speedPos; j++) {
		for (var k = 0; k < arrow_load[j].length; k++) {
			arrow_temp[j].push(parseFloat(arrow_load[j][k]));
		}
		if (arrow_load[j][0] == "") {
			arrow_temp[j].pop();
		}
	}
	if (objDos.tuning != undefined) {
		tuning = objDos.tuning;
	}
	
	if (isNaN(parseFloat(head_num)) || isNaN(parseFloat(haba4_num)) || isNaN(parseFloat(tune_num))) {
		head_num = 200;
		if (isNaN(parseFloat(firstbpm.text))) {
			haba4_num = 10.0;
		} else {
			haba4_num = 1800 / Number(firstbpm.text);
		}
		tune_num = 1;
		pageMax = 100;
	}
	delete arrow_load;

	// ヘッダー取込
	headerInfo = "";
	for (var j = 0; j < headerList.length; j++) {
		headerInfo += (objDos[headerList[j]] == undefined ? "" : ("&" + headerList[j] + "=" + objDos[headerList[j]] + "&\r"));
	}

	// 矢印色・歌詞データ取込
	footerInfo = "";
	for (var j = 0; j < footerList.length; j++) {
		var valName:String = footerList[j] + (tune_num == 1 ? "" : tune_num) + "_data";
		footerInfo += (objDos[valName] == undefined ? "" : ("&" + valName + "=" + objDos[valName] + "&\r"));
	}

	if(barBlank != undefined){
		beatNum = (barBlank == 2 ? 4 : barBlank);
	}else{
		barBlank = (beatNum == 4 ? 2 : beatNum);
	}
	measure = Math.floor(maxPageKoma / beatNum / 4) * beatNum;
	timelineNum = measure / barBlank;
	pageKoma = 4 * measure;
	readyToStart();
}

function loadBtn(){
	ldList.removeMovieClip();
	if(file_name.length > 0){
		var sav = new LoadVars();
		sav.load(file_name + ".sm");
		sav.onData = function(val){
			if(val == undefined){
				_root.error_msg = "そのファイルは存在しないか読み込めません";
			}else{
				_root.read_sm(val, "\r\n");
			}
		};
	}else{
		var sav = new LoadVars();
		sav.load(save_file+".txt");
		sav.onData = function(val){
			if(val == undefined){
				if(_root.save_file.length > 0){
					_root.error_msg = "そのファイルは存在しないか読み込めません";
					return;
				}
				crFlg = true;
			} else {
				_root.error_msg = "";
				_root.load_num = val;
				crFlg = false;
			}
			this.decode(_root.load_num);
			if(_root.load_num.substring(0,4)=="nkey"){
				_root.read_fujiN(crFlg);
			}else if(_root.load_num.substring(1,4)=="key" || _root.load_num.substring(2,5)=="key"){
				
				if(_root.load_num.substring(4,6)=="1." || _root.load_num.substring(5,7)=="1."){
					_root.read_fuji115(crFlg);
				}else{
					_root.read_fuji(crFlg);
				}
				
			}else if(_root.load_num.substring(0,7) == "Dancing"){
				_root.read_doyle(this);
			}else if(_root.load_num.substring(0,6) == "#TITLE"){
				_root.read_sm(_root.load_num, "\r");
			}else{
				_root.directRead(this);
			}
		};
	}
}

function readyToStart()
{

	if (loadPageFlg == true) {
		var endNum:Number = 0;
		for (var j = 0; j < speedPos; j++) {
			if (!isNaN(parseFloat(arrow_temp[j][0]))) {
				var k:Number = arrow_temp[j].length - 1;
				if (endNum < parseInt(arrow_temp[j][k])) {
					endNum = parseInt(arrow_temp[j][k]);
				}
			}
		}
		page = Math.floor(endNum / pageKoma) + 1;
	}
	
	if (Number(pageMaxInt.text) < 20 || isNaN(parseInt(pageMaxInt.text))) {
	} else if (Number(pageMaxInt.text) > 1000) {
		pageMax = 1000;
	} else {
		pageMax = parseInt(pageMaxInt.text);
	}

	gotoAndPlay("pageStart");
	endMask._visible = false;
	opt._visible = false;
	short._visible = false;
	arrCnt._visible = false;
	make_koma(pageKoma * (page - 1));
	set_interval(pagePos / barBlank / 4);
}