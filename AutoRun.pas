//********************************************
//autorun module by SpawN
//avalible function:
//1. DoAppToRun(Название,Полный путь до приложения); - Добавить в автозагрузку
//2. IsAppInRun(Название); - Проверить добавлено ли в автозагрузку
//3. DelAppFromRun(Название); - Удалить из автозагрузки
//********************************************



unit AutoRun;

interface

uses registry,Windows;

procedure DoAppToRun(RunName, AppName: string);
function IsAppInRun(RunName: string): Boolean;
procedure DelAppFromRun(RunName: string);

implementation

procedure DoAppToRun(RunName, AppName: string);
var
Reg: TRegistry;
begin
Reg := TRegistry.Create;
with Reg do
begin
RootKey := HKEY_LOCAL_MACHINE;
OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
WriteString(RunName, AppName);
CloseKey;
Free;
end;
end;

// Check if the application is in the registry...

function IsAppInRun(RunName: string): Boolean;
var
Reg: TRegistry;
begin
Reg := TRegistry.Create;
with Reg do
begin
RootKey := HKEY_LOCAL_MACHINE;
OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
Result := ValueExists(RunName);
CloseKey;
Free;
end;
end;

// Remove the application from the registry...

procedure DelAppFromRun(RunName: string);
var
Reg: TRegistry;
begin
Reg := TRegistry.Create;
with Reg do
begin
RootKey := HKEY_LOCAL_MACHINE;
OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
if ValueExists(RunName) then DeleteValue(RunName);
CloseKey;
Free;
end;
end;

end.

