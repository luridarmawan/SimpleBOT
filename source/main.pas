unit main;

{$mode objfpc}{$H+}

interface

uses
  simplebot_controller,
  Classes, SysUtils, fpcgi, HTTPDefs, fastplaz_handler, html_lib, database_lib;

type

  { TMainModule }

  TMainModule = class(TMyCustomWebModule)
  private
    procedure BeforeRequestHandler(Sender: TObject; ARequest: TRequest);
    function defineHandler(const IntentName: string; Params: TStrings): string;
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
end;

destructor TMainModule.Destroy;
begin
  inherited Destroy;
end;

// Init First
procedure TMainModule.BeforeRequestHandler(Sender: TObject; ARequest: TRequest);
begin
  Response.ContentType := 'application/json';
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
  Text, ChatID, MessageID: string;
begin

  // telegram style
  //   {"message":{"message_id":0,"text":"Hi","chat":{"id":0}}}
  json := TJSONUtil.Create;
  json.LoadFromJsonString(Request.Content);
  Text := json['message/text'];
  if Text = 'False' then
    Text := '';
  MessageID := json['message/message_id'];
  ChatID := json['message/chat/id'];
  json.Free;

  // jika tidak ada di body, ambil dari parameter POST
  if Text = '' then
    Text := _POST['text'];

  SimpleBOT := TSimpleBotModule.Create;
  SimpleBOT.ChatID := ChatID;
  SimpleBOT.OnError := @OnErrorHandler;  // Your Custom Message
  SimpleBOT.Handler['define'] := @defineHandler;
  text_response := SimpleBOT.Exec(Text);
  SimpleBOT.Free;

  // Send To Telegram
  {
  if s2i(ChatID) <> 0 then
    TelegramSend(ChatID, MessageID, SimpleAI.ResponseText);
  }

  //---
  Response.Content := text_response;
end;

function TMainModule.defineHandler(const IntentName: string; Params: TStrings): string;
var
  i: integer;
  keyName, keyValue: string;
begin
  i := 2;
  if SimpleBOT.Debug then
    i := 3;

  if Params.Count < i then //
  begin
    keyName := Params.Names[0];
    keyValue := Params.ValueFromIndex[0];
    SimpleBOT.SetSession(_AI_SESSION_USER + keyName, keyValue);
    Result := SimpleBOT.GetResponse(IntentName + 'Response', '', '');
    if preg_match('%(' + keyName + ')%', Result) then
    begin
      Result := preg_replace('%(' + keyName + ')%', keyValue, Result, True);
    end;

    if keyName = 'Email' then
    begin
      if not isEmail( keyValue) then
        Result := SimpleBOT.GetResponse( 'EmailTidakValid');
    end;

    Result := SimpleBOT.StringReplacement( Result);
  end // count < 1
  else
  begin // global define: blablabla adalah bla bla bla bla
    keyName := Params.Values['Key'];
    keyValue := Params.Values['Value'];
    Result := keyName + ' = ' + keyValue;

    Result := SimpleBOT.GetResponse( 'HalBaru');
    Result := StringReplace( Result, '%word%', UpperCase( keyName), [rfReplaceAll]);
  end;

  // Simpan ke database
  //   keyName & keyValue
  //

end;

function TMainModule.OnErrorHandler(const Message: string): string;
var
  s: string;
begin
  s := Trim(Message);
  if s <> '' then
  begin
    //Result := 'Your custom message: ..... ';
    Result := SimpleBOT.GetResponse( 'none');
  end;

  if isWord(s) then
  begin
    s := StringReplace(SimpleBOT.GetResponse('InginTahu', ''),
      '%word%', s, [rfReplaceAll]);
    Result := s;
    Exit;
  end;


  // simpan message, untuk dipelajari oleh AI
  //
  //

end;


end.
