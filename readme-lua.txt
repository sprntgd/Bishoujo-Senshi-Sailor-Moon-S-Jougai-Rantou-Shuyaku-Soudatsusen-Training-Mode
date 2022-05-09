���{��̉�����ςɂȂ镔�������邩���m��܂���B
���͓��{��ւ������Ȃ̂ł��݂܂���B

�o�O�񍐂�����Ƃ�����ΘA�����Ă��������B
Contact me with bug reports and questions.
  Twitter: @SprntGd
  e-Mail:  sprintgod@hotmail.com

================================================================================
 �K�v�Ȃ��� / REQUIREMENTS
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

Snes9X ver1.52�œ����܂���B1.51�g���ׂ��ł��B
Does not work with Snes9X v1.52. Make sure to use 1.51.
--------------------------------------------------------------------------------
ROM
* Bishoujo Senshi Sailor Moon S - Jougai Rantou! Shuyaku Soudatsusen (J)
  CRC: B0FD1854
* Bishoujo Senshi Sailor Moon Super S - Zenin Sanka!! Shuyaku Soudatsusen (J)
  CRC: 25440331

================================================================================
 �p�b�`�m�[�g / PATCH NOTES
--------------------------------------------------------------------------------
2018/12/WIP
   * ���P���ꂽ�F�ύX���[�h�B
   * Improved color edit mode.

2018/11/19
   * ��ʂ̏�Ŕ����������iP�̔��肪���������Ȃ�o�O���Ȃ������B
   * Fixed hitbox for Luna-P when spawned off the top of the screen.

2018/11/18
   * �ݒ胁�j���[�ǉ��iSTART�j
     Added settings menu (Start button)
   * ���͍Đ��ǉ� (SELECT)
     Added input playback (Select button)
   * ���͕\���ǉ�
     Added input display
   * �q�{�^������񉟂��đ��葀��A������񉟂��Č��ɖ߂�B
     �ȑO�̓���(��������)�͐ݒ胁�j���[����I�ׂ�B
     Press the R button once to control the opponent, and again to cancel.
     Old behavior of holding the button can be selected in the settings menu.

2017/12/27
   * ���[���̏��j�o�O�f�[�^�𒼂����B
     Fixed data for Moon's light kick. 

2017/05/27
   * ���O�v�Z�ǉ�
     Lag calculation added

2017/05/26
   * ���x����ʂ̉��ɒǉ�
     Added velocity to the bottom of the screen
   * ���낢��o�O����
     Various bug fixes
   * ���Ⴊ�݂ł͂���܂���B���Ⴊ�݂ł��B
     Fixed brain to no longer mistranslate the word crouch.

2017/05/25
   * ����
     First release

--------------------------------------------------------------------------------
 ���� / CONTROLS
--------------------------------------------------------------------------------
R        : ���葀��         : Control opponent

L        : ���Z�b�g         : Reset position
L+��     : ����             : Left corner
L+��     : �E��             : Right corner
L+?+B    : �P�h�b�g������ : Move both characters right 1 pixel
L+?+A    : �P�h�b�g���E�� : Move both characters left 1 pixel
L+?+Y    : �������k�߂�     : Decrease character spacing
L+?+X    : ������L�΂�     : Increase character spacing
L+?+START: ���ɖ߂�         : Reset to default
L+��     : �L�����ύX       : Change character
L+��     : �F�ύX           : Change color

START    : �ݒ���         : Settings menu
SELECT   : �Đ����[�h       : Input playback mode

A+B+X+Y  :�i�G^��^�j
  �@+��  : ���n���s         : Failed landing
    +����: �]���           : Fall over
    +��  : ���у��[�����s   : Chibimoon misfire
    
1P SELECT�������ŃL�����I���֖߂�
Hold 1P Select to return to character select

================================================================================
 �ݒ��� / SETTINGS MENU
--------------------------------------------------------------------------------
SHOW INPUT (OFF/1P/2P/ON)
 * ���͕\��             * Input display

SHOW DAMAGE (ON/OFF)
 * HP�Q�[�W/����        * HP gauge
 * �_���[�W             * Damage values
 * �d����               * Frame advantage.

SHOW STATUS (ON/OFF)
 * X,Y                  * Position
 * �����@               * Distance
 * ���x                 * Velocity
 * �U������             * Attack frame (first active frame)
 * �U������(HL)         * Attack guard type(HL)
 * �U���_���[�W    �@�@ * Attack type and unmodified damage value.

HITBOXES (ON/OFF/1P/2P)
 * �� �U��              * Red    = Attack
 * �� ��炢            * Green  = Hurt
 * �� ��炢(��)        * Yellow = Hurt (head)
 * �� ���              * Blue   = Physical
SUBFRAME
 �T�u�t���[���̔���f�[�^�[�𗘗p����
 Use hitbox data from subframes
 * HIT     : ���������̂��𐳂����\�� : Collisions appear correctly
 * -1F     : �O�̃t���[��             : Previous frame
 * 1P MOVE : 1P�����̌�               : After 1P movement
 * 2P MOVE : 1P+2P�����̌�            : After 1P and 2P movement
 * OFF     : ��ѓ�����̌�         : After projectiles have moved

DUMMY
 * AUTO   : ����ɕ����Ă��Ⴊ�� : Match the opponent
 * STAND  : ����
 * DUCK   : ���Ⴊ��
 * JUMP   : ���
 * OFF    : �������Ȃ�
GUARD
 * HIT    : �U�����K�[�h         : Block only
 * THROW  : �����̎󂯐g         : Throw tech only
 * ALL    : �K�[�h�{�󂯐g       : Both
 * OFF    : �������Ȃ�
RECOVERY
 �U�����󂯂���̍s��
 The action to perform after taking a hit
 * AUTO   : ����ɕ����Ă��Ⴊ�� : Match the opponent
 * STAND  : ����
 * DUCK   : ���Ⴊ��
 * BACK+S : �o�N�X�e������       : Backdash to Stand
 * BACK+D : �o�N�X�e�����Ⴊ��   : Backdash to Duck
 * BACK++ : �A���o�N�X�e         : Multiple backdash
PLAY SLOT
 �U�����󂯂��u�ԂōĐ����n�߂�
 Begins playback the moment an attack is received.

PAD SWAP(R)
 * TOGGLE : ����
 * HOLD   : ��������

================================================================================
 �Đ����[�h / INPUT PLAYBACK MODE
--------------------------------------------------------------------------------
 1. SELECT���񉟂��ċL�^���[�h�J�n
 2. A/B/X/Y�������ċL�^�X���b�g�I��
 3. ���̓�������L�^���n�܂�BSELECT�ŏI���
 4. SELECT����񉟂��čĐ����[�h�J�n
 5. A/B/X/Y�������čĐ��X���b�g�I��
 6. SELECT����񉟂��čĐ��A������񂨂��Ď~�܂�ASTART�ōĐ����[�h�I��

 1. Press select twice to enter recording mode.
 2. Press A/B/X/Y to select a recording slot.
 3. Recording starts from the next character movement. Press select to end.
 4. Press select once to enter playback mode.
 5. Press A/B/X/Y to select a playback slot.
 6. Press select once to play, again to stop, or start to exit playback mode.

================================================================================
 �F�ύX / COLOR EDIT
--------------------------------------------------------------------------------
�ݒ��ʂ�SELECT�������ĐF�ύX���[�h�ɓ���B
Press Select while the menu is open to enter color edit mode.

Select(������)�ŏI���B
Exit by holding Select.

����  : �F�I��         : Select palette
Y+����: �ԕύX         : Change red
B+����: �ΕύX         : Change green
A+����: �ύX         : Change blue
X+����: �ԗΐS���ύX : Change all colors
    +R: 2P��           : Change player 2
SELECT: �I�������F�\�� : Highlight selected palette
START : �F�����ɖ߂�   : Restore color to default
L     : �L��������     : Move character

SELECT+START
      : �Z�[�u(BMP)    : Save(BMP)

================================================================================
 �o�b�O�Ƃ� / GAME BUGS ETC.
--------------------------------------------------------------------------------
* ����o�O�ɂ���āA�E�ɂ���v���[���[�̍U���̊ԍ������P�h�b�g�L�т�B
  �ł����A�����ԍ������P�h�b�g�Z���Ȃ�B
* Due to a hitbox bug, standing on the right gives 1 pixel more attack range,
  but throw range becomes 1 pixel shorter.
  
* �P�e�̒��ł͂��̊����F
  �P�o�����蔻��`�F�b�N �� �P�o���� �� �Q�o�����蔻��`�F�b�N �� �Q�o����
  ���ʂ́A�P�o���O�ɓ����Ă鎞�ł��ꔻ�肪�O�ɂł�A�s���ɂȂ�܂��B
* Frame processing order is like this:
  1P Hit Check �� 1P Movement �� 2P Hit Check �� 2P Movement
  The result is that when 1P is moving forwards, their hurtbox sticks out more.

* �R���{�̂Ȃ��͒ǉ��P�t���[���̗L�����K�v�B
  > �s���U�e�̋Z�́A�����U�e�̋Z�Ŋm�蔽�����邱�Ƃ��o����B
�@> �L���U�e�̋Z�́A�����U�e�̋Z�ɃR���{���Ȃ��Ȃ��B�T�e�Ȃ�Ȃ���B
* Combos require 1 extra frame of advantage
  > A -6F move can be punished by a 6F move.
  > A +6F move cannot combo into a 6F move.
  
* ���Ⴊ�݁����A���������A�Ƃ��͂P�t���[�����o�B
  > ��V���{��(+6F) �� �T���j(5F)���R���{�ɂȂ���B
  > ��V���{��(+6F) �� �Q���j(���Ⴊ��1F+5F)���Ȃ��Ȃ��B
  > ��V���{��(+6F) �� �S�^�U���j(����1F+5F)���Ȃ��Ȃ��B
  > ��V���{�� �� �S���߁i�S���j�j�U�{��o �� �߂��Ȃ疳��
  > ��V���{�� �� �S���߁i�T���j�j�U�{��o �� �\
* Switching between standing/ducking/walking eats 1 frame.
  > L.Shabon(+6F) �� 5HK(5F) can combo.
  > L.Shabon(+6F) �� 4HK(1F walk + 5F) cannot combo.
  > L.Shabon(+6F) �� 2HK(1F duck + 5F) cannot combo.
  > L.Shabon �� 4..(4HK)6LP = Impossible if close
  > L.Shabon �� 4..(5HK)6LP = Always possible

* ���ʂ̍U���͑���������̏ꏊ���牟���܂��B
  �󒆂̍U������ѓ���͑�����U���̌����ɉ����܂��B
  ����͔���f�[�^�́uJ�v�̈Ӗ��B
  ���Ȃ݂ɁA�}�[�L�����[�̋󒆎�L�b�N�ɂ͂��́uJ�v���Ȃ��B
* Normal attacks push the opponent away from our position.
  Jump attacks push the opponent in the direction we are facing.
  This what "J" means in the attack data.
  Oddly, Mercury's J.LK does not have the J flag set.

* �o�b�N�X�e�b�v�o�Ȃ��o�b�O�F
    �T �� ���傤�ǂP�U�t���[����� �S�T�S �� �o�Ȃ��B
* Backdash input bug:
    Input 5 �� Exactly 16 frames leter press 454 �� Nothing happens.

* �o�N�X�e�̍d���͂P�t���[���B
  ���[���Ƃ��у��[���͂��̂P�t���[�����L�����Z�����邱�Ƃ��ł���B
  ��������΁A�o�N�X�e���o�N�X�e���o�N�X�e�͊��S�ɖ��G�ł����A
  ���[���̃o�N�X�e�͑������ē��ڂ̃o�N�X�e���o�Ȃ��Ȃ�܂��B
  ���́i�T�S�T�S�j�͂����Ȃ�F
  �@�X�e�[�g�O �� �T �� �X�e�[�g�P
  �@�X�e�[�g�P �� �S �� �X�e�[�g�Q
  �@�X�e�[�g�Q �� �T �� �X�e�[�g�R
  �@�X�e�[�g�R �� �S �� �o�N�X�e���o�܂�(�X�e�[�g�R�Ɏc��)
  �X�e�[�g�w����X�e�[�g�O�ɖ߂�̂͂P�T�t���[����������B
  ����܂ł́A���̃o�N�X�e�̓��͂��n�܂�Ȃ��B
  ���ڂ̃o�N�X�e�̓��͂��i�T�S�T �҂� �S�j�ɂ���΁A
  �Ō�́u�S�v�̂�����ɃX�e�[�g�O�ɖ߂��āA�A���o�N�X�e���o����B
* Backdash has 1 frame of recovery.
  Moon and Chibimoon can cancel that 1 frame.
  This makes their Backdash��Backdash completely invincible.
  However, Moon's backdash is too fast for it to work properly.
  The input (5454) looks like this:
    State0 �� 5 �� State1
    State1 �� 4 �� State2
    State2 �� 5 �� State3
    State3 �� 4 �� Backdash, remain in State3.
  It takes 15 frames to return from the above states to State0.
  Until then, it is not possible to start another backdash input.
  If you input the first backdash as (545 wait 4), the return to state0
  occurs very shortly after the last 4, allowing for consecutive backdashes.

  �E���k�X�͂P�t���[�����Ɂu�S�T�S���������v����͂���΁A
 �P�S�e�̃o�N�X�e�̌�܂ŃX�e�[�g�R�Ɏc���āA
  ���̂܂ܓ��ڂ̃o�N�X�e���o�܂��B
  With Uranus if you input a frame perfect 454(hold),
  State3 remains for 1 frame after the 14 frame backdash ends,
  and a second backdash will come out while still holding 4.