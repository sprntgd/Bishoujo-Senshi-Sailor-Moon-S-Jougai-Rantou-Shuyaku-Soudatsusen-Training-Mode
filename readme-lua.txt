日本語の解説が変になる部分があるかも知れません。
私は日本語へたくそなのですみません。

バグ報告か質問とかあれば連絡してください。
Contact me with bug reports and questions.
  Twitter: @SprntGd
  e-Mail:  sprintgod@hotmail.com

================================================================================
 必要なもの / REQUIREMENTS
--------------------------------------------------------------------------------
BizHawk (Tested on version 2.2.2)
  https://github.com/TASVideos/BizHawk/releases/

Config > Cores > SNES > BSNES
Tools > Lua Console
Script > Open Script > SailorMoonS.lua
--------------------------------------------------------------------------------
Snes9X rerecording 1.51 v7
  http://tasvideos.org/EmulatorResources/Snes9x.html

File > Lua Scripting > New Lua Script Window
Browse > SailorMoonS.lua > Run

Snes9X ver1.52で働きません。1.51使いべきです。
Does not work with Snes9X v1.52. Make sure to use 1.51.
--------------------------------------------------------------------------------
ROM
* Bishoujo Senshi Sailor Moon S - Jougai Rantou! Shuyaku Soudatsusen (J)
  CRC: B0FD1854
* Bishoujo Senshi Sailor Moon Super S - Zenin Sanka!! Shuyaku Soudatsusen (J)
  CRC: 25440331

================================================================================
 パッチノート / PATCH NOTES
--------------------------------------------------------------------------------
2018/12/WIP
   * 改善された色変更モード。
   * Improved color edit mode.

2018/11/19
   * 画面の上で発生したルナPの判定がおかしくなるバグをなおした。
   * Fixed hitbox for Luna-P when spawned off the top of the screen.

2018/11/18
   * 設定メニュー追加（START）
     Added settings menu (Start button)
   * 入力再生追加 (SELECT)
     Added input playback (Select button)
   * 入力表示追加
     Added input display
   * Ｒボタンを一回押して相手操作、もう一回押して元に戻る。
     以前の動作(押し続け)は設定メニューから選べる。
     Press the R button once to control the opponent, and again to cancel.
     Old behavior of holding the button can be selected in the settings menu.

2017/12/27
   * ムーンの小Ｋバグデータを直した。
     Fixed data for Moon's light kick. 

2017/05/27
   * ラグ計算追加
     Lag calculation added

2017/05/26
   * 速度を画面の下に追加
     Added velocity to the bottom of the screen
   * いろいろバグ直し
     Various bug fixes
   * じゃがみではありません。しゃがみです。
     Fixed brain to no longer mistranslate the word crouch.

2017/05/25
   * 初版
     First release

--------------------------------------------------------------------------------
 操作 / CONTROLS
--------------------------------------------------------------------------------
R        : 相手操作         : Control opponent

L        : リセット         : Reset position
L+←     : 左へ             : Left corner
L+→     : 右へ             : Right corner
L+?+B    : １ドットずつ左へ : Move both characters right 1 pixel
L+?+A    : １ドットずつ右へ : Move both characters left 1 pixel
L+?+Y    : 距離を縮める     : Decrease character spacing
L+?+X    : 距離を伸ばす     : Increase character spacing
L+?+START: 元に戻す         : Reset to default
L+↓     : キャラ変更       : Change character
L+↑     : 色変更           : Change color

START    : 設定画面         : Settings menu
SELECT   : 再生モード       : Input playback mode

A+B+X+Y  :（；^∀^）
  　+↑  : 着地失敗         : Failed landing
    +←→: 転んで           : Fall over
    +↓  : ちびムーン失敗   : Chibimoon misfire
    
1P SELECT長押しでキャラ選択へ戻る
Hold 1P Select to return to character select

================================================================================
 設定画面 / SETTINGS MENU
--------------------------------------------------------------------------------
SHOW INPUT (OFF/1P/2P/ON)
 * 入力表示             * Input display

SHOW DAMAGE (ON/OFF)
 * HPゲージ/数字        * HP gauge
 * ダメージ             * Damage values
 * 硬直差               * Frame advantage.

SHOW STATUS (ON/OFF)
 * X,Y                  * Position
 * 距離　               * Distance
 * 速度                 * Velocity
 * 攻撃発生             * Attack frame (first active frame)
 * 攻撃判定(HL)         * Attack guard type(HL)
 * 攻撃ダメージ    　　 * Attack type and unmodified damage value.

HITBOXES (ON/OFF/1P/2P)
 * 赤 攻撃              * Red    = Attack
 * 緑 喰らい            * Green  = Hurt
 * 黄 喰らい(頭)        * Yellow = Hurt (head)
 * 紺 具体              * Blue   = Physical
SUBFRAME
 サブフレームの判定データーを利用する
 Use hitbox data from subframes
 * HIT     : あたったのかを正しく表示 : Collisions appear correctly
 * -1F     : 前のフレーム             : Previous frame
 * 1P MOVE : 1P動きの後               : After 1P movement
 * 2P MOVE : 1P+2P動きの後            : After 1P and 2P movement
 * OFF     : 飛び道具動きの後         : After projectiles have moved

DUMMY
 * AUTO   : 相手に併せてしゃがむ : Match the opponent
 * STAND  : 立つ
 * DUCK   : しゃがむ
 * JUMP   : 飛ぶ
 * OFF    : 何もしない
GUARD
 * HIT    : 攻撃をガード         : Block only
 * THROW  : 投げの受け身         : Throw tech only
 * ALL    : ガード＋受け身       : Both
 * OFF    : 何もしない
RECOVERY
 攻撃を受けた後の行動
 The action to perform after taking a hit
 * AUTO   : 相手に併せてしゃがむ : Match the opponent
 * STAND  : 立つ
 * DUCK   : しゃがむ
 * BACK+S : バクステ→立つ       : Backdash to Stand
 * BACK+D : バクステ→しゃがむ   : Backdash to Duck
 * BACK++ : 連続バクステ         : Multiple backdash
PLAY SLOT
 攻撃が受けた瞬間で再生を始める
 Begins playback the moment an attack is received.

PAD SWAP(R)
 * TOGGLE : 押し
 * HOLD   : 押し続け

================================================================================
 再生モード / INPUT PLAYBACK MODE
--------------------------------------------------------------------------------
 1. SELECTを二回押して記録モード開始
 2. A/B/X/Yを押して記録スロット選択
 3. 次の動きから記録が始まる。SELECTで終わり
 4. SELECTを一回押して再生モード開始
 5. A/B/X/Yを押して再生スロット選択
 6. SELECTを一回押して再生、もう一回おして止まる、STARTで再生モード終了

 1. Press select twice to enter recording mode.
 2. Press A/B/X/Y to select a recording slot.
 3. Recording starts from the next character movement. Press select to end.
 4. Press select once to enter playback mode.
 5. Press A/B/X/Y to select a playback slot.
 6. Press select once to play, again to stop, or start to exit playback mode.

================================================================================
 色変更 / COLOR EDIT
--------------------------------------------------------------------------------
設定画面でSELECTを押して色変更モードに入る。
Press Select while the menu is open to enter color edit mode.

Select(長押し)で終了。
Exit by holding Select.

←→  : 色選択         : Select palette
Y+↑↓: 赤変更         : Change red
B+↑↓: 緑変更         : Change green
A+↑↓: 青変更         : Change blue
X+↑↓: 赤緑青全部変更 : Change all colors
    +R: 2Pで           : Change player 2
SELECT: 選択した色表示 : Highlight selected palette
START : 色を元に戻す   : Restore color to default
L     : キャラ操作     : Move character

SELECT+START
      : セーブ(BMP)    : Save(BMP)

================================================================================
 バッグとか / GAME BUGS ETC.
--------------------------------------------------------------------------------
* 判定バグによって、右にいるプレーヤーの攻撃の間合いが１ドット伸びる。
  ですが、投げ間合いが１ドット短くなる。
* Due to a hitbox bug, standing on the right gives 1 pixel more attack range,
  but throw range becomes 1 pixel shorter.
  
* １Ｆの中ではこの感じ：
  １Ｐ当たり判定チェック → １Ｐ動き → ２Ｐ当たり判定チェック → ２Ｐ動き
  結果は、１Ｐが前に動いてる時でやられ判定が前にでる、不利になります。
* Frame processing order is like this:
  1P Hit Check → 1P Movement → 2P Hit Check → 2P Movement
  The result is that when 1P is moving forwards, their hurtbox sticks out more.

* コンボのつなぎは追加１フレームの有利が必要。
  > 不利６Ｆの技は、発生６Ｆの技で確定反撃することが出来る。
　> 有利６Ｆの技は、発生６Ｆの技にコンボがつなげない。５Ｆならつなげる。
* Combos require 1 extra frame of advantage
  > A -6F move can be punished by a 6F move.
  > A +6F move cannot combo into a 6F move.
  
* しゃがみ→立つ、立つ→歩く、とかは１フレームが経つ。
  > 弱シャボン(+6F) → ５強Ｋ(5F)がコンボにつなげる。
  > 弱シャボン(+6F) → ２強Ｋ(しゃがみ1F+5F)がつなげない。
  > 弱シャボン(+6F) → ４／６強Ｋ(歩き1F+5F)がつなげない。
  > 弱シャボン → ４ため（４強Ｋ）６＋弱Ｐ ＝ 近いなら無理
  > 弱シャボン → ４ため（５強Ｋ）６＋弱Ｐ ＝ 可能
* Switching between standing/ducking/walking eats 1 frame.
  > L.Shabon(+6F) → 5HK(5F) can combo.
  > L.Shabon(+6F) → 4HK(1F walk + 5F) cannot combo.
  > L.Shabon(+6F) → 2HK(1F duck + 5F) cannot combo.
  > L.Shabon → 4..(4HK)6LP = Impossible if close
  > L.Shabon → 4..(5HK)6LP = Always possible

* 普通の攻撃は相手を自分の場所から押します。
  空中の攻撃か飛び道具は相手を攻撃の向きに押します。
  それは判定データの「J」の意味。
  ちなみに、マーキュリーの空中弱キックにはこの「J」がない。
* Normal attacks push the opponent away from our position.
  Jump attacks push the opponent in the direction we are facing.
  This what "J" means in the attack data.
  Oddly, Mercury's J.LK does not have the J flag set.

* バックステップ出ないバッグ：
    ５ → ちょうど１６フレーム後で ４５４ → 出ない。
* Backdash input bug:
    Input 5 → Exactly 16 frames leter press 454 → Nothing happens.

* バクステの硬直は１フレーム。
  ムーンとちびムーンはその１フレームをキャンセルすることができる。
  そうすれば、バクステ→バクステ→バクステは完全に無敵ですが、
  ムーンのバクステは早すぎて二回目のバクステが出なくなります。
  入力（５４５４）はこうなる：
  　ステート０ → ５ → ステート１
  　ステート１ → ４ → ステート２
  　ステート２ → ５ → ステート３
  　ステート３ → ４ → バクステが出ます(ステート３に残る)
  ステートＸからステート０に戻るのは１５フレームがかかる。
  それまでは、次のバクステの入力が始まれない。
  一回目のバクステの入力を（５４５ 待つ ４）にすれば、
  最後の「４」のすぐ後にステート０に戻って、連続バクステが出来る。
* Backdash has 1 frame of recovery.
  Moon and Chibimoon can cancel that 1 frame.
  This makes their Backdash→Backdash completely invincible.
  However, Moon's backdash is too fast for it to work properly.
  The input (5454) looks like this:
    State0 → 5 → State1
    State1 → 4 → State2
    State2 → 5 → State3
    State3 → 4 → Backdash, remain in State3.
  It takes 15 frames to return from the above states to State0.
  Until then, it is not possible to start another backdash input.
  If you input the first backdash as (545 wait 4), the return to state0
  occurs very shortly after the last 4, allowing for consecutive backdashes.

  ウラヌスは１フレームずつに「４５４→長おし」を入力すれば、
 １４Ｆのバクステの後までステート３に残って、
  そのまま二回目のバクステが出ます。
  With Uranus if you input a frame perfect 454(hold),
  State3 remains for 1 frame after the 14 frame backdash ends,
  and a second backdash will come out while still holding 4.