# -*- mode: python -*-

block_cipher = None


a = Analysis(['sms_patcher.py'],
             pathex=['D:\\Games\\Fighting\\~SNES\\~sailormoon'],
             binaries=[],
             datas=[],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=['_bz2', '_hashlib', '_lzma', '_socket', '_ssl', 'pyexpat', 'unicodedata', 'select'],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='sms_patcher',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          runtime_tmpdir=None,
          console=True )
