//********************************************
//Sound control button by SpawN
//Currently work on windows 7 onlY!
//********************************************


unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MMSystem, Vcl.StdCtrls,  ActiveX,
  ComObj, Vcl.ImgList, Vcl.Menus, Vcl.ComCtrls, Vcl.ExtCtrls, IniFiles,
  System.ImageList;

type
  TForm1 = class(TForm)
    SoundButton: TButton;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    Settings: TMenuItem;
    ExitButton: TMenuItem;
    AutoStart: TMenuItem;
    Panel1: TPanel;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Timer1: TTimer;
    procedure SoundButtonClick(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure AutoStartClick(Sender: TObject);
    procedure SettingsClick(Sender: TObject);
    procedure LoadSettings;
    procedure SaveSettings;
    procedure TrackBar1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  IAudioEndpointVolumeCallback = interface(IUnknown)
  ['{657804FA-D6AD-4496-8A60-352752AF4F89}']
  end;

  IAudioEndpointVolume = interface(IUnknown)
    ['{5CDF2C82-841E-4546-9722-0CF74078229A}']
    function RegisterControlChangeNotify(AudioEndPtVol: IAudioEndpointVolumeCallback): HRESULT; stdcall;
    function UnregisterControlChangeNotify(AudioEndPtVol: IAudioEndpointVolumeCallback): HRESULT; stdcall;
    function GetChannelCount(out PInteger): HRESULT; stdcall;
    function SetMasterVolumeLevel(fLevelDB: single; pguidEventContext: PGUID): HRESULT; stdcall;
    function SetMasterVolumeLevelScalar(fLevelDB: single; pguidEventContext: PGUID): HRESULT; stdcall;
    function GetMasterVolumeLevel(out fLevelDB: single): HRESULT; stdcall;
    function GetMasterVolumeLevelScaler(out fLevelDB: single): HRESULT; stdcall;
    function SetChannelVolumeLevel(nChannel: Integer; fLevelDB: double; pguidEventContext: PGUID): HRESULT; stdcall;
    function SetChannelVolumeLevelScalar(nChannel: Integer; fLevelDB: double; pguidEventContext: PGUID): HRESULT; stdcall;
    function GetChannelVolumeLevel(nChannel: Integer; out fLevelDB: double): HRESULT; stdcall;
    function GetChannelVolumeLevelScalar(nChannel: Integer; out fLevel: double): HRESULT; stdcall;
    function SetMute(bMute: Boolean; pguidEventContext: PGUID): HRESULT; stdcall;
    function GetMute(out bMute: Boolean): HRESULT; stdcall;
    function GetVolumeStepInfo(pnStep: Integer; out pnStepCount: Integer): HRESULT; stdcall;
    function VolumeStepUp(pguidEventContext: PGUID): HRESULT; stdcall;
    function VolumeStepDown(pguidEventContext: PGUID): HRESULT; stdcall;
    function QueryHardwareSupport(out pdwHardwareSupportMask): HRESULT; stdcall;
    function GetVolumeRange(out pflVolumeMindB: double; out pflVolumeMaxdB: double; out pflVolumeIncrementdB: double): HRESULT; stdcall;
  end;

  IAudioMeterInformation = interface(IUnknown)
  ['{C02216F6-8C67-4B5B-9D00-D008E73E0064}']
  end;

  IPropertyStore = interface(IUnknown)
  end;

  IMMDevice = interface(IUnknown)
  ['{D666063F-1587-4E43-81F1-B948E807363F}']
    function Activate(const refId: TGUID; dwClsCtx: DWORD;  pActivationParams: PInteger; out pEndpointVolume: IAudioEndpointVolume): HRESULT; stdCall;
    function OpenPropertyStore(stgmAccess: DWORD; out ppProperties: IPropertyStore): HRESULT; stdcall;
    function GetId(out ppstrId: PLPWSTR): HRESULT; stdcall;
    function GetState(out State: Integer): HRESULT; stdcall;
  end;


  IMMDeviceCollection = interface(IUnknown)
  ['{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}']
  end;

  IMMNotificationClient = interface(IUnknown)
  ['{7991EEC9-7E89-4D85-8390-6C703CEC60C0}']
  end;

  IMMDeviceEnumerator = interface(IUnknown)
  ['{A95664D2-9614-4F35-A746-DE8DB63617E6}']
    function EnumAudioEndpoints(dataFlow: TOleEnum; deviceState: SYSUINT; DevCollection: IMMDeviceCollection): HRESULT; stdcall;
    function GetDefaultAudioEndpoint(EDF: SYSUINT; ER: SYSUINT; out Dev :IMMDevice ): HRESULT; stdcall;
    function GetDevice(pwstrId: pointer; out Dev: IMMDevice): HRESULT; stdcall;
    function RegisterEndpointNotificationCallback(pClient: IMMNotificationClient): HRESULT; stdcall;
  end;

const
  CLASS_IMMDeviceEnumerator : TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';
  IID_IMMDeviceEnumerator : TGUID = '{A95664D2-9614-4F35-A746-DE8DB63617E6}';
  IID_IAudioEndpointVolume : TGUID = '{5CDF2C82-841E-4546-9722-0CF74078229A}';
var
  Form1: TForm1;
  Hit: boolean;
_x,_y: integer;
ini:TIniFile;
implementation

{$R *.dfm}

uses AutoRun;

procedure SetMasterVolume(fLevelDB: single);
var
  pEndpointVolume: IAudioEndpointVolume;
  LDeviceEnumerator: IMMDeviceEnumerator;
  Dev: IMMDevice;
begin
  if not Succeeded(CoCreateInstance(CLASS_IMMDeviceEnumerator, nil, CLSCTX_INPROC_SERVER, IID_IMMDeviceEnumerator, LDeviceEnumerator)) then
   RaiseLastOSError;
  if not Succeeded(LDeviceEnumerator.GetDefaultAudioEndpoint($00000000, $00000000, Dev)) then
   RaiseLastOSError;

  if not Succeeded( Dev.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, nil, pEndpointVolume)) then
   RaiseLastOSError;

  if not Succeeded(pEndpointVolume.SetMasterVolumeLevelScalar(fLevelDB, nil)) then
   RaiseLastOSError;
end;


procedure TForm1.AutoStartClick(Sender: TObject);
begin
if AutoStart.Checked then
    begin
      AutoStart.Checked:=false;
      DelAppFromRun('SoundC');
    end
    else
    begin
      AutoStart.Checked:=True;
      DoAppToRun('SoundC',Application.ExeName);
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
panel1.Visible:=false;
SoundButton.Visible:=true;
Ini:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'1.ini');
ini.WriteInteger('main','level',trackbar1.Position);
ini.Free;
end;

procedure TForm1.ExitButtonClick(Sender: TObject);
begin
close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
hit:=false;
Ini:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'1.ini');
trackbar1.Position:=Ini.ReadInteger('main','level',5);
ini.Free;
SetMasterVolume(trackbar1.Position/10);
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Hit:=true;
  _x:=X; _y:=Y;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Hit then
  begin
   left:=left+(x-_x);
   top:=top+(y-_y);
  end;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Hit:=false;
  Ini:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'1.ini');
  ini.WriteInteger('main','left',left);
  ini.WriteInteger('main','top',top);
  ini.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Ini:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'1.ini');
  left:=ini.ReadInteger('main','left',0);
  top:=ini.ReadInteger('main','top',0);
  ini.Free;
end;

procedure TForm1.LoadSettings;
begin
//
end;

procedure TForm1.PopupMenu1Popup(Sender: TObject);
begin
if IsAppInRun('SoundC') then
AutoStart.Checked:=true
else
AutoStart.Checked:=false;
end;

procedure TForm1.SaveSettings;
begin
//
end;

procedure TForm1.SettingsClick(Sender: TObject);
begin
SoundButton.Visible:=false;
panel1.Visible:=true;
end;

procedure TForm1.SoundButtonClick(Sender: TObject);
begin
case SoundButton.Tag of
0: begin
SoundButton.Tag:=1;
SetMasterVolume(0.0);
SoundButton.ImageIndex:=1;
end;
1: begin
SoundButton.Tag:=0;
SetMasterVolume(trackbar1.Position/10);
SoundButton.ImageIndex:=0;
end;

end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
if (getasynckeystate($01)) AND (getasynckeystate($02))<>0 then
begin
application.Minimize;
end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
Label1.Caption:=IntToStr(TrackBar1.Position*10)+'%';
end;

end.
