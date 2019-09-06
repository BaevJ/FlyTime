unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Variants, Windows, Math, Classes, Forms, SysUtils, EditBtn, StdCtrls, Graphics,
 Dialogs, ExtCtrls, Controls, Menus, Spin, Buttons, ComCtrls,
 DateUtils, Registry;

type

  { TForm1 }

  TForm1 = class(TForm)
    Beffly: TEdit;
    Button1: TButton;
    Button2: TButton;
    Calc1: TLabel;
    arrdate: TDateEdit;
    Deppdate: TDateEdit;
    Duty: TEdit;
    Aftfly: TEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    maxduty: TEdit;
    minrest: TEdit;
    Image1: TImage;
    Label10: TLabel;
    Calc2: TLabel;
    locdep: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    locarr: TLabel;
    Label18: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    PageControl1: TPageControl;
    SpinEdit1: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Depp: TTimeEdit;
    Arr: TTimeEdit;
    procedure AftflyKeyPress(Sender: TObject; var Key: char);
    procedure BefflyKeyPress(Sender: TObject; var Key: char);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit2DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Label15Click(Sender: TObject);
    procedure Label18Click(Sender: TObject);
    procedure maxdutyKeyPress(Sender: TObject; var Key: char);
    procedure minrestKeyPress(Sender: TObject; var Key: char);
    procedure activationcheck();
  private

  public

  end;

var
  Form1: TForm1;
  Reg: TRegistry;

const
  n = 15;
  m = -7;

implementation

{$R *.lfm}

{ TForm1 }

function CaesarEncipher(toCode: string): string;  //шифратор
var i, T: integer;
begin
  for i := 1 to length(toCode) do begin
    T := (Ord(toCode[ i ]) + n);
    if T >= 256 then dec(T, 256);
    toCode[ i ] := Chr(T);
  end;
  CaesarEncipher := toCode;
end;

function CaesarEncipher1(toCode: string): string;  //шифратор
var i, T: integer;
begin
  for i := 1 to length(toCode) do begin
    T := (Ord(toCode[ i ]) + m);
    if T >= 256 then dec(T, 256);
    toCode[ i ] := Chr(T);
  end;
  CaesarEncipher1   := toCode;
end;

function computerName:string;
var
  Length:DWord;
begin
  Length:=0;
  getComputerName(nil,Length);
  setLength(Result,Length-1);
  getComputerName(PChar(Result),Length);
end;


procedure TForm1.Button1Click(Sender: TObject);
var
   a, b, c, d, e, result: integer;
   begin
    Calc1.Caption:= '';
    Calc2.Caption:= '';
    Duty.Font.Color:=$000000;
    If Beffly.text = '' then begin Beffly.text := '01:00'; end;
    If Aftfly.text = '' then begin Aftfly.text := '0:30'; end;
    If Depp.text = '' then begin Depp.text := '01:00'; end;
    If Arr.text = '' then begin Arr.text := '11:45'; end;
    If minrest.text = '' then begin minrest.text := '12:00'; end;
    If maxduty.text = '' then begin maxduty.text := '12:00'; end;

    a := minutesbetween(0, Depp.Time);    // время вылета
    b := minutesbetween(0, Arr.Time);     // время прилета
    c := minutesbetween(0, strtotime(Beffly.text));  // за сколько да вылета начинается предполетная подготовка к рейсу
    d := minutesbetween(0, strtotime(Aftfly.text));  // время послеполетного разбора
    e := minutesbetween(0, strtotime(minrest.text));  // минимальное время отдыха

    result := ifthen (a>=b, 1440-a+b+c+d, b-a+c+d);  //расчет времени полетной смены
    Duty.Text:=inttostr(result div 60)+ ':' + FormatFloat('0#', result mod 60); //вывод результата в поле

    arrdate.text := Formatdatetime('dd.MM.YYYY', incminute(deppdate.date, a+result)); //расчет даты прилета

    locdep.Caption:= Formatdatetime('hh:mm', Depp.Time + SpinEdit1.value/24);    // вылет с учетом разницы с UTC
    locarr.Caption:= Formatdatetime('hh:mm', Arr.Time + SpinEdit1.value/24);     // прилет с учетом разницы с UTC

    if result>e then begin duty.Font.Color:=$0000FF end;  //Если ПС > 12 часов - красным
    if result<e then begin duty.Font.Color:=$000000 end;  //Если ПС < 12 часов - черным

    if result*2>e then
       begin label8.Caption:= 'Rest after duty: ' + inttostr(result*2 div 60)+ ':' + FormatFloat('0#', result*2 mod 60); //расчет отдыха после смены
       label9.Caption:= 'Next duty not before: ' + Formatdatetime('dd.MM.YYYY hh:mm', incminute(arrdate.date + arr.time + strtotime(Aftfly.text), result*2))
       end;
    if result*2<e then
       begin label8.Caption:= 'Rest after duty: ' + minrest.text;
       label9.Caption:= 'Next duty not before: ' + Formatdatetime('dd.MM.YYYY hh:mm', incminute(arrdate.date + arr.time + strtotime(Aftfly.text), e))
       end;

    //проверка ночного вылета
    if (strtotime(Depp.text)+(SpinEdit1.value/24)-strtotime(Beffly.text) > strtotime('22:00')) or (strtotime(Depp.text)+(SpinEdit1.value/24)-strtotime(Beffly.text) < strtotime('06:01')) then
       begin
       calc2.caption := 'Duty starts between 22:00-06:00';
       end;

    //проверка ночной ПС
    if strtotime(locdep.Caption)>strtotime(locarr.Caption) then
     begin
     if strtotime(locarr.Caption)+strtotime(Aftfly.text)+strtotime('2:00') > strtotime('22:00')-strtotime(locdep.Caption)+strtotime(Beffly.text) then Calc1.Caption:= 'More than 50% of duty time between 22:00-06:00';
     end;
    if (strtotime(locdep.Caption)-strtotime(Beffly.text) < strtotime('06:00')) and (strtotime('06:00')-strtotime(locdep.Caption)+strtotime(Beffly.text) > strtotime(locarr.Caption)+strtotime(Aftfly.text)-strtotime('06:00'))
     then Calc1.Caption:= 'More than 50% of duty time between 22:00-06:00';
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Reg:=TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey('\SOFTWARE\Dutytime', true);

  Reg.WriteString('Beffly', Beffly.text);
  Reg.WriteString('Aftfly', Aftfly.text);
  Reg.WriteString('minrest', minrest.text);
  Reg.WriteString('maxduty', maxduty.text);
  Reg.WriteInteger('TMZN', Spinedit1.value);
  Reg.WriteString('acode', Edit2.text);

  Reg.Free;

  ShowMessage('Settings have been saved');
  activationcheck();
  edit2.readonly:=true;
end;

procedure TForm1.Edit2DblClick(Sender: TObject);
begin
 edit2.readonly:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Deppdate.Text:=datetimetostr(now);
  Deppdate.Alignment:=tacenter;
  arrdate.Alignment:=tacenter;
  Depp.Alignment:=tacenter;
  arr.Alignment:=tacenter;
  Edit1.text:=CaesarEncipher(ComputerName);
  label8.Caption:= 'Rest after duty: ' + minrest.text;

  //Загрузка схраненых настроек//
  Reg:=TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey('\SOFTWARE\Dutytime', true);
  if reg.ValueExists('Beffly') then Beffly.text := Reg.ReadString('Beffly');
  if reg.ValueExists('Aftfly') then Aftfly.text := Reg.ReadString('Aftfly');
  if reg.ValueExists('minrest') then minrest.text := Reg.ReadString('minrest');
  if reg.ValueExists('maxduty') then maxduty.text := Reg.ReadString('maxduty');
  if reg.ValueExists('acode') then Edit2.text :=  Reg.ReadString('acode');
  if reg.ValueExists('TMZN') then Spinedit1.value := Reg.ReadInteger('TMZN');
  Reg.free;
  activationcheck();
  edit2.readonly:=true;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
 Duty.SelectAll;
 Duty.CopyToClipboard;
end;

procedure TForm1.Label15Click(Sender: TObject);
begin
   MessageBox(handle,'Flight duty time calculator for civil aviation based on common international rules. You can change some rules on Settings tab. All questions and requests please send to BaevAA@mail.ru','Flight duty time calculator', MB_ICONQUESTION);
end;

procedure TForm1.Label18Click(Sender: TObject);
begin
   MessageBox(handle,'Please enter Activation code and press "Save settings" to activate program. Double click on field to edit. To get Activatation code, please send your Program code to BaevAA@mail.ru','Good luck!', MB_ICONQUESTION);
end;

procedure TForm1.maxdutyKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', '.', ',', ';', ':', #8]) then
  Key := #0;
  if Key='.' then key:=':';
  if Key=',' then key:=':';
  if Key=';' then key:=':';
end;

procedure TForm1.minrestKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', '.', ',', ';', ':', #8]) then
  Key := #0;
  if Key='.' then key:=':';
  if Key=',' then key:=':';
  if Key=';' then key:=':';
end;

procedure TForm1.AftflyKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', '.', ',', ';', ':', #8]) then
  Key := #0;
  if Key='.' then key:=':';
  if Key=',' then key:=':';
  if Key=';' then key:=':';
end;

procedure TForm1.BefflyKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', '.', ',', ';', ':', #8]) then
  Key := #0;
  if Key='.' then key:=':';
  if Key=',' then key:=':';
  if Key=';' then key:=':';
end;

                 //Проверка активации программы//
procedure TForm1.activationcheck();
 begin
    if Edit2.text <> CaesarEncipher1(ComputerName) then
    begin
    ShowMessage('Please enter Activation code on Settings tab');
    TabSheet1.enabled:=false;
    edit2.readonly:=false;
    end
    else
    TabSheet1.enabled:=true;

end;

end.

