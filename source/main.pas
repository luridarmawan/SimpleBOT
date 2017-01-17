unit main;

{$mode objfpc}{$H+}

interface

uses
  simplebot_controller, logutil_lib,
  domainwhois_controller,
  Classes, SysUtils, fpcgi, HTTPDefs, fastplaz_handler, database_lib;

type

  { TMainModule }

  TMainModule = class(TMyCustomWebModule)
  private
    DomainWhois: TDomainWhoisController;
    procedure BeforeRequestHandler(Sender: TObject; ARequest: TRequest);
    function defineHandler(const IntentName: string; Params: TStrings): string;
    function isTelegram: boolean;
  public
    SimpleBOT: TSimpleBotModule;
    constructor CreateNew(AOwner: TComponent; CreateMode: integer); override;
    destructor Destroy; override;

    procedure Get; override;
    procedure Post; override;
    function OnErrorHandler(const Message: string): string;
  end;

implementation

uses json_lib, common;

constructor TMainModule.CreateNew(AOwner: TComponent; CreateMode: integer);
begin
  inherited CreateNew(AOwner, CreateMode);
  BeforeRequest := @BeforeRequestHandler;

  DomainWhois := TDomainWhoisController.Create;
end;

destructor TMainModule.Destroy;
begin
  DomainWhois.Free;
  inherited Destroy;
end;

// Init First
procedure TMainModule.BeforeRequestHandler(Sender: TObject; ARequest: TRequest);
begin
  //  Response.ContentType := 'application/json';
end;

// GET Method Handler
procedure TMainModule.Get;
begin
  Response.Content := '{}';
end;

// POST Method Handler
// CURL example:
//   curl "http://local-bot.fastplaz.com/ai/" -X POST -d '{"message":{"message_id":0,"chat":{"id":0},"text":"Hi"}}'
procedure TMainModule.Post;
var
  json: TJSONUtil;
  text_response: string;
  Text, chatID, messageID, fullName, userName, telegramToken: string;
  i: integer;
begin

  // telegram style
  //   {"message":{"message_id":0,"text":"Hi","chat":{"id":0}}}
  json := TJSONUtil.Create;
  try
    json.LoadFromJsonString(Request.Content);
    Text := json['message/text'];
    if Text = 'False' then
      Text := '';
    messageID := json['message/message_id'];
    chatID := json['message/chat/id'];
    userName := json['message/chat/username'];
    fullName := json['message/chat/first_name'] + ' ' + json['message/chat/last_name'];
  except
    // jika tidak ada di body, ambil dari parameter post
    Text := _POST['text'];
  end;

  // maybe submitted from post data
  if Text = '' then
    Text := _POST['text'];


  SimpleBOT := TSimpleBotModule.Create;
  SimpleBOT.chatID := chatID;
  if userName <> '' then
  begin
    SimpleBOT.UserData['Name'] := userName;
    SimpleBOT.UserData['FullName'] := fullName;
  end;
  SimpleBOT.OnError := @OnErrorHandler;  // Your Custom Message
  SimpleBOT.Handler['define'] := @defineHandler;
  SimpleBOT.Handler['domain_whois'] := @DomainWhois.whoisHandler;
  text_response := SimpleBOT.Exec(Text);
  SimpleBOT.Free;

  // Send To Telegram
  // add paramater 'telegram=1' to your telegram url
  if isTelegram then
  begin
    telegramToken := Config[_TELEGRAM_CONFIG_TOKEN];
    for i := 0 to SimpleBOT.SimpleAI.ResponseText.Count - 1 do
    begin
      if i > 0 then
        messageID := '';
      SimpleBOT.TelegramSend(telegramToken,
        chatID, messageID,
        SimpleBOT.SimpleAI.ResponseText[i]);
    end;
  end;

  //---
  Response.ContentType := 'application/json';
  Response.Content := text_response;
end;

function TMainModule.defineHandler(const IntentName: string; Params: TStrings): string;
var
  keyName, keyValue: string;
begin

  // global define
  keyName := Params.Values['Key'];
  if keyName <> '' then
  begin
    keyName := Params.Values['Key'];
    keyValue := Params.Values['Value'];
    Result := keyName + ' = ' + keyValue;
    Result := SimpleBOT.GetResponse('HalBaru');
    Result := StringReplace(Result, '%word%', UpperCase(keyName), [rfReplaceAll]);
  end;

  Result := SimpleBOT.StringReplacement(Result);

  // Example Set & Get temporer user data
  {
  SimpleBOT.UserData[ 'name'] := 'Luri Darmawan';
  varstring :=   SimpleBOT.UserData[ 'name'];
  }

  // Save to database
  //   keyName & keyValue

end;

function TMainModule.isTelegram: boolean;
begin
  Result := False;
  if _GET['telegram'] = '1' then
    Result := True;
end;

function TMainModule.OnErrorHandler(const Message: string): string;
var
  s: string;
begin
  s := Trim(Message);
  s := StringReplace(SimpleBOT.GetResponse('InginTahu', ''), '%word%',
    s, [rfReplaceAll]);
  Result := s;


  // simpan message ke DB, untuk dipelajari oleh AI

end;


end.
